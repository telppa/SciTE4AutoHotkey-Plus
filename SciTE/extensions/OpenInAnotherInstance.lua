dofile(props['SciteDefaultHome'].."/extensions/ahk.lua")

-- 只读模式下屏蔽保存功能，避免保存只读窗口的内容对主窗口造成混乱
function OnBeforeSave(path)
	return true
end