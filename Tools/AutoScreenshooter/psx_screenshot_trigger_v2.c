typedef unsigned int u32;
typedef unsigned short u16;
typedef signed int s32;
typedef unsigned long usize;

#define SYS_exit       1
#define SYS_write      4
#define SYS_open       5
#define SYS_close      6
#define SYS_ioctl     54
#define SYS_nanosleep 162

#define O_WRONLY    1
#define O_NONBLOCK  04000

#define EV_SYN 0x00
#define EV_KEY 0x01
#define SYN_REPORT 0
#define KEY_S 31
#define KEY_LEFTMETA 125

#define UI_SET_EVBIT  0x40045564u
#define UI_SET_KEYBIT 0x40045565u
#define UI_DEV_CREATE 0x00005501u
#define UI_DEV_DESTROY 0x00005502u

struct input_id {
    u16 bustype;
    u16 vendor;
    u16 product;
    u16 version;
};

struct uinput_user_dev {
    char name[80];
    struct input_id id;
    u32 ff_effects_max;
    s32 absmax[64];
    s32 absmin[64];
    s32 absfuzz[64];
    s32 absflat[64];
};

struct input_event32 {
    s32 tv_sec;
    s32 tv_usec;
    u16 type;
    u16 code;
    s32 value;
};

struct timespec32 {
    s32 tv_sec;
    s32 tv_nsec;
};

static inline long sc0(long n) {
    register long r7 asm("r7") = n;
    register long r0 asm("r0");
    asm volatile("svc 0" : "=r"(r0) : "r"(r7) : "memory");
    return r0;
}

static inline long sc1(long n, long a0) {
    register long r7 asm("r7") = n;
    register long r0 asm("r0") = a0;
    asm volatile("svc 0" : "+r"(r0) : "r"(r7) : "memory");
    return r0;
}

static inline long sc2(long n, long a0, long a1) {
    register long r7 asm("r7") = n;
    register long r0 asm("r0") = a0;
    register long r1 asm("r1") = a1;
    asm volatile("svc 0" : "+r"(r0) : "r"(r1), "r"(r7) : "memory");
    return r0;
}

static inline long sc3(long n, long a0, long a1, long a2) {
    register long r7 asm("r7") = n;
    register long r0 asm("r0") = a0;
    register long r1 asm("r1") = a1;
    register long r2 asm("r2") = a2;
    asm volatile("svc 0" : "+r"(r0) : "r"(r1), "r"(r2), "r"(r7) : "memory");
    return r0;
}

static usize cstrlen(const char *s) {
    usize n = 0;
    while (s[n]) n++;
    return n;
}

static void msg(const char *s) {
    sc3(SYS_write, 2, (long)s, (long)cstrlen(s));
}

static void sleep_ns(s32 sec, s32 nsec) {
    struct timespec32 ts;
    ts.tv_sec = sec;
    ts.tv_nsec = nsec;
    sc2(SYS_nanosleep, (long)&ts, 0);
}

static int emit(int fd, u16 type, u16 code, s32 value) {
    struct input_event32 ev;
    ev.tv_sec = 0;
    ev.tv_usec = 0;
    ev.type = type;
    ev.code = code;
    ev.value = value;
    long r = sc3(SYS_write, fd, (long)&ev, sizeof(ev));
    return (r == (long)sizeof(ev)) ? 0 : -1;
}

static int sync_ev(int fd) {
    return emit(fd, EV_SYN, SYN_REPORT, 0);
}

static void zero(void *p, usize n) {
    unsigned char *b = (unsigned char *)p;
    for (usize i = 0; i < n; i++) b[i] = 0;
}

static void copy_name(char *dst, const char *src, usize max) {
    usize i = 0;
    while (i + 1 < max && src[i]) {
        dst[i] = src[i];
        i++;
    }
    if (max) dst[i] = 0;
}

static int run(void) {
    const char *dev = "/dev/uinput";
    int fd = (int)sc2(SYS_open, (long)dev, O_WRONLY | O_NONBLOCK);
    if (fd < 0) {
        msg("ERROR: cannot open /dev/uinput\n");
        return 20;
    }

    if (sc3(SYS_ioctl, fd, UI_SET_EVBIT, EV_KEY) < 0 ||
        sc3(SYS_ioctl, fd, UI_SET_EVBIT, EV_SYN) < 0 ||
        sc3(SYS_ioctl, fd, UI_SET_KEYBIT, KEY_LEFTMETA) < 0 ||
        sc3(SYS_ioctl, fd, UI_SET_KEYBIT, KEY_S) < 0) {
        msg("ERROR: uinput capability ioctl failed\n");
        sc1(SYS_close, fd);
        return 21;
    }

    struct uinput_user_dev uidev;
    zero(&uidev, sizeof(uidev));
    copy_name(uidev.name, "PSC Screenshot Trigger", sizeof(uidev.name));
    uidev.id.bustype = 0x03;
    uidev.id.vendor = 0x1209;
    uidev.id.product = 0x5053;
    uidev.id.version = 1;

    if (sc3(SYS_write, fd, (long)&uidev, sizeof(uidev)) != (long)sizeof(uidev)) {
        msg("ERROR: writing uinput device descriptor failed\n");
        sc1(SYS_close, fd);
        return 22;
    }

    if (sc2(SYS_ioctl, fd, UI_DEV_CREATE) < 0) {
        msg("ERROR: UI_DEV_CREATE failed\n");
        sc1(SYS_close, fd);
        return 23;
    }

    sleep_ns(3, 0);

    if (emit(fd, EV_KEY, KEY_LEFTMETA, 1)) goto emit_fail;
    if (emit(fd, EV_KEY, KEY_S, 1)) goto emit_fail;
    if (sync_ev(fd)) goto emit_fail;

    sleep_ns(0, 60000000);

    if (emit(fd, EV_KEY, KEY_S, 0)) goto emit_fail;
    if (emit(fd, EV_KEY, KEY_LEFTMETA, 0)) goto emit_fail;
    if (sync_ev(fd)) goto emit_fail;

    sleep_ns(1, 0);
    sc2(SYS_ioctl, fd, UI_DEV_DESTROY);
    sc1(SYS_close, fd);
    msg("OK: SUPER+S injected (stable chord)\n");
    return 0;

emit_fail:
    msg("ERROR: writing keyboard events failed\n");
    sc2(SYS_ioctl, fd, UI_DEV_DESTROY);
    sc1(SYS_close, fd);
    return 24;
}

void _start(void) {
    int code = run();
    sc1(SYS_exit, code);
    for (;;) {}
}
