测试解析的例子()
{
  test=
  (
  QRESULT CALLBACK test(
    CONST BYTE abc,
    LPVOID lpBuffer,
    HANDLE *phFile,
    HANDLE hFile,
    _In_ int    nCode,
    [out] ULONG                       *pAlgCount,
    [out] BCRYPT_ALGORITHM_IDENTIFIER **ppAlgList
    [out]          BCRYPT_HASH_HANDLE *phHash,
    LPOVERLAPPED lpOverlapped
    [in, out]      BCRYPT_ALG_HANDLE  hAlgorithm,
    ...
    TEST ttt
  `);
  )

  GuiControl, , edit1, % test
}