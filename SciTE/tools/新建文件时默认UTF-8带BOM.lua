-- sunwind（1576157）搜集整理
-- event OnClear 完美解决新建文件时默认的文件编码

local oldOnClear = OnClear
function OnClear()
  if oldOnClear ~= nil then
    if oldOnClear() then
      return true
    end
  end
  if props['FileName'] == "" then
--  新建时默认采用UTF-8带BOM编码方式
    scite.MenuCommand(IDM_ENCODING_UTF8)
--  新建时默认采用UTF-8无BOM编码方式
--  scite.MenuCommand(IDM_ENCODING_UCOOKIE)
  end
  return false
end