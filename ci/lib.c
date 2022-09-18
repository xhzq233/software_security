//
// Created by Xu on 9/16/22.
//

#include "lib.h"

int exit_flag = 1;

void ci_init(attach_data_t attachData) {
    const char *a[] = {
            "雪豹闭嘴",
            "何为猫雷",
            "猫雷とは何ですか",
            "监测到xxx调用危险函数",
            "监测到xxx弹出窗口",
            "我测你们码",
            "监测到xxx上传信息, url=xxx",
    };
    const char b[] = {
            1, 1, 2, 2, 1
    };
    int i = 0;
    while (1) {
        if (exit_flag == 0) return;
        sleep(b[i % 5]);
        struct struct_send_ data = {.type = b[i % 5], .str = a[i % 7], .time = 0L};
        i++;
        attachData->send_fn(&data);
    }
}

#define STOP 1

void ci_stop(stop_data_t stopCode) {
    if(stopCode->code == STOP) {
        exit_flag = 0;
    }
}
