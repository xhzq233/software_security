//
// Created by Xu on 9/16/22.
//

#include "lib.h"

typedef char *str;
typedef const str cstr;

#include <cstdio>
void default_send_fn(send_data_t sendData);

void default_send_fn(send_data_t sendData)
{
    printf_s("type=%d str=%s\n", sendData->type, sendData->str);
}

#ifdef __APPLE__

#include <unistd.h>
#include <ctime>
#include <chrono>

void ci_init(attach_data_t attachData)
{
    char h[100] = "im header: callback from backend";
    auto data_ = struct_send_{.type = send_data_to_header, .str = h};
    attachData->send_fn(&data_);
    int i = 1;
    while (1)
    {
        sleep(2);
        using namespace std::chrono;
        milliseconds ms = duration_cast<milliseconds>(system_clock::now().time_since_epoch());
        auto data = struct_send_{
            .type = (u32_t)((msg_box_t << (i % 6)) | (restrict_t << (i % 2))),
            .str = "im from apple",
        };
        ++i;
        attachData->send_fn(&data);
    }
}

#elif defined(_WIN32) || defined(_WIN64)
#define _CRT_SECURE_NO_WARNINGS
#undef UNICODE
#include <windows.h>
#undef UNICODE
#define sleep(x) Sleep((x)*1000)
#include <direct.h>
#include <cstdio>
#include <E:\\XHZ\\Documents\\Dev\\Detours\\include\\detours.h>
#include <iostream>
#include <unordered_set>
#include <shlwapi.h>
#pragma comment(lib, "Shlwapi.lib")
#pragma comment(lib, "E:\\XHZ\\Documents\\Dev\\Detours\\lib.X64\\detours.lib")
using namespace std;
#define _CRT_SECURE_NO_WARNINGS

void file_check(cstr file_path, send_fn_t fn); //检测文件操作异常行为
void getFolder(cstr path);                     //获取文件所在文件夹路径
void reg_check(send_fn_t fn);                  //注册表异常检测
void heap_check(send_fn_t fn);                 //堆异常检测

struct argument
{
    u32_t type;
    int argNum;                   //参数数量
    SYSTEMTIME st;                //时间
    char function_name[20] = {0}; //函数名称
    char arg_name[10][30] = {0};  //参数名称
    char value[10][150] = {0};    //参数内容
} arg;

unordered_set<string> folders; //创建容器，保存文件夹名称

void lyf(cstr file_path, cstr dir_path, cstr dll_path, send_fn_t fn, u32_t type)
{
    const int nBufferLen = 2000;
    char szBuffer[nBufferLen] = {0};
    HANDLE hPipe = NULL;
    DWORD dwReadLen = 0;
    DWORD dwWriteLen = 0;
    STARTUPINFO si;
    PROCESS_INFORMATION pi;
    //创建命名管道
    hPipe = CreateNamedPipe("\\\\.\\pipe\\Communication", PIPE_ACCESS_DUPLEX, PIPE_TYPE_MESSAGE | PIPE_READMODE_MESSAGE | PIPE_WAIT, 1, 0, 0, NMPWAIT_WAIT_FOREVER, 0);
    
    ZeroMemory(&si, sizeof(STARTUPINFO));
    ZeroMemory(&pi, sizeof(PROCESS_INFORMATION));
    si.cb = sizeof(STARTUPINFO);
    char send_buffer[512];
    if (DetourCreateProcessWithDllEx(file_path, NULL, NULL, NULL, TRUE, CREATE_DEFAULT_ERROR_MODE | CREATE_SUSPENDED, NULL, dir_path, &si, &pi, dll_path, NULL))
    {
        ResumeThread(pi.hThread);
        if (ConnectNamedPipe(hPipe, NULL) == NULL) {
            return;
        }
        //传输type
        WriteFile(hPipe, &type, sizeof(type), &dwReadLen, NULL);
        //读取管道数据
        while (ReadFile(hPipe, szBuffer, sizeof(argument), &dwReadLen, NULL))
        {
            memcpy(&arg, szBuffer, sizeof(argument));
            sprintf_s(send_buffer, "%s Hooked!", arg.function_name);
            struct_send_ send_data{arg.type, send_buffer};
            fn(&send_data);
            //打印参数信息
            for (int i = 0; i < arg.argNum; i++)
            {
                sprintf_s(send_buffer, "%s :%s", arg.arg_name[i], arg.value[i]);
                struct_send_ send_data{arg.type, send_buffer};
                fn(&send_data);
            }
            if (type & file_restrict_t)
                file_check(dll_path, fn);
            if (type & reg_restrict_t)
                reg_check(fn);
            if (type & heap_restrict_t)
                heap_check(fn);
        }
        DisconnectNamedPipe(hPipe);
        CloseHandle(hPipe);
        WaitForSingleObject(pi.hProcess, INFINITE);
    }
    else
    {
        char error[100];
        sprintf_s(error, "%d", GetLastError());
    }
}

//检测文件异常行为
void file_check(cstr file_path, send_fn_t fn)
{
    static int NumOfsend = 0; //记录一次CreateFile后send的执行次数
    static BOOL flag = TRUE;
    if (!strcmp(arg.function_name, "CopyFile"))
    {
        struct_send_ send_data{file_basic_t | restrict_t & restrict_t, "Warning! 可能有自我复制行为"};
        fn(&send_data);
        return;
    }
    if (!strcmp(arg.function_name, "CreateFile")) //是否为CreateFile函数
    {
        NumOfsend = 0;
        str file_name = PathFindFileNameA(file_path); //获取文件名称
        char folder[200];
        strcpy_s(folder, arg.value[0]);
        getFolder(folder); //获取文件夹名称
        //是否有自我复制
        if ((!strcmp(arg.value[1], "GENERIC_READ") || !strcmp(arg.value[1], "GENERIC_WRITE_READ")) && !strcmp(arg.value[0], file_name))
        {
            struct_send_ send_data{file_basic_t | restrict_t & restrict_t, "Warning! 可能有自我复制行为"};
            fn(&send_data);
        }
        //是否修改可执行文件
        if (!strcmp(arg.value[1], "GENERIC_WRITE") || !strcmp(arg.value[1], "GENERIC_WRITE_READ")) //有写访问权限
        {
            if (strstr(arg.value[0], ".exe") || strstr(arg.value[0], ".dll") || strstr(arg.value[0], ".ocx") || strstr(arg.value[0], ".bat"))
            {
                struct_send_ send_data{file_basic_t | restrict_t, "Warning! 可能修改可执行文件"};
                fn(&send_data);
            }
        }
        //是否修改系统文件
        if (!strcmp(arg.function_name, "GENERIC_WRITE") || !strcmp(arg.value[1], "GENERIC_WRITE_READ"))
        {
            if (strstr(arg.value[0], "C:\\Windows") || strstr(arg.value[0], "C:\\Users") || strstr(arg.value[0], "C:\\Program Files"))
            {
                struct_send_ send_data{file_basic_t | restrict_t, "Warning! 可能修改系统文件"};
                fn(&send_data);
            }
        }
        //操作范围是否多个文件夹
        if (folders.find(folder) == folders.end())
        {
            folders.emplace(folder);
        }
        if (folders.size() > 1 && flag)
        {
            struct_send_ send_data{file_basic_t | restrict_t, "Warning! 操作范围有多个文件夹"};
            fn(&send_data);
            flag = FALSE;
        }
        return;
    }
    //监测是否发送文件至网络
    if (!strcmp(arg.function_name, "send"))
    {
        NumOfsend++;
        if (NumOfsend >= 2)
        {
            struct_send_ send_data{file_basic_t | restrict_t, "Warning! 可能发送文件内容至网络"};
            fn(&send_data);
        }
    }
}

//检测堆操作异常行为
void heap_check(send_fn_t fn)
{
    if (!strcmp(arg.function_name, "HeapDestroy") && strcmp(arg.arg_name[arg.argNum], "ERROR"))
    {
        struct_send_ send_data{heap_basic_t | restrict_t, "ERROR! 重复销毁堆！"};
        fn(&send_data);
        return;
    }
    if (!strcmp(arg.function_name, "HeapFree") && strcmp(arg.arg_name[arg.argNum], "ERROR"))
    {
        struct_send_ send_data{heap_basic_t | restrict_t, "ERROR! 重复释放堆！"};
        fn(&send_data);
    }
}

//检测注册表异常行为
void reg_check(send_fn_t fn)
{
    char send_buffer[256];
    if (!strcmp(arg.arg_name[arg.argNum], "ERROR"))
    {
        sprintf_s(send_buffer, "%s! %s %s", arg.arg_name[arg.argNum], arg.value[arg.argNum], arg.value[0]);
        struct_send_ send_data{reg_basic_t | restrict_t, send_buffer};
        fn(&send_data);
        return;
    }
    if (!strcmp(arg.function_name, "RegCreateKeyEx"))
    {
        sprintf_s(send_buffer, "Warning! 新注册表项创建! %s", arg.value[0]);
        struct_send_ send_data{reg_basic_t | restrict_t, send_buffer};
        fn(&send_data);
        return;
    }
    if (!strcmp(arg.function_name, "RegDeleteTree"))
    {
        if (strstr(arg.value[0], "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run"))
        {
            struct_send_ send_data{reg_basic_t | restrict_t, "Warning! 正在尝试删除自启动项"};
            fn(&send_data);
            return;
        }
    }
    if (!strcmp(arg.function_name, "RegSetValue"))
    {
        if (strstr(arg.value[0], "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run"))
        {
            struct_send_ send_data{reg_basic_t | restrict_t, "Warning! 正在尝试修改自启动项默认键值"};
            fn(&send_data);
            return;
        }
    }
    if (!strcmp(arg.function_name, "RegSetValueEx"))
    {
        if (strstr(arg.value[0], "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run"))
        {
            struct_send_ send_data{reg_basic_t | restrict_t, "Warning! 正在尝试修改自启动项默认键值"};
            fn(&send_data);
            return;
        }
    }
    if (!strcmp(arg.function_name, "RegDeleteKey"))
    {
        if (strstr(arg.value[0], "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run"))
        {
            struct_send_ send_data{reg_basic_t | restrict_t, "Warning! 正在尝试删除自启动项!"};
            fn(&send_data);
            return;
        }
    }
    if (!strcmp(arg.function_name, "RegSetKeyValue"))
    {
        if (strstr(arg.value[0], "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run"))
        {
            struct_send_ send_data{reg_basic_t | restrict_t, "Warning! 正在尝试删除自启动项键值!"};
            fn(&send_data);
            return;
        }
    }
}

//获取文件夹名称
void getFolder(cstr path)
{
    if (strstr(path, "\\") != NULL)
    {
        auto length = strlen(path) / sizeof(char);
        while (path[length] != '\\')
            length--;
        memcpy(path + length, path + strlen(path) - 1, length + 1);
        path[length] = '\0';
    }
    else
        strcpy_s(path, strlen(arg.value[0]) + 1, arg.value[0]);
    return;
}

void ci_init(attach_data_t attachData)
{
    // freopen("log.txt", "w", stdout);
    char exe_path[MAX_PATH], dir_path[MAX_PATH], dll_path[MAX_PATH];
    int type = attachData->type;
    strcpy_s(exe_path, attachData->executable_path);
    _getcwd(dir_path, MAX_PATH);
    strcpy_s(dll_path, dir_path);
    strcat_s(dll_path, "\\lyf.dll");

    lyf(exe_path, dir_path, dll_path, attachData->send_fn, type);
}
#endif

int main()
{
    struct_attach_ attach{default_send_fn, 0, 0b11111111111, "E:\\XHZ\\Documents\\Dev\\software_security\\test\\test.exe"};
    ci_init(&attach);
}
