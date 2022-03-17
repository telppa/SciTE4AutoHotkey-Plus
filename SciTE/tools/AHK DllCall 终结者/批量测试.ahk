FileRead, ahkType, type.json
ahkType := createAhkTypeFromJson(ahkType)

a1=
(
int MessageBox(
  HWND hWnd, 
  LPCTSTR lpText, 
  LPCTSTR lpCaption, 
  UINT uType
`); 
)

a2=
(
BOOL SystemParametersInfo ( 
UINT uiAction, 
UINT uiParam, 
PVOID pvParam, 
UINT fWinIni);
)

a3=
(
BOOL IsWindowVisible(
  [in] HWND hWnd
`);
)

a4=
(
int wsprintf(
  LPTSTR lpOut,
  LPCTSTR lpFmt,
  ...
`);
)

a5=
(
BOOL QueryPerformanceFrequency(
  [out] LARGE_INTEGER *lpFrequency
`);
)

a6=
(
BOOL QueryPerformanceCounter(
  [out] LARGE_INTEGER *lpPerformanceCount
`);
)

a7=
(
int GetScrollPos(
  [in] HWND hWnd,
  [in] int  nBar
`);
)

a8=
(
BOOL GetScrollInfo(
  [in]      HWND         hwnd,
  [in]      int          nBar,
  [in, out] LPSCROLLINFO lpsi
`);
)

a9=
(
HANDLE CreateFile(
  LPCTSTR lpFileName,
  DWORD dwDesiredAccess,
  DWORD dwShareMode,
  LPSECURITY_ATTRIBUTES lpSecurityAttributes,
  DWORD dwCreationDisposition,
  DWORD dwFlagsAndAttributes,
  HANDLE hTemplateFile
`);
)

a10=
(
BOOL WriteFile( 
  HANDLE hFile, 
  LPCVOID lpBuffer, 
  DWORD nNumberOfBytesToWrite, 
  LPDWORD lpNumberOfBytesWritten, 
  LPOVERLAPPED lpOverlapped
`); 
)

a11=
(
BOOL CloseHandle(
  HANDLE hObject
`);
)

a12=
(
BOOL ReadFile(
  HANDLE hFile,
  LPVOID lpBuffer,
  DWORD nNumberOfBytesToRead,
  LPDWORD lpNumberOfBytesRead,
  LPOVERLAPPED lpOverlapped
`);
)

a13=
(
HCURSOR LoadCursor ( 
HINSTANCE hInstance, 
LPCTSTR lpCursorName);
)

a14=
(
HANDLE CopyImage(
  [in] HANDLE h,
  [in] UINT   type,
  [in] int    cx,
  [in] int    cy,
  [in] UINT   flags
`);
)

a15=
(
HCURSOR CreateCursor(
  [in, optional] HINSTANCE  hInst,
  [in]           int        xHotSpot,
  [in]           int        yHotSpot,
  [in]           int        nWidth,
  [in]           int        nHeight,
  [in]           const VOID *pvANDPlane,
  [in]           const VOID *pvXORPlane
`);
)

a16=
(
BOOL SetSystemCursor(
  [in] HCURSOR hcur,
  [in] DWORD   id
`);
)

a17=
(
BOOL GetWindowRect(
  [in]  HWND   hWnd,
  [out] LPRECT lpRect
`);
)

a18=
(
HDC GetDC(
  [in] HWND hWnd
`);
)

a19=
(
HBRUSH CreateSolidBrush(
  [in] COLORREF color
`);
)

a20=
(
int FillRect(
  [in] HDC        hDC,
  [in] const RECT *lprc,
  [in] HBRUSH     hbr
`);
)

a21=
(
int ReleaseDC(
  [in] HWND hWnd,
  [in] HDC  hDC
`);
)

a22=
(
BOOL DeleteObject(
  [in] HGDIOBJ ho
`);
)

a23=
(
BOOL SetSystemTime(
  [in] const SYSTEMTIME *lpSystemTime
`);
)

a24=
(
NTSTATUS BCryptCreateHash(
  [in, out]      BCRYPT_ALG_HANDLE  hAlgorithm,
  [out]          BCRYPT_HASH_HANDLE *phHash,
  [out]          PUCHAR             pbHashObject,
  [in, optional] ULONG              cbHashObject,
  [in, optional] PUCHAR             pbSecret,
  [in]           ULONG              cbSecret,
  [in]           ULONG              dwFlags
`);
)

a25=
(
NTSTATUS BCryptEnumAlgorithms(
  [in]  ULONG                       dwAlgOperations,
  [out] ULONG                       *pAlgCount,
  [out] BCRYPT_ALGORITHM_IDENTIFIER **ppAlgList,
  [in]  ULONG                       dwFlags
`);
)

a26=
(
NTSTATUS BCryptOpenAlgorithmProvider(
  [out] BCRYPT_ALG_HANDLE *phAlgorithm,
  [in]  LPCWSTR           pszAlgId,
  [in]  LPCWSTR           pszImplementation,
  [in]  ULONG             dwFlags
`);
)

a27=
(
LPTSTR CharLower(
  LPTSTR lpsz
`);
)

a28=
(
BOOL CreateProcessA(
  [in, optional]      LPCSTR                lpApplicationName,
  [in, out, optional] LPSTR                 lpCommandLine,
  [in, optional]      LPSECURITY_ATTRIBUTES lpProcessAttributes,
  [in, optional]      LPSECURITY_ATTRIBUTES lpThreadAttributes,
  [in]                BOOL                  bInheritHandles,
  [in]                DWORD                 dwCreationFlags,
  [in, optional]      LPVOID                lpEnvironment,
  [in, optional]      LPCSTR                lpCurrentDirectory,
  [in]                LPSTARTUPINFOA        lpStartupInfo,
  [out]               LPPROCESS_INFORMATION lpProcessInformation
`);
)

a29=
(
HANDLE OpenProcess(
  [in] DWORD dwDesiredAccess,
  [in] BOOL  bInheritHandle,
  [in] DWORD dwProcessId
`);
)

a30=
(
BOOL OpenProcessToken(
  [in]  HANDLE  ProcessHandle,
  [in]  DWORD   DesiredAccess,
  [out] PHANDLE TokenHandle
`);
)

a31=
(
BOOL LookupPrivilegeValueA(
  [in, optional] LPCSTR lpSystemName,
  [in]           LPCSTR lpName,
  [out]          PLUID  lpLuid
`);
)

a32=
(
BOOL AdjustTokenPrivileges(
  [in]            HANDLE            TokenHandle,
  [in]            BOOL              DisableAllPrivileges,
  [in, optional]  PTOKEN_PRIVILEGES NewState,
  [in]            DWORD             BufferLength,
  [out, optional] PTOKEN_PRIVILEGES PreviousState,
  [out, optional] PDWORD            ReturnLength
`);
)

a33=
(
BOOL EnumProcesses(
  [out] DWORD   *lpidProcess,
  [in]  DWORD   cb,
  [out] LPDWORD lpcbNeeded
`);
)

a34=
(
DWORD GetModuleBaseNameA(
  [in]           HANDLE  hProcess,
  [in, optional] HMODULE hModule,
  [out]          LPSTR   lpBaseName,
  [in]           DWORD   nSize
`);
)

a35=
(
DWORD GetProcessImageFileNameA(
  [in]  HANDLE hProcess,
  [out] LPSTR  lpImageFileName,
  [in]  DWORD  nSize
`);
)

a36=
(
HHOOK SetWindowsHookExA(
  [in] int       idHook,
  [in] HOOKPROC  lpfn,
  [in] HINSTANCE hmod,
  [in] DWORD     dwThreadId
`);
)

a37=
(
BOOL UnhookWindowsHookEx(
  [in] HHOOK hhk
`);
)

a38=
(
HMODULE GetModuleHandleA(
  [in, optional] LPCSTR lpModuleName
`);
)

a39=
(
LRESULT CALLBACK LowLevelMouseProc(
  _In_ int    nCode,
  _In_ WPARAM wParam,
  _In_ LPARAM lParam
`);
)

a40=
(
LPSTR GetCommandLineA();
)

loop, 40
  out.=createDllCallTemplate(a%A_Index%, "", ahkType, false, true, true, true) "`r`n`r`n"

FileDelete, 批量测试结果.txt
FileAppend, % out, 批量测试结果.txt
ExitApp

#Include AHK DllCall 终结者.ahk