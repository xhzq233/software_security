//
// Created by Xu on 9/16/22.
//

#include "lib.h"

int exit_flag = 0;

#ifdef __APPLE__

#include <unistd.h>
#include <ctime>
#include <cstring>

void *init(void *pVoid)
{
    auto attachData = (attach_data_t)pVoid;
    exit_flag = LIB_START_SIG;
    char h[100] = "callback from backend, path:";
    strcat(h, attachData->executable_path);
    auto data_ = struct_send_{.type = 0, .str = h};
    attachData->send_fn(&data_);
    while (1)
    {
        if (exit_flag == LIB_STOP_SIG)
            return nullptr;
        sleep(2);
        auto data = struct_send_{
            .type = 1,
            .time = time(nullptr),
            .str = "im from apple",
        };
        attachData->send_fn(&data);
    }
}

#elif defined(_WIN32) || defined(_WIN64)
#define _CRT_SECURE_NO_WARNINGS
#include <windows.h>
#define sleep(x) Sleep((x)*1000)
#define UNICODE
#include <direct.h>
#include <cstdio>
#include <E:\XHZ\Documents\Dev\Detours\include\detours.h>
#include <iostream>
#include <unordered_set>
#include <shlwapi.h>
#pragma comment(lib, "Shlwapi.lib")
#pragma comment(lib, "detours.lib")
using namespace std;

void get_err()
{
    wchar_t error[100];
    wsprintf(error, L"%d", GetLastError());
    MessageBox(NULL, error, L"error", NULL);
}

// void lpx(const wchar_t *exe_path, const wchar_t *dir_path)
// {
//     STARTUPINFO si;
//     PROCESS_INFORMATION pi;
//     ZeroMemory(&si, sizeof(STARTUPINFO));
//     ZeroMemory(&pi, sizeof(PROCESS_INFORMATION));

//     si.cb = sizeof(STARTUPINFO);
//     _getcwd(dll_path, MAX_PATH);
//     strcat(dll_path, "\\DLLmainW.dll");

//     if (DetourCreateProcessWithDllEx(
//             exe_path,
//             NULL,
//             NULL,
//             NULL,
//             TRUE,
//             CREATE_DEFAULT_ERROR_MODE | CREATE_SUSPENDED,
//             NULL,
//             dir_path,
//             &si,
//             &pi,
//             dll_path,
//             NULL))
//     {
//         ResumeThread(pi.hThread);
//         char buf[16];
//         while (ReadFile(stdout, buf, 16, NULL, NULL))
//         {
//             struct struct_send_ data
//             {
//                 1, 0, buf
//             };
//             attachData->send_fn(&data);
//             mbstowcs(dir_path, buf, strlen(buf) + 1); //+1是\0
//             MessageBox(NULL, dir_path, L"ReadFile data", NULL);
//         }
//         get_err();
//         WaitForSingleObject(pi.hProcess, INFINITE);
//     }
//     else
//     {
//         wchar_t error[100];
//         wsprintf(error, L"%d", GetLastError());
//         mbstowcs(dir_path, dll_path, strlen(dll_path) + 1); //+1是\0
//         MessageBox(NULL, dir_path, error, NULL);
//     }
// }

void file_check(const wchar_t *file_path); //检测文件操作异常行为
void getFolder(char *path);                //获取文件所在文件夹路径

struct argument
{
    int argNum;                   //参数数量
    SYSTEMTIME st;                //时间
    char function_name[20] = {0}; //函数名称
    char arg_name[10][30] = {0};  //参数名称
    char value[10][150] = {0};    //参数内容
} arg;

unordered_set<string> folders; //创建容器，保存文件夹名称

// HANDLE hMapFile = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, sizeof(argument), L"share");
// LPVOID lp = MapViewOfFile(hMapFile, FILE_ALL_ACCESS, 0, 0, 0);//创建共享内存(弃用，改用管道传输）
ci_time_t systemtime_to_time_t(const SYSTEMTIME &st)
{
    struct tm gm = {st.wSecond, st.wMinute, st.wHour, st.wDay, st.wMonth - 1, st.wYear - 1900, st.wDayOfWeek, 0, 0};
    return mktime(&gm);
}

int lyf(const wchar_t *file_path, const wchar_t *dir_path, const send_fn_t fn)
{

    const int nBufferLen = 2000;
    char szBuffer[nBufferLen] = {0};
    SECURITY_ATTRIBUTES sa;
    HANDLE hRead = NULL;
    HANDLE hWrite = NULL;
    STARTUPINFO si;
    PROCESS_INFORMATION pi;
    DWORD dwReadLen = 0;
    BOOL bRet = FALSE;

    //创建匿名管道
    sa.bInheritHandle = TRUE;
    sa.lpSecurityDescriptor = NULL;
    sa.nLength = sizeof(SECURITY_ATTRIBUTES);
    bRet = ::CreatePipe(&hRead, &hWrite, &sa, 0);
    if (!bRet)
    {
        cout << "创建匿名管道失败!" << endl;
        system("pause");
        return -1;
    }

    ZeroMemory(&si, sizeof(STARTUPINFO));
    ZeroMemory(&pi, sizeof(PROCESS_INFORMATION));
    si.cb = sizeof(STARTUPINFO);
    si.dwFlags = STARTF_USESTDHANDLES;
    si.hStdInput = hRead;
    si.hStdOutput = hWrite;
    si.hStdError = GetStdHandle(STD_ERROR_HANDLE);
    char dll_path[MAX_PATH]; // dll路径
    _getcwd(dll_path, MAX_PATH);
    strcat(dll_path, "\\lyf.dll");

    char send_buffer[512];
    if (DetourCreateProcessWithDllEx(file_path, NULL, NULL, NULL, TRUE, CREATE_DEFAULT_ERROR_MODE | CREATE_SUSPENDED, NULL, dir_path, &si, &pi, dll_path, NULL))
    {

        ResumeThread(pi.hThread);
        CloseHandle(pi.hProcess);
        CloseHandle(pi.hThread);
        //读取管道数据
        while (bRet = ::ReadFile(hRead, szBuffer, sizeof(argument), &dwReadLen, NULL))
        {
            if (!bRet)
            {
                cout << "读取数据失败!" << endl;
                system("pause");
                return -1;
            }
            memcpy(&arg, szBuffer, sizeof(argument));
            printf("\n\n**********************************\n");
            printf("%s Hooked!\n", arg.function_name);
            printf("DLL日志输出: %d-%d-%d %02d:%02d:%02d:%03d\n", arg.st.wYear, arg.st.wMonth, arg.st.wDay, arg.st.wHour, arg.st.wMinute, arg.st.wSecond, arg.st.wMilliseconds);

            for (int i = 0; i < arg.argNum; i++)
            {
                sprintf(send_buffer, "%s :%s", arg.arg_name[i], arg.value[i]);
                struct_send_ send_data{1, systemtime_to_time_t(arg.st), send_buffer};
                fn(&send_data);
            }
            file_check(file_path);
            printf("**********************************\n\n");
            /*std::cout << "从子进程接收到数据: " << arg.function_name << endl;*/
        }

        WaitForSingleObject(pi.hProcess, INFINITE);
    }
    else
    {
        char error[100];
        sprintf_s(error, "%d", GetLastError());
    }

    return 0;
}

//检测文件异常行为
void file_check(const wchar_t *file_path)
{
    static int NumOfsend = 0; //记录一次CreateFile后send的执行次数
    // CreateFile异常行为
    if (!strcmp(arg.function_name, "CreateFile")) //是否为CreateFile函数
    {
        NumOfsend = 0;
        //获取文件名称
        LPWSTR file_name = PathFindFileNameW(file_path);
        int num = WideCharToMultiByte(CP_OEMCP, NULL, file_name, -1, NULL, 0, NULL, FALSE);
        LPSTR pchar = new char[num];
        WideCharToMultiByte(CP_OEMCP, NULL, file_name, -1, pchar, num, NULL, FALSE);
        //获取文件夹名称
        char folder[200];
        strcpy_s(folder, arg.value[0]);
        getFolder(folder);
        //是否有自我复制
        if ((!strcmp(arg.value[1], "80000000") || !strcmp(arg.value[1], "C0000000")) && !strcmp(arg.value[0], pchar))
            printf("可能有自我复制行为\n");
        //是否修改可执行文件
        if (!strcmp(arg.value[1], "40000000") || !strcmp(arg.value[1], "C0000000")) //有写访问权限
        {
            if (strstr(arg.value[0], ".exe") || strstr(arg.value[0], ".dll") || strstr(arg.value[0], ".ocx") || strstr(arg.value[0], ".bat"))
                printf("可能有可执行文件被修改\n");
        }
        //是否修改系统文件
        if (!strcmp(arg.function_name, "40000000") || !strcmp(arg.value[1], "C0000000"))
        {
            if (strstr(arg.value[0], "C:\\Windows") || strstr(arg.value[0], "C:\\Users") || strstr(arg.value[0], "C:\\Program Files"))
                printf("可能有系统文件被修改\n");
        }
        //操作范围是否多个文件夹
        if (folders.find(folder) == folders.end())
        {
            folders.emplace(folder);
        }
        if (folders.size() > 1)
            printf("操作范围有多个文件夹\n");
    }
    //监测是否发送文件至网络
    if (!strcmp(arg.function_name, "send"))
    {
        NumOfsend++;
        if (NumOfsend >= 2)
            printf("文件内容可能被发送至网络\n");
    }
}

//获取文件夹名称
void getFolder(char *path)
{
    if (strstr(path, "\\") != NULL)
    {
        int length = strlen(path) / sizeof(char);
        while (path[length] != '\\')
            length--;
        memcpy(path + length, path + strlen(path) - 1, length + 1);
        path[length] = '\0';
    }
    else
        strcpy_s(path, strlen(arg.value[0]) + 1, arg.value[0]);
    return;
}

void init(attach_data_t attachData)
{
    wchar_t exe_path[MAX_PATH], dir_path[MAX_PATH];
    char dll_path[MAX_PATH];

    auto len = strlen(attachData->executable_path);

    mbstowcs(exe_path, attachData->executable_path, len + 1); //+1是\0

    _wgetcwd(dir_path, MAX_PATH);

    lyf(exe_path, dir_path, attachData->send_fn);
}
#endif

void ci_init(attach_data_t attachData)
{
    freopen("out.txt", "w", stdout);
    init(attachData);
}

void ci_stop(stop_data_t stopCode)
{
    exit_flag = stopCode->code;
}