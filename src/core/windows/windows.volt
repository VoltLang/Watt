// Copyright © 2013-2016, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
module core.windows.windows;
// As it stands, this module only has the bits of WIN32 that have been used.
// Pull requests to add more welcome.

import core.stdc.stdarg;


extern (Windows):

alias UINT = uint;
alias WORD = ushort;
alias DWORD = uint;
alias BOOL = int;
alias BYTE = u8;
alias LPBYTE = byte*;
alias PVOID = void*;
alias LPVOID = void*;
alias LPCVOID = const(void)*;
alias LPCSTR = const(char)*;
alias LPCWSTR = const(wchar)*;
alias LPBOOL = BOOL*;
alias LPSTR = char*;
alias LPWSTR = wchar*;
alias LPDWORD = DWORD*;
alias ULONG_PTR = size_t;
alias DWORD_PTR = ULONG_PTR;
alias HANDLE = PVOID;
alias PHANDLE = HANDLE*;
alias HINSTANCE = HANDLE;
alias HMODULE = HINSTANCE;
alias HDC = HANDLE;
alias HWND = HANDLE;
alias TCHAR = char;
alias LONG = i32;
alias LONG_PTR = LONG*;
alias UINT_PTR = UINT*;
alias WPARAM = UINT_PTR;
alias LPARAM = LONG_PTR;
alias LRESULT = LONG_PTR;
alias HICON = HANDLE;
alias HCURSOR = HICON;
alias HBRUSH = HANDLE;
alias ATOM = WORD;
alias HMENU = HANDLE;
alias PROC = void*;  // This is a guess.


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
HANDLE FindFirstFileW(LPCWSTR, LPWIN32_FIND_DATA);
BOOL FindNextFileA(HANDLE, LPWIN32_FIND_DATA);
BOOL FindNextFileW(HANDLE, LPWIN32_FIND_DATA);

DWORD GetCurrentDirectoryA(DWORD, LPSTR);
DWORD GetCurrentDirectoryW(DWORD, LPWSTR);
BOOL SetCurrentDirectoryA(LPCSTR);
BOOL SetCurrentDirectoryW(LPCWSTR);



enum GET_FILEEX_INFO_LEVELS
{
	GetFileExInfoStandard
}

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

DWORD GetFileAttributesA(LPCSTR);
DWORD GetFileAttributesW(LPCWSTR);
BOOL GetFileAttributesExA(LPCSTR, GET_FILEEX_INFO_LEVELS, LPVOID);
BOOL GetFileAttributesExW(LPCWSTR, GET_FILEEX_INFO_LEVELS, LPVOID);

DWORD GetFileSize(HANDLE, LPDWORD lpFileSizeHigh);


LPCSTR GetEnvironmentStringsA();
LPCWSTR GetEnvironmentStringsW();
BOOL FreeEnvironmentStringsA(LPCSTR);
BOOL FreeEnvironmentStringsW(LPCWSTR);


enum uint CP_UTF8 = 65001;

int MultiByteToWideChar(UINT CodePage, DWORD  dwFlags, LPCSTR lpMultiByteStr,
	int cbMultiByte, LPWSTR lpWideCharStr, int cchWideChar);
int WideCharToMultiByte(UINT CodePage, DWORD dwFlags, LPCWSTR lpWideCharStr,
	int cchWideChar, LPSTR lpMultiByteStr, int cbMultiByte,
	LPCSTR lpDefaultChar, LPBOOL lpUsedDefaultChar);

enum i32 CCHDEVICENAME = 32;
enum i32 CCHFORMNAME = 32;

struct POINTL
{
	x: LONG;
	y: LONG;
}
alias POINT = POINTL;
alias PPOINT = POINT*;
alias PPOINTL = POINTL*;

enum DWORD DM_BITSPERPEL = 0x00040000;
enum DWORD DM_PELSWIDTH  = 0x00080000;
enum DWORD DM_PELSHEIGHT = 0x00100000;

// TODO: In Windows 2000 and older, this structure is different.
struct _devicemode {
	dmDeviceName: TCHAR[32/*CCHDEVICENAME*/];
	dmSpecVersion: WORD;
	dmDriverVersion: WORD;
	dmSize: WORD;
	dmDriverExtra: WORD;
	dmFields: DWORD;

	union _u {
		struct _s {
			dmOrientation: i16;
			dmPaperSize: i16;
			dmPaperLength: i16;
			dmPaperWidth: i16;
			dmScale: i16;
			dmCopies: i16;
			dmDefaultSource: i16;
			dmPrintQuality: i16;
		}
		s: _s;
		struct _s2 {
			dmPosition: POINTL;
			dmDisplayOrientation: DWORD;
			dmDisplayFixedOutput: DWORD;
		}
		s2: _s2;
	}

	dmColor: i16;
	dmDuplex: i16;
	dmYResolution: i16;
	dmTTOption: i16;
	dmCollate: i16;
	dmFormName: TCHAR[32/*CCHFORMNAME*/];
	dmLogPixels: WORD;
	dmBitsPerPel: DWORD;
	dmPelsWidth: DWORD;
	dmPelsHeight: DWORD;
	union _u2 {
		dmDisplayFlags: DWORD;
		dmNup: DWORD;
	}
	u2: _u2;
	dmDisplayFrequency: DWORD;
	dmICMMethod: DWORD;
	dmICMIntent: DWORD;
	dmMediaType: DWORD;
	dmDitherType: DWORD;
	dmReserved1: DWORD;
	dmReserved2: DWORD;
	dmPanningWidth: DWORD;
	dmPanningHeight: DWORD;
}
alias DEVMODE = _devicemode;
alias PDEVMODE = _devicemode*;
alias LPDEVMODE = _devicemode*;

enum DWORD CDS_FULLSCREEN = 0x00000004;
enum LONG DISP_CHANGE_SUCCESSFUL = 0;

fn ChangeDisplaySettingsA(lpDevMode: DEVMODE*, dwFlags: DWORD) LONG;
fn ChangeDisplaySettingsW(lpDevMode: DEVMODE*, dwFlags: DWORD) LONG;

fn ShowCursor(bShow: BOOL) i32;

enum u32 MB_ABORTRETRYIGNORE = 0x2;
enum u32 MB_CANCELTRYCONTINUE = 0x6;
enum u32 MB_HELP = 0x4000;
enum u32 MB_OK = 0;
enum u32 MB_OKCANCEL = 0x1;
enum u32 MB_RETRYCANCEL = 0x5;
enum u32 MB_YESNO = 0x4;
enum u32 MB_YESNOCANCEL = 0x3;
enum u32 MB_ICONEXCLAMATION = 0x30;
enum u32 MB_ICONWARNING = 0x30;
enum u32 MB_ICONINFORMATION = 0x40;
enum u32 MB_ICONASTERISK = 0x40;
enum u32 MB_ICONQUESTION = 0x20;
enum u32 MB_ICONSTOP = 0x10;
enum u32 MB_ICONERROR = 0x10;
enum u32 MB_ICONHAND = 0x10;

enum i32 IDYES = 6;
enum i32 IDNO = 7;

fn MessageBoxA(hWnd: HWND, lpText: LPCSTR, lpCaptions: LPCSTR, uType: UINT) i32;
fn MessageBoxW(hWnd: HWND, lpText: LPWSTR, lpCaptions: LPWSTR, uType: UINT) i32;

fn ReleaseDC(hWnd: HWND, hDC: HDC) i32;

fn DestroyWindow(hWnd: HWND) BOOL;

fn UnregisterClassA(lpClassName: LPCSTR, hInstance: HINSTANCE) BOOL;
fn UnregisterClassW(lpClassName: LPWSTR, hInstance: HINSTANCE) BOOL;

alias WNDPROC = fn!Windows(HWND, UINT, WPARAM, LPARAM) LRESULT;

enum UINT CS_BYTEALIGNCLIENT = 0x00001000;
enum UINT CS_BYTEALIGNWINDOW = 0x00002000;
enum UINT CS_CLASSDC         = 0x00000040;
enum UINT CS_DBLCLK          = 0x00000008;
enum UINT CS_DROPSHADOW      = 0x00020000;
enum UINT CS_GLOBALCLASS     = 0x00004000;
enum UINT CS_HREDRAW         = 0x00000002;
enum UINT CS_NOCLOSE         = 0x00000200;
enum UINT CS_OWNDC           = 0x00000020;
enum UINT CS_PARENTDC        = 0x00000080;
enum UINT CS_SAVEBITS        = 0x00000800;
enum UINT CS_VREDRAW         = 0x00000001;

enum UINT WS_OVERLAPPED   = 0x00000000L;
enum UINT WS_CAPTION      = 0x00C00000L;
enum UINT WS_SYSMENU      = 0x00080000L;
enum UINT WS_THICKFRAME   = 0x00040000L;
enum UINT WS_MINIMIZEBOX  = 0x00020000L;
enum UINT WS_MAXIMIZEBOX  = 0x00010000L;
enum UINT WS_OVERLAPPEDWINDOW = 0x00CF0000;
enum UINT WS_POPUP        = 0x80000000L;
enum UINT WS_CLIPCHILDREN = 0x02000000L;
enum UINT WS_CLIPSIBLINGS = 0x04000000L;

enum UINT WS_EX_APPWINDOW = 0x00040000L;
enum UINT WS_EX_WINDOWEDGE = 0x00000100L;

struct WNDCLASSA
{
	style: UINT;
	lpfnWndProc: WNDPROC;
	cbClsExtra: i32;
	cbWndExtra: i32;
	hInstance: HINSTANCE;
	hIcon: HICON;
	hCursor: HCURSOR;
	hbrBackground: HBRUSH;
	lpszMenuName: LPCSTR;
	lpszClassName: LPCSTR;
}
alias PWNDCLASSA = WNDCLASSA*;

struct WNDCLASSW
{
	style: UINT;
	lpfnWndProc: WNDPROC;
	cbClsExtra: i32;
	cbWndExtra: i32;
	hInstance: HINSTANCE;
	hIcon: HICON;
	hCursor: HCURSOR;
	hbrBackground: HBRUSH;
	lpszMenuName: LPWSTR;
	lpszClassName: LPWSTR;
}
alias PWNDCLASSW = WNDCLASSW*;

struct RECT
{
	left: LONG;
	top: LONG;
	right: LONG;
	bottom: LONG;
}
alias PRECT = RECT*;

fn GetModuleHandleA(lpModuleName: LPCSTR) HMODULE;
fn GetModuleHandleW(lpModuleName: LPWSTR) HMODULE;

// C Win32 has a macro that casts to LPCSTR/LPWSTR as appropriate. We'll leave that to the user.
enum IDI_WINLOGO = 32517;

fn LoadIconA(hInstance: HINSTANCE, lpIconName: LPCSTR) HICON;
fn LoadIconW(hInstance: HINSTANCE, lpIconName: LPWSTR) HICON;

// C Win32 has a macro that casts to LPCSTR/LPWSTR as appropriate. We'll leave that to the user. 
enum IDC_ARROW = 32512;

fn LoadCursorA(hInstance: HINSTANCE, lpCursorName: LPCSTR) HCURSOR;
fn LoadCursorW(hInstance: HINSTANCE, lpCursorName: LPWSTR) HCURSOR;

fn RegisterClassA(lpWndClass: WNDCLASSA*) ATOM;
fn RegisterClassW(lpWndClass: WNDCLASSW*) ATOM;

fn AdjustWindowRectEx(lpRect: RECT*, dwStyle: DWORD, bMenu: BOOL, dwExStyle: DWORD) BOOL;

fn CreateWindowExA(DWORD, LPCSTR, LPCSTR, DWORD, i32, i32, i32, i32, HWND, HMENU, HINSTANCE, LPVOID) HWND;
fn CreateWindowExW(DWORD, LPWSTR, LPWSTR, DWORD, i32, i32, i32, i32, HWND, HMENU, HINSTANCE, LPVOID) HWND;

enum DWORD PFD_DRAW_TO_WINDOW = 0x00000004L;
enum DWORD PFD_SUPPORT_OPENGL = 0x00000020L;
enum DWORD PFD_DOUBLEBUFFER   = 0x00000001L;
enum BYTE PFD_TYPE_RGBA = 0;
enum DWORD PFD_MAIN_PLANE = 0;

struct PIXELFORMATDESCRIPTOR
{
	nSize: WORD;
	nVersion: WORD;
	dwFlags: DWORD;
	iPixelType: BYTE;
	cColorBits: BYTE;
	cRedBits: BYTE;
	cRedShift: BYTE;
	cGreenBits: BYTE;
	cGreenShift: BYTE;
	cBlueBits: BYTE;
	cBlueShift: BYTE;
	cAlphaBits: BYTE;
	cAlphaShift: BYTE;
	cAccumBits: BYTE;
	cAccumRedBits: BYTE;
	cAccumGreenBits: BYTE;
	cAccumBlueBits: BYTE;
	cAccumAlphaBits: BYTE;
	cDepthBits: BYTE;
	cStencilBits: BYTE;
	cAuxBuffers: BYTE;
	iLayerType: BYTE;
	bReserved: BYTE;
	dwLayerMask: DWORD;
	dwVisibleMask: DWORD;
	dwDamageMask: DWORD;
}
alias PPIXELFORMATDESCRIPTOR = PIXELFORMATDESCRIPTOR*;

fn GetDC(hWnd: HWND) HDC;

fn ChoosePixelFormat(hdc: HDC, ppfd: PIXELFORMATDESCRIPTOR*) i32;

fn SetPixelFormat(hdc: HDC, iPixelFormat: i32, ppfd: PIXELFORMATDESCRIPTOR*) BOOL;

enum SW_SHOW = 5;

fn ShowWindow(hWnd: HWND, nCmdShow: i32) BOOL;

fn SetForegroundWindow(hWnd: HWND) BOOL;

fn SetFocus(hWnd: HWND) HWND;

fn LOWORD(dw: DWORD) WORD
{
	return cast(WORD)dw;
}

fn HIWORD(dw: DWORD) WORD
{
	return cast(WORD)((cast(DWORD)dw >> 16) & 0xFFFF);
}

enum WM_ACTIVE = 1;
enum WM_SYSCOMMAND = 0x0112;
enum WM_CLOSE = 0x0010;
enum WM_KEYDOWN = 0x0100;
enum WM_KEYUP = 0x0101;
enum WM_SIZE = 0x0005;
enum WM_QUIT = 0x0012;

enum SC_SCREENSAVE = 0xF140;
enum SC_MONITORPOWER = 0xF170;

fn PostQuitMessage(nExitCode: i32);

fn DefWindowProcA(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM) LRESULT;

struct MSG
{
	hwnd: HWND;
	message: UINT;
	wParam: WPARAM;
	lParam: LPARAM;
	time: DWORD;
	pt: POINT;
}
alias PMSG = MSG*;
alias LPMSG = MSG*;

enum UINT PM_NOREMOVE = 0x0000;
enum UINT PM_REMOVE = 0x0001;
enum UINT PM_NOYIELD = 0x0002;

fn PeekMessageA(lpMsg: LPMSG, hWnd: HWND, wMsgFilterMin: UINT, wMsgFilterMax: UINT, wRemoveMsg: UINT) BOOL;
fn PeekMessageW(lpMsg: LPMSG, hWnd: HWND, wMsgFilterMin: UINT, wMsgFilterMax: UINT, wRemoveMsg: UINT) BOOL;

fn TranslateMessage(lpMsg: MSG*) BOOL;
fn DispatchMessageA(lpMsg: MSG*) LRESULT;
fn DispatchMessageW(lpMsg: MSG*) LRESULT;

fn SwapBuffers(HDC) BOOL;
