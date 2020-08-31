#NoEnv
#Warn
SetWorkingDir %A_ScriptDir%

Gui Add, GroupBox, x3 y0 w230 h111, Slide advancement
Gui Add, Radio, x11 y21 w90 h13 Checked, Automati&c after
Gui Add, Edit, x108 y18 w38 h20, 5.000
Gui Add, Text, x149 y21 w60 h13, seconds
Gui Add, Radio, x11 y44 w210 h13, Automatic after &mouse/keyboard input
Gui Add, Radio, x11 y67 w93 h13, &Random   after
Gui Add, Edit, x108 y63 w38 h20, 5.000
Gui Add, Text, x149 y67 w60 h13, seconds
Gui Add, Radio, x11 y89 w210 h13, R&andom   after mouse/keyboard input
Gui Add, GroupBox, x231 y0 w194 h111
Gui Add, Button, x251 y20 w150 h28, Play &Slideshow
Gui Add, Button, x251 y67 w150 h28, Cancel

Gui Add, GroupBox, x3 y117 w230 h180, Slideshow options
Gui Add, Text, x9 y138 w95 h13, Start with image nr.:
Gui Add, Edit, x108 y135 w38 h20, 1
Gui Add, Text, x149 y138 w81 h13, (file double-click)
Gui Add, CheckBox, x11 y161 w218 h15, R&emember last file index on exit
Gui Add, CheckBox, x11 y182 w206 h15, &Loop slideshow
Gui Add, CheckBox, x11 y203 w206 h15 Checked, S&uppress errors while playing
Gui Add, CheckBox, x11 y224 w218 h15 Checked, L&oop MP3 files (for background music)
Gui Add, CheckBox, x11 y245 w206 h15, Hi&de mouse cursor
Gui Add, CheckBox, x11 y267 w218 h15, Close IrfanView after last slideshow file
Gui Add, GroupBox, x231 y117 w194 h180
Gui Add, CheckBox, x237 y133 w87 h15 Checked, Show &text:
Gui Add, Edit, x237 y153 w182 h89 -VScroll, $D$F $X
Gui Add, Text, x237 y245 w143 h42, $D = file folder`, $F = file name`n$X = file index`,`n$Ex = EXIF`, $Ix = IPTC ...
Gui Add, Button, x369 y262 w50 h23, Help

Gui Add, GroupBox, x3 y289 w422 h112, Play mode:
Gui Add, Radio, x11 y306 w218 h16 Checked, Play in full screen mode (current monitor)
Gui Add, Button, x29 y325 w153 h24, Full screen options
Gui Add, Radio, x249 y306 w155 h16, Play in Window mode:
Gui Add, Text, x255 y332 w32 h13, X-pos:
Gui Add, Edit, x288 y328 w33 h20 Disabled, 0
Gui Add, Text, x345 y332 w36 h13, Y-pos:
Gui Add, Edit, x381 y328 w33 h20 Disabled, 0
Gui Add, Text, x255 y358 w33 h13, Width:
Gui Add, Edit, x288 y354 w33 h20, 800
Gui Add, Text, x345 y358 w36 h13, Height:
Gui Add, Edit, x381 y354 w33 h20, 600
Gui Add, CheckBox, x255 y380 w83 h15 Checked, Centered

Gui Add, GroupBox, x3 y393 w230 h156
Gui Add, Button, x11 y405 w170 h21, Load filenames from TXT file
Gui Add, Button, x11 y431 w170 h21, Save filenames as TXT file
Gui Add, Button, x11 y457 w170 h21, Save slideshow as  EXE/SCR
Gui Add, Button, x11 y483 w170 h21, Burn slideshow to CD
Gui Add, CheckBox, x11 y509 w219 h18, Include su&bdirectories (for 'Add all')
Gui Add, CheckBox, x11 y530 w185 h15 Checked, Show &Preview image
Gui Add, Text, x252 y408 w158 h141 +0x1201, Preview image

Gui Add, Text, x440 y15 w41 h13, Look &in:
Gui Add, DropDownList, x483 y10 w222, Desktop|Computer|System (C:)||
Gui Add, ActiveX, vExplorer x435 y38 w413 h138, Shell.Explorer
Explorer.Navigate("C:\")
Gui Add, Text, x437 y187 w72 h13, File &name:
Gui Add, Edit, x510 y185 w238 h20
Gui Add, Text, x437 y218 w72 h13, Files of &type:
Gui Add, DropDownList, x510 y215 w238, Common Graphic Files||All files (*.*)|ANI/CUR - Windows Cursors|AVI/WMV/ASF - Video for Windows|B3D - BodyPaint 3D Format|BMP/DIB/RLE - Windows Bitmap|CAM - Casio Camera File (JPG Version only)|CDR/CMX - Corel Draw Format (Preview only)|CLP - Windows Clipboard|CPT - Corel PhotoPaint 6.0 Format|CRW/CR2 - Canon CRW Format|DCM/ACR/IMA - DICOM/ACR/IMA Format|DCR/DNG/EFF/MRW/NEF/NRW/ORF/PEF/RAF/SRF/ARW/RWL/RW2/X3F/MPO - Digital Camera RAW Format|DDS/BLP - Direct Draw Surface|DJVU/IW44 - DjVu Format|DWG/DXF/HPGL/CGM/SVG/PLT - CAD Files|ECW - Enhanced Compressed Wavelet|EPS/PS/PDF/AI - PostScript Files|EXE/DLL/CPL - Files|EXR - EXR Format|FPX - FlashPix Format|FSH - EA Sports Format|G3 - G3 FAX Format|GIF - Compuserve GIF|HDP/JXR/WDP - JPEG-XR/HD Photo|ICO/ICL - Windows Icons|ICS/IDS - Image Cytometry Standard Format|IFF/LBM - Amiga Interchange File Format|IMG - GEM Raster Format|JLS - JPEG-LS Format|JP2 - JPEG2000 Format|JPG/JPEG - JPG Files|JPM - JPM Format|KDC - Kodak Digital Camera Files|MED - MED/OctaMED Audio Format|MNG/JNG - Multiple Network Graphics|MP3/M3U - MPEG Audio Files|MOV - Apple QuickTime Movie|MPG/MPEG/DAT - MPEG Files|NLM/NOL/NGG/GSM - Nokia LogoManager Files|OGG - Ogg Vorbis Audio Format|PBM/PGM/PPM - Portable Bitmaps|PCD - Kodak Photo CD|PCX/DCX - Zsoft Paintbrush|PDN - Paint.NET Format|PNG - Portable Network Graphics|PSD - Photoshop Files|PSP - Paint Shop Pro Files|RA - Real Audio Files|RAS - Sun Raster Files|RAW/YUV - RAW Files|RLE - Utah RLE Files|SFF - Structured Fax Format|SFW - Seattle Film Works Files|SGI - Silicon Graphics Files|SID - LizardTech MrSID Format|SWF/FLV - Flash/Shockwave Format|TGA - Truevision Targa|TIF - Tagged Image File Format|TTF - True Type Font Files|WAV/MID/RMI/WMA/AIF/SND/AU/CDA - Sound Files|WBMP - WAP Bitmap|WBZ/WBC - Webshots Format|WEBP - Weppy Format|WMF/EMF - Windows Metafiles|WSQ - Wavelet Scaler Quantization|XBM/XPM - X-Bitmap|XCF - GIMP File Format
Gui Add, Button, x555 y265 w69 h24, Add
Gui Add, Button, x555 y294 w69 h24, Add all
Gui Add, Button, x629 y265 w69 h24, Remove
Gui Add, Button, x629 y294 w69 h24, Remove all
Gui Add, Button, x702 y265 w69 h24, Move up
Gui Add, Button, x702 y294 w69 h24, Move down
Gui Add, Button, x776 y293 w69 h24, Sort files
Gui Add, Text, x429 y306 w77 h16, Slideshow files:
Gui Add, Text, x509 y306 w42 h16, ( 0 )
Gui Add, ListBox, x429 y322 w417 h225

Gui Show, w856 h554, IrfanView Slideshow - Sample GUI
Return

GuiEscape:
GuiClose:
    ExitApp
