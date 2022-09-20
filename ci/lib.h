//
// Created by Xu on 9/16/22.
//

#ifndef SOFTWARE_SECURITY_MAIN_H
#define SOFTWARE_SECURITY_MAIN_H

typedef long long ci_time_t;
#define LIB_START_SIG 12
#define LIB_STOP_SIG 13

#define msg_box_t 0b1

#define heap_basic_t 0b1
#define file_basic_t 0b10
#define reg_basic_t 0b100
#define net_basic_t 
#define mem_copy_basic_t

#define heap_restrict_t

#define file_restric_t

#define reg_restric_t

#define net_restrict_t

#define mem_copy_restrict_t

typedef unsigned int u32_t;

typedef struct struct_send_ {
    const u32_t type;
    const ci_time_t time;
    const char *str;
} *send_data_t;

typedef void send_fn_t(send_data_t);

typedef struct struct_attach_ {
    send_fn_t *send_fn;
    const ci_time_t time;
    const u32_t type;
    const char *executable_path;
} *attach_data_t;

extern "C" void ci_init(attach_data_t);

#endif //SOFTWARE_SECURITY_MAIN_H
