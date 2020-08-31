#NoEnv
#Warn
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

BCM_SETSHIELD := 0x160C

Menu Tray, Icon, shell32.dll, 4

Try {
    Gui Add, % "Tab3", x6 y7 w608 h401, Permissions|Auditing|Owner|Effective Permissions
} Catch {
    Gui Add, Tab2, x6 y7 w608 h401, Permissions|Auditing|Owner|Effective Permissions
}
    Gui Add, Text, x21 y40 w579 h13, To view details of a permission entry`, double-click the entry. To modify permissions`, click Change Permissions.
    Gui Add, Text, x21 y76 w84 h13, Object name:
    Gui Add, Text, x109 y76 w495 h13, C:\Windows\System32
    Gui Add, Text, x21 y104 w579 h13, Permission en&tries:
    Gui Add, ListView, x21 y123 w579 h172 +LV0x4000, Type|Name|Permission|Inherited From|Apply To
        LV_Add("Select", "Allow", "TrustedInstaller", "Special", "<not inherited>", "This folder and subfolders")
        LV_Add("", "Allow", "SYSTEM", "Special", "<not inherited>", "This folder only")
        LV_Add("", "Allow", "SYSTEM", "Special", "<not inherited>", "Subfolders and files only")
        LV_Add("", "Allow", "Administrators (NASA\Administrators)", "Special", "<not inherited>", "This folder only")
        LV_Add("", "Allow", "Administrators (NASA\Administrators)", "Special", "<not inherited>", "Subfolders and files only")
        LV_Add("", "Allow", "Users (NASA\Users)", "Read & execute", "<not inherited>", "This folder, subfolders and files")
        LV_Add("", "Allow", "CREATOR OWNER", "Special", "<not inherited>", "Subfolders and files only")
        LV_ModifyCOl(1, 60)
        LV_ModifyCOl(2, 147)
        LV_ModifyCOl(3, 110)
        LV_ModifyCOl(4, 110)
        LV_ModifyCOl(5, 147)
    Gui Add, Button, hWndhPermBtn x21 y307 w131 h23, &Change Permissions...
    SendMessage BCM_SETSHIELD, 0, 1,, ahk_id%hPermBtn%
    Gui Add, Checkbox, x21 y344 w579 h13 Disabled, &Include inheritable permissions from this object's parent
    Gui Add, Link, x22 y380 w500 h23, <a>Manage permissions entries</a>

Gui Tab, 2
    Gui Add, Text, x21 y40 w84 h13, Object name:
    Gui Add, Text, x109 y40 w495 h13, C:\Windows\System32
    Gui Add, Picture, x21 y84 w16 h16 Icon222, shell32.dll
    Gui Add, Text, x42 y84 w540 h52, To continue`, you must be an administrative user with privileges to view this object's auditing properties.`n`nDo you want to continue?
    Gui Add, Button, hWndhContinueBtn x42 y137 w93 h23, &Continue
    SendMessage BCM_SETSHIELD, 0, 1,, ahk_id%hContinueBtn%
    Gui Add, Link, x22 y380 w500 h23, <a>Learn about control and permissions</a>
    
Gui Tab, 3
    Gui Add, Text, x21 y40 w579 h26, You can take or assign ownership of this object if you have the required permissions or privileges.
    Gui Add, Text, x21 y89 w84 h13, Object name:
    Gui Add, Text, x109 y89 w495 h13, C:\Windows\System32
    Gui Add, Text, x21 y117 w579 h13, &Current owner:
    Gui Add, Edit, x21 y136 w579 h21, TrustedInstaller
    Gui Add, Text, x21 y169 w579 h13, Change &owner to:
    Gui Add, ListView, x21 y188 w579 h138 Disabled, Name
        ImgLst := IL_Create(1)
        IL_Add(ImgLst, "comres.dll", 2)
        LV_SetImageList(ImgLst) 
        LV_Add("Icon1", "Alguimist (NASA\Alguimist)")
    Gui Add, Button, hWndhEditBtn x21 y337 w93 h23, &Edit...
    SendMessage BCM_SETSHIELD, 0, 1,, ahk_id%hEditBtn%
    Gui Add, Link, x22 y380 w500 h23, <a>Learn about object ownership</a>

Gui Tab, 4
    Gui Add, Text, x21 y40 w579 h39, The following list displays the permissions that would be granted to the selected group or user`, based solely on the permissions granted directly through group membership.
    Gui Add, Text, x21 y102 w84 h13, Object name:
    Gui Add, Text, x109 y102 w495 h13, C:\Windows\System32
    Gui Add, Text, x21 y130 w579 h13, &Group or user name:
    Gui Add, Edit, x21 y149 w503 h21
    Gui Add, Button, x532 y148 w68 h23, &Select...
    Gui Add, Text, x21 y177 w579 h13, &Effective permissions:
    Gui Add, ListView, x21 y196 w579 h153 -Hdr Checked, Permissions
        LV_ModifyCol(1, 555)
        LV_Add("", "Full control")
        LV_Add("", "Traverse folder / execute file")
        LV_Add("", "List folder / read data")
        LV_Add("", "Read attributes")
        LV_Add("", "Read extended attributes")
        LV_Add("", "Create files / write data")
        LV_Add("", "Create folders / append data")
        LV_Add("", "Write attributes")
        LV_Add("", "Write extended attributes")
        LV_Add("", "Delete subfolders and files")
        LV_Add("", "Delete")
        LV_Add("", "Read permissions")
        LV_Add("", "Change permissions")
        LV_Add("", "Take ownership")
    Gui Add, Link, x22 y380 w500 h23, <a>How are effective permissions determined?</a>

Gui Tab

Gui Add, Button, x377 y414 w75 h23 Default, OK
Gui Add, Button, x458 y414 w75 h23, Cancel
Gui Add, Button, x539 y414 w75 h23 Disabled, &Apply

Gui Show, w620 h444, Advanced Security Settings for System32 - Sample GUI
Return

GuiEscape:
GuiClose:
    ExitApp
