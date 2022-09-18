//
// Created by Xu on 9/16/22.
//

#ifndef SOFTWARE_SECURITY_MAIN_H
#define SOFTWARE_SECURITY_MAIN_H

typedef long long time_t;

typedef struct struct_send_ {
    const char type;
    const time_t time;
    const char *str;
} *send_data_t;

typedef void send_fn_t(send_data_t);

typedef struct struct_attach_ {
    send_fn_t *send_fn;
    const time_t time;
    const char *executable_path;
} *attach_data_t;

typedef struct struct_stop_ {
    int code;
} *stop_data_t;

void ci_init(attach_data_t);

void ci_stop(stop_data_t);

#endif //SOFTWARE_SECURITY_MAIN_H
