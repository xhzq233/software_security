//
// Created by Xu on 9/16/22.
//

#ifndef SOFTWARE_SECURITY_MAIN_H
#define SOFTWARE_SECURITY_MAIN_H

typedef long long ci_time_t;
#define LIB_START_SIG 12
#define LIB_STOP_SIG 13

/// struct_attach_ data type
/// configurations on every bit
#define msg_box_t           0b1
#define heap_basic_t        0b10
#define file_basic_t        0b100
#define reg_basic_t         0b1000
#define net_basic_t         0b10000
#define mem_copy_basic_t    0b100000
#define heap_restrict_t     0b1000000
#define file_restrict_t     0b10000000
#define reg_restrict_t      0b100000000
#define net_restrict_t      0b1000000000
#define mem_copy_restrict_t 0b10000000000

typedef unsigned int u32_t;

typedef struct struct_send_ {
#define send_data_to_header 0b0
    const u32_t type;
    const ci_time_t time;
    const char *str;
} *send_data_t;

typedef void send_fn_t(send_data_t);

typedef struct struct_attach_ {
    send_fn_t *send_fn;
    const ci_time_t time;
    const u32_t type;// configurations on every bit
    const char *executable_path;
} *attach_data_t;

struct hHeaps
{
	HANDLE  heap;
	int flag;
};

extern "C" void ci_init(attach_data_t);

#endif //SOFTWARE_SECURITY_MAIN_H
