//
// Created by Xu on 9/16/22.
//

#include "lib.h"
#ifdef __APPLE__

#include <unistd.h>

#elif defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#define sleep(x) Sleep((x)*1000)
#endif

void init(attach_data_t attachData);

int exit_flag = 1;

void ci_init(attach_data_t attachData) {
    init(attachData);
}

#define STOP 1

void ci_stop(stop_data_t stopCode) {
    if(stopCode->code == STOP) {
        exit_flag = 0;
    }
}


#include<direct.h>
#include<cstdio>
#include<windows.h>
#include<E:\XHZ\Documents\Dev\Detours\include\detours.h>

void init(attach_data_t attachData) 	{
	wchar_t Exe[MAX_PATH],Dll[MAX_PATH];
					
	auto len = strlen(attachData->executable_path);

	mbstowcs(Exe,attachData->executable_path,len+1);//+1是\0

	STARTUPINFO si;
	PROCESS_INFORMATION pi;
	ZeroMemory(&si, sizeof(STARTUPINFO));
	ZeroMemory(&pi, sizeof(PROCESS_INFORMATION));

	si.cb = sizeof(STARTUPINFO);
	_wgetcwd(Dll,MAX_PATH);

	if (DetourCreateProcessWithDllEx(Exe, NULL, NULL, NULL, TRUE,
		CREATE_DEFAULT_ERROR_MODE | CREATE_SUSPENDED,
		NULL, Dll, &si, &pi, "DLLmainW.dll", NULL)){
		ResumeThread(pi.hThread);
        char buf[16];
        while (ReadFile(stdout,buf,16,NULL,NULL)){
            struct struct_send_ data{1,0, buf};
            attachData->send_fn(&data);
        }
		WaitForSingleObject(pi.hProcess, INFINITE);
	} else{
		wchar_t error[100];
		wsprintf(error, L"%d", GetLastError());
		MessageBox(NULL,error,L"NULL",NULL);
	}
}