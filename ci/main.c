//
// Created by Xu on 9/16/22.
//

#include "main.h"
#include <unistd.h>

void init(send_fn_t *fn) {
    const char *a[] = {
            "雪豹闭嘴",
            "何为猫雷",
            "猫雷とは何ですか",
            "监测到xxx来了",
            "我测你们码",
            "xxx闭嘴",
    };
    const char b[] = {
            1, 1, 2
    };
    int i = 0;
    while (1) {
        sleep(1);
        struct send_data_t data = {.type = b[i % 3], .str = a[i % 6]};
        i++;
        fn(&data);
    }
}

