-- 菜单栏 - 选项 - 打开 用户缩略语定义文件 指向的路径不对，所以用这个函数做修正
function OpenUserAhkAbbrevsFile()
	local SciteUserHome = props["SciteUserHome"]
	local user_ahk_abbrevs_path = SciteUserHome.."/user.ahk.abbrevs.properties"
	scite.Open(user_ahk_abbrevs_path)
end