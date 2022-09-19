//
// Created by Xu on 9/16/22.
//

#ifndef SOFTWARE_SECURITY_MAIN_H
#define SOFTWARE_SECURITY_MAIN_H

typedef long ci_time_t;
#define LIB_START_SIG 12
#define LIB_STOP_SIG 13

typedef struct struct_send_ {
    const char type;
    const ci_time_t time;
    const char *str;
} *send_data_t;

typedef void send_fn_t(send_data_t);

typedef struct struct_attach_ {
    send_fn_t *send_fn;
    const ci_time_t time;
    const char *executable_path;
} *attach_data_t;

typedef struct struct_stop_ {
    int code;
} *stop_data_t;

extern "C" void ci_init(attach_data_t);

extern "C" void ci_stop(stop_data_t);

#endif //SOFTWARE_SECURITY_MAIN_H
