;
; Author:         Shayne Holmes
;
; Script Function:
; Launch MusicBee, or restore it if it's already running
;

; ^ - ctrl
; # - win
; ! - alt
; + - shift

#Include lib
#Include MusicBeeIPC ; the path to the MusicBeeIPC SDK
#Include MusicBeeIPC.ahk

if (MB_GetMusicBeeVersionStr() = "Unknown")
{
    Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\MusicBee\MusicBee.lnk"
}
else {
    MB_Window_Restore()
    MB_Window_BringToFront()
}

