module core.windows.windows;

import core.stdc.stdarg;

extern (Windows):

alias DWORD = uint;
alias BOOL = int;
alias LPVOID = void*;
alias LPCVOID = const(void)*;
alias LPCSTR = const(char)*;
alias LPCWSTR = const(wchar)*;

struct SECURITY_ATTRIBUTES
{
	DWORD nLength;
	LPVOID lpSecurityDescriptor;
	BOOL bInheritHandle;
}

alias PSECURITY_ATTRIBUTES = SECURITY_ATTRIBUTES*;
alias LPSECURITY_ATTRIBUTES = SECURITY_ATTRIBUTES*;

BOOL CreateDirectoryA(LPCSTR, LPSECURITY_ATTRIBUTES);
BOOL CreateDirectoryW(LPCWSTR, LPSECURITY_ATTRIBUTES);

DWORD GetLastError();

enum FORMAT_MESSAGE_ALLOCATE_BUFFER = 0x00000100;
enum FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000;

DWORD FormatMessageA(DWORD, LPCVOID, DWORD, DWORD, LPCSTR, DWORD, va_list*);
DWORD FormatMessageW(DWORD, LPCVOID, DWORD, DWORD, LPCWSTR, DWORD, va_list*);
