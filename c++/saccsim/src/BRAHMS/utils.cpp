#include "utils.h"

#include <ctime>

#ifdef __linux__
#	include <sys/time.h>
#	include <stdio.h>
#	include <unistd.h>
#else
#	include <Windows.h>
#endif

using namespace std;

double getSeconds()
{
#ifdef __linux__
    struct timeval t;
    gettimeofday(&t, NULL);
    return (double) t.tv_sec + (double) t.tv_usec/1000000.0;
#else
    return (double) GetTickCount() / 1000.0;
#endif
}

double elapsed(double startTime) 
{
    return 1.e3* ((double) (clock() - startTime)) / CLOCKS_PER_SEC;
}

string getExePath()
{
#ifdef __linux__
    std::string path = "";
    pid_t pid = getpid();
    char buf[20] = {0};
    sprintf(buf,"%d",pid);
    std::string _link = "/proc/";
    _link.append( buf );
    _link.append( "/exe");
    char proc[512];
    int ch = readlink(_link.c_str(),proc,512);
    if (ch != -1) {
        proc[ch] = 0;
        path = proc;
        std::string::size_type t = path.find_last_of("/");
        path = path.substr(0,t);
    }

    return path + string("/");

#else
    HMODULE hModule = GetModuleHandleW(NULL);
    WCHAR wPath[MAX_PATH];
    GetModuleFileNameW(hModule, wPath, MAX_PATH);
    char cPath[MAX_PATH];
    char DefChar = ' ';
    WideCharToMultiByte(CP_ACP, 0, wPath, -1, cPath, 260, &DefChar, NULL);
    string sPath(cPath);
    return sPath.substr(0, sPath.find_last_of("\\/")).append("\\");
#endif
}

string getBasePath()
{
#ifdef __APPLE__
    return getExePath() + "../../../../../";
#else
    return getExePath() + "../../";
#endif
}
