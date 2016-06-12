// Copyright © 2013-2014, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module core.windows.windows;

import core.stdc.stdarg;


extern (Windows):

alias WORD = ushort;
alias DWORD = uint;
alias BOOL = int;
alias LPBYTE = byte*;
alias PVOID = void*;
alias LPVOID = void*;
alias LPCVOID = const(void)*;
alias LPCSTR = const(char)*;
alias LPCWSTR = const(wchar)*;
alias LPSTR = char*;
alias LPWSTR = wchar*;
alias LPDWORD = DWORD*;
alias ULONG_PTR = size_t;
alias DWORD_PTR = ULONG_PTR;
alias HANDLE = PVOID;
alias PHANDLE = HANDLE*;
alias HINSTANCE = HANDLE;
alias HMODULE = HINSTANCE;
alias TCHAR = char;

enum TRUE = 1;
enum FALSE = 0;
enum MAX_PATH = 260;
enum INVALID_HANDLE_VALUE = -1;

struct SECURITY_ATTRIBUTES
{
	DWORD nLength;
	LPVOID lpSecurityDescriptor;
	BOOL bInheritHandle;
}

alias PSECURITY_ATTRIBUTES = SECURITY_ATTRIBUTES*;
alias LPSECURITY_ATTRIBUTES = SECURITY_ATTRIBUTES*;

enum STARTF_USESTDHANDLES = 0x00000100;

struct STARTUPINFOA
{
	DWORD cb;
	LPSTR lpReserved;
	LPSTR lpDesktop;
	LPSTR lpTitle;
	DWORD dwX;
	DWORD dwY;
	DWORD dwXSize;
	DWORD dwYSize;
	DWORD dwXCountChars;
	DWORD dwYCountChars;
	DWORD dwFillFlags;
	DWORD dwFlags;
	WORD wShowWindow;
	WORD cbReserved2;
	LPBYTE lpReserved2;
	HANDLE hStdInput;
	HANDLE hStdOutput;
	HANDLE hStdError;
}

alias LPSTARTUPINFOA = STARTUPINFOA*;

struct STARTUPINFOW
{
	DWORD cb;
	LPWSTR lpReserved;
	LPWSTR lpDesktop;
	LPWSTR lpTitle;
	DWORD dwX;
	DWORD dwY;
	DWORD dwXSize;
	DWORD dwYSize;
	DWORD dwXCountChars;
	DWORD dwYCountChars;
	DWORD dwFillFlags;
	DWORD dwFlags;
	WORD wShowWindow;
	WORD cbReserved2;
	LPBYTE lpReserved2;
	HANDLE hStdInput;
	HANDLE hStdOutput;
	HANDLE hStdError;
}

alias LPSTARTUPINFOW = STARTUPINFOW*;

struct PROCESS_INFORMATION
{
	HANDLE hProcess;
	HANDLE hThread;
	DWORD dwProcessId;
	DWORD dwThreadId;
}

alias LPPROCESS_INFORMATION = PROCESS_INFORMATION*;

BOOL CreateDirectoryA(LPCSTR, LPSECURITY_ATTRIBUTES);
BOOL CreateDirectoryW(LPCWSTR, LPSECURITY_ATTRIBUTES);

DWORD GetLastError();

enum FORMAT_MESSAGE_ALLOCATE_BUFFER = 0x00000100;
enum FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000;

DWORD FormatMessageA(DWORD, LPCVOID, DWORD, DWORD, LPCSTR, DWORD, va_list*);
DWORD FormatMessageW(DWORD, LPCVOID, DWORD, DWORD, LPCWSTR, DWORD, va_list*);

BOOL CreateProcessA(LPCSTR, LPSTR, LPSECURITY_ATTRIBUTES, LPSECURITY_ATTRIBUTES, BOOL, DWORD, LPVOID, LPCSTR, LPSTARTUPINFOA, LPPROCESS_INFORMATION);
BOOL CreateProcessW(LPCWSTR, LPWSTR, LPSECURITY_ATTRIBUTES, LPSECURITY_ATTRIBUTES, BOOL, DWORD, LPVOID, LPCWSTR, LPSTARTUPINFOW, LPPROCESS_INFORMATION);

enum WAIT_OBJECT_0 = 0L;
@property DWORD INFINITE() { return cast(DWORD) 0xFFFFFFFF; }

DWORD WaitForSingleObject(HANDLE, DWORD);
DWORD WaitForMultipleObjects(DWORD, HANDLE*, BOOL, DWORD);
BOOL CloseHandle(HANDLE);
BOOL GetExitCodeProcess(HANDLE, LPDWORD);

enum HANDLE_FLAG_INHERIT = 0x00000001;
enum HANDLE_FLAG_PROTECT_FROM_CLOSE = 0x00000002;

BOOL GetHandleInformation(HANDLE, LPDWORD);
BOOL SetHandleInformation(HANDLE, DWORD, DWORD);

@property DWORD STD_INPUT_HANDLE() { return cast(DWORD) -10; }
@property DWORD STD_OUTPUT_HANDLE() { return cast(DWORD) -11; }
@property DWORD STD_ERROR_HANDLE() { return cast(DWORD) -12; }

HANDLE GetStdHandle(DWORD);

BOOL CreatePipe(PHANDLE, PHANDLE, LPSECURITY_ATTRIBUTES, DWORD);

struct OVERLAPPED
{
	private struct _s 
	{
		DWORD Offset;
		DWORD OffsetHigh;
	}
	ULONG_PTR Internal;
	ULONG_PTR InternalHigh;
	union _u 
	{
		_s s;
		PVOID Pointer;
	}
	_u u;
	HANDLE hEvent;
}

alias LPOVERLAPPED = OVERLAPPED*;

BOOL ReadFile(HANDLE, LPVOID, DWORD, LPDWORD, LPOVERLAPPED);

struct SYSTEM_INFO
{
	DWORD wReserved;
	DWORD dwPageSize;
	LPVOID lpMinimumApplicationAddress;
	LPVOID lpMaximumApplicationAddress;
	DWORD_PTR dwActiveProcessorMask;
	DWORD dwNumberOfProcessors;
	DWORD dwProcessorType;
	DWORD dwAllocationGranularity;
	WORD wProcessorLevel;
	WORD wProcessorRevision;
}

alias LPSYSTEM_INFO = SYSTEM_INFO*;

void GetSystemInfo(LPSYSTEM_INFO);

extern (C) int _fileno(void*);
extern (C) HANDLE _get_osfhandle(int);

void Sleep(DWORD);

struct FILETIME
{
	DWORD dwLowDateTime;
	DWORD dwHighDateTime;
}

alias PFILETIME = FILETIME*;

struct WIN32_FIND_DATA
{
	DWORD    dwFileAttributes;
	FILETIME ftCreationTime;
	FILETIME ftLastAccessTime;
	FILETIME ftLastWriteTime;
	DWORD    nFileSizeHigh;
	DWORD    nFileSizeLow;
	DWORD    dwReserved0;
	DWORD    dwReserved1;
	TCHAR[260]    cFileName;
	TCHAR[14]    cAlternateFileName;
}

alias LPWIN32_FIND_DATA = WIN32_FIND_DATA*;

enum ERROR_FILE_NOT_FOUND = 2;
enum ERROR_NO_MORE_FILES = 18;

HANDLE FindFirstFileA(LPCSTR, LPWIN32_FIND_DATA);
BOOL FindNextFileA(HANDLE, LPWIN32_FIND_DATA);

DWORD GetCurrentDirectoryA(DWORD, LPSTR);
BOOL SetCurrentDirectoryA(LPCSTR);


enum uint CP_UTF8 = 65001;

enum GET_FILEEX_INFO_LEVELS
{
	GetFileExInfoStandard
}

int MultiByteToWideChar(uint, DWORD, LPCSTR, int, LPWSTR, int);

struct WIN32_FILE_ATTRIBUTE_DATA
{
	DWORD    dwFileAttributes;
	FILETIME ftCreationTime;
	FILETIME ftLastAccessTime;
	FILETIME ftLastWriteTime;
	DWORD    nFileSizeHigh;
	DWORD    nFileSizeLow;
}

alias LPWIN32_FILE_ATTRIBUTE_DATA = WIN32_FILE_ATTRIBUTE_DATA*;

enum DWORD FILE_ATTRIBUTE_DIRECTORY = 0x10;
enum INVALID_FILE_ATTRIBUTES = cast(DWORD)-1;

BOOL GetFileAttributesExW(LPCWSTR, GET_FILEEX_INFO_LEVELS, LPVOID);
DWORD GetFileAttributesA(LPCSTR);
