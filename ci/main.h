//
// Created by Xu on 9/16/22.
//

#ifndef SOFTWARE_SECURITY_MAIN_H
#define SOFTWARE_SECURITY_MAIN_H

typedef struct send_data_t {
    const char type;
    const char *str;
} *ffi_send_data;

typedef void send_fn_t(ffi_send_data);

void init(send_fn_t*);

#endif //SOFTWARE_SECURITY_MAIN_H
