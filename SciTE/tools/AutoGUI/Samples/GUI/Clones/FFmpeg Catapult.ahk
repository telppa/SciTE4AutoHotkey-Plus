#NoEnv
#Warn
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

Try {
    Gui Add, % "Tab3", x12 y12 w479 h220 +Theme, Main|Picture|Video|Audio|Tagging|Options
} Catch {
    Gui Add, Tab2, x12 y12 w479 h220 +Theme, Main|Picture|Video|Audio|Tagging|Options
}
    Gui Add, GroupBox, x20 y38 w462 h97, Files
    Gui Add, Text, x28 y59 w34 h13, Input:
    Gui Add, Edit, x76 y56 w318 h20
    Gui Add, Button, x400 y53 w75 h23, Browse
    Gui Add, Text, x28 y85 w42 h13, Output:
    Gui Add, Edit, x76 y82 w318 h20
    Gui Add, Button, x400 y80 w75 h23, Save
    Gui Add, CheckBox, x31 y108 w125 h17, Overwrite existing file

    Gui Add, GroupBox, x20 y140 w375 h80, Encoding
    Gui Add, Text, x28 y162 w40 h13, Preset:
    Gui Add, DropDownList, x76 y159 w312, 
    (LTrim Join|
        Default|
        Apple iPod (5th Gen), 240p
        Apple iPod (5th Gen), 480p
        Sony PSP
        Sony PSP, 480p
        DivX
        H.264, Standard Definition
        H.264, High Definition
        MPEG-2, Standard Definition
        MPEG-2, High Definition
        MPEG-4, Standard Definition
        MPEG-4, High Definition
        VP8, Standard Definition
        VP8, High Definition
        Extract audio stream to MP3
        Copy audio and video to AVI
        Copy audio and video to MKV
        Copy audio and video to MP4
    )
    Gui Add, Text, x28 y189 w42 h13, Format:
    Gui Add, DropDownList, x76 y186 w179,
    (LTrim Join|
        3GP
        AVI|
        M4A
        Matroska
        MP3
        MP4
        MPEG Program Stream
        MPEG Transport Stream
        Ogg
        WebM
        Windows Media Audio
        Windows Media Video
        Custom
    )
    Gui Add, CheckBox, x264 y189 w68 h17 Checked, Threads:
    Gui Add, DropDownList, x335 y186 w53, Auto|1||

    Gui Add, GroupBox, x400 y140 w82 h80, Session
    Gui Add, Radio, x406 y160 w50 h17 Checked, Keep
    Gui Add, Radio, x406 y186 w62 h17, Refresh

Gui Tab, 2
    Gui Add, GroupBox, x20 y38 w240 h95, Resolution
    Gui Add, Radio, x28 y59 w134 h17, Keep original resolution
    Gui Add, Radio, x28 y82 w92 h17, Half resolution
    Gui Add, Radio, x28 y105 w56 h17 Checked, Width:
    Gui Add, Edit, x90 y104 w55 h20, 512
    Gui Add, Text, x152 y107 w41 h13, Height:
    Gui Add, Edit, x199 y104 w55 h20

    Gui Add, GroupBox, x20 y139 w240 h78, Screen
    Gui Add, CheckBox, x28 y160 w82 h17, Aspect ratio
    Gui Add, CheckBox, x174 y160 w80 h17, Deinterlace
    Gui Add, Text, x25 y189 w35 h13 Disabled, Ratio:
    Gui Add, Edit, x66 y187 w25 h20 Disabled, 16
    Gui Add, Text, x97 y189 w10 h13 Disabled, :
    Gui Add, Edit, x113 y187 w25 h20 Disabled, 9
    Gui Add, Text, x193 y192 w30 h13, FPS:
    Gui Add, Edit, x229 y189 w25 h20

    Gui Add, GroupBox, x264 y38 w217 h121, Layout
    Gui Add, CheckBox, x275 y59 w48 h17, Crop
    Gui Add, CheckBox, x425 y59 w45 h17, Pad
    Gui Add, Text, x272 y84 w38 h13 Disabled, Width:
    Gui Add, Edit, x316 y105 w50 h20 Disabled
    Gui Add, Text, x378 y84 w41 h13 Disabled, Height:
    Gui Add, Edit, x425 y81 w50 h20 Disabled
    Gui Add, Text, x272 y109 w29 h13 Disabled, Vert:
    Gui Add, Edit, x316 y81 w50 h20 Disabled
    Gui Add, Text, x378 y109 w34 h13 Disabled, Horiz:
    Gui Add, Edit, x425 y105 w50 h20 Disabled
    Gui Add, Text, x272 y134 w40 h13 Disabled, Colour:
    Gui Add, Edit, x316 y131 w100 h20 Disabled

    Gui Add, GroupBox, x264  y165 w217 h52, Scaling
    Gui Add, Text, x272 y189 w46 h13, Method:
    Gui Add, DropDownList, x324 y186 w151, Bicubic|Bilinear|Gaussian|Lanczos||Sinc|Spline

Gui Tab, 3
    Gui Add, GroupBox, x20 y38 w186 h82,Codec
    Gui Add, Button, x416 y245 w75 h23 Disabled, Run
    Gui Add, Button, x12 y245 w75 h23, Exit
    Gui Add, Text, x28 y62 w41 h13, Codec:
    Gui Add, DropDownList, x75 y59 w125,
    (LTrim Join|
        H.264
        H.265
        MPEG-2
        MPEG-4|
        Theora
        VP8
        WMV
        Copy
        None
    )
    Gui Add, CheckBox, x31 y90 w119 h17, Two-pass encoding

    Gui Add, GroupBox, x210 y38 w271 h82,Encoder
    Gui Add, Text, x218 y62 w50 h13, Encoder:
    Gui Add, DropDownList, x274 y59 w201, MPEG-4 (FFmpeg)|Xvid||
    Gui Add, Button, x400 y86 w75 h23, Properties

    Gui Add, GroupBox, x20 y122 w461 h97, Bitrate
    Gui Add, Text, x28 y145 w40 h13, Bitrate:
    Gui Add, Text, x315 y144 w27 h13, Min:
    Gui Add, Edit, x163 y145 w30 h15, Kbps
    Gui Add, ComboBox, x160 y142 w53, Kbps||
    Gui Add, Text, x312 y169 w30 h13, Max:
    Gui Add, Text, x304 y193 w38 h13, Buffer:
    Gui Add, CheckBox, x31 y169 w69 h17, Use CRF
    Gui Add, Text, x28 y192 w31 h13 Disabled, CRF:
    Gui Add, Edit, x65 y189 w35 h20 Disabled
    Gui Add, Text, x434 y170 w31 h13, Kbps
    Gui Add, Text, x434 y145 w31 h13, Kbps
    Gui Add, DropDownList, x434 y190 w41, KB|MB||GB
    Gui Add, Edit, x72 y142 w80 h20, 1000
    Gui Add, Edit, x348 y141 w80 h20
    Gui Add, Edit, x348 y166 w80 h20, 1500
    Gui Add, Edit, x348 y191 w80 h20, 2
    Gui Add, Text, x115 y192 w34 h13, Qmin:
    Gui Add, Edit, x155 y189 w35 h20
    Gui Add, Text, x196 y192 w37 h13, Qmax:
    Gui Add, Edit, x239 y189 w35 h20

Gui Tab, 4
    Gui Add, GroupBox, x20 y38 w186 h57, Codec
    Gui Add, Text, x28 y62 w41 h13, Codec:
    Gui Add, DropDownList, x75 y59 w125,
    (LTrim Join|
        AC3
        AAC
        FLAC
        HE-AAC
        MP2
        MP3|
        Opus
        PCM
        Speex
        Vorbis
        WMA
        Copy
        None
    )
    Gui Add, GroupBox, x210 y38 w271 h82, Encoder
    Gui Add, Text, x218 y62 w50 h13, Encoder:
    Gui Add, DropDownList, x274 y59 w201, LAME||
    Gui Add, Button, x400 y86 w75 h23 Disabled, Properties

    Gui Add, GroupBox, x20 y97 w186 h74, Bitrate
    Gui Add, Text, x28 y119 w40 h13, Bitrate:
    Gui Add, DropDownList, x75 y116 w125,
    (LTrim Join|
        32 Kbps
        40 Kbps
        48 Kbps
        56 Kbps
        64 Kbps
        80 Kbps
        96 Kbps
        112 Kbps
        128 Kbps|
        144 Kbps
        160 Kbps
        192 Kbps
        224 Kbps
        256 Kbps
        320 Kbps
    )
    Gui Add, CheckBox, x32 y143 w70 h17, Use VBR

    Gui Add, GroupBox, x210 y123 w271 h48, Output
    Gui Add, Text, x218 y144 w54 h13, Channels:
    Gui Add, DropDownList, x278 y140 w39, 1|2||
    Gui Add, Text, x353 y144 w31 h13, Freq:
    Gui Add, DropDownList, x390 y140 w85,
    (LTrim Join|
        8000 Hz
        11025 Hz
        12000 Hz
        16000 Hz
        22050 Hz
        24000 Hz
        32000 Hz
        44100 Hz|
        48000 Hz
    )
    Gui Add, GroupBox, x20 y173 w461 h46, Stream
    Gui Add, Text, x28 y193 w37 h13, Audio:
    Gui Add, Edit, x71 y190 w323 h20
    Gui Add, Button, x400 y188 w75 h23, Browse

Gui Tab, 5
    Gui Add, GroupBox, x20 y38 w461 h97, General
    Gui Add, Text, x28 y59 w30 h13, Title:
    Gui Add, Edit, x73 y56 w402 h20
    Gui Add, Text, x28 y84 w39 h13, Album:
    Gui Add, Edit, x73 y81 w302 h20
    Gui Add, Text, x381 y84 w32 h13 Disabled, Year:
    Gui Add, Edit, x419 y81 w56 h20 Disabled
    Gui Add, Text, x28 y109 w30 h13, Artist
    Gui Add, Edit, x73 y106 w218 h20
    Gui Add, Text, x297 y109 w39 h13, Genre:
    Gui Add, Edit, x342 y106 w133 h20

    Gui Add, GroupBox, x20 y139 w138 h80, Track
    Gui Add, Text, x28 y163 w38 h13, Track:
    Gui Add, Edit, x73 y160 w25 h20
    Gui Add, Text, x104 y163 w12 h13, /
    Gui Add, Edit, x122 y160 w25 h20
    Gui Add, Text, x28 y188 w31 h13 Disabled, Disc:
    Gui Add, Edit, x73 y186 w25 h20 Disabled
    Gui Add, Text, x104 y189 w12 h13 Disabled, /
    Gui Add, Edit, x122 y186 w25 h20 Disabled

    Gui Add, GroupBox, x162 y139 w319 h80, Misc
    Gui Add, Text, x170 y163 w35 h13 Disabled, Band:
    Gui Add, Edit, x211 y160 w100 h20 Disabled
    Gui Add, Text, x317 y163 w53 h13 Disabled, Publisher:
    Gui Add, Edit, x375 y160 w100 h20 Disabled
    Gui Add, Text, x170 y189 w54 h13, Comment:
    Gui Add, Edit, x230 y186 w245 h20

Gui Tab, 6
    Gui Add, GroupBox, x20 y38 w461 h123, Binaries
    Gui Add, Text, x28 y59 w48 h13, FFmpeg:
    Gui Add, Edit, x84 y56 w310 h20, ffmpeg.exe
    Gui Add, Button, x400 y53 w75 h23, Browse
    Gui Add, Text, x28 y84 w50 h13, Terminal:
    Gui Add, Edit, x84 y81 w310 h20, cmd.exe
    Gui Add, Button, x400 y79 w75 h23, Browse
    Gui Add, Text, x28 y109 w86 h13, Term arguments:
    Gui Add, Edit, x134 y106 w341 h20, /c start
    Gui Add, Text, x28 y135 w100 h13, FFmpeg arguments:
    Gui Add, Edit, x134 y132 w341 h20

    Gui Add, GroupBox, x20 y165 w461 h54, Session
    Gui Add, CheckBox, x31 y188 w87 h17, Write log file:
    Gui Add, CheckBox, x351 y188 w124 h17 Checked, Save settings on exit
    Gui Add, Edit, x118 y186 w213 h20 Disabled

Gui Tab
Gui Add, Button, x12 y245 w75 h23, Exit
Gui Add, Button, x416 y245 w75 h23 Disabled, Run

Gui Show, w503 h280, FFmpeg Catapult - Sample GUI
Return

GuiEscape:
GuiClose:
    ExitApp
