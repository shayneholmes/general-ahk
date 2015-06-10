;
; Author:         Shayne Holmes
;
; Script Function:
; Customizing desktop experience for Shayne's work computer
;

; ^ - ctrl
; # - win
; ! - alt
; + - shift

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SetTitleMatchMode 2 ; for #ifwinnotactive calls
DetectHiddenWindows, on
Menu, Tray, Icon, icon.ico ; set tray icon

#Include lib
#Include minimizetray.ahk
#Include MusicBeeIPC ; the path to the MusicBeeIPC SDK
#Include MusicBeeIPC.ahk

#Persistent
SetBatchLines, 10ms
Process, Priority,, High

; Shell Hook
Gui +LastFound
hWnd := WinExist()
DllCall("RegisterShellHookWindow", UInt,hWnd)
MsgNum := DllCall("RegisterWindowMessage", Str,"SHELLHOOK")
OnMessage(MsgNum, "ShellMessage")
OnMessage(16687, "RainmeterWindowMessage")

ShellMessage(wParam, lParam) {
; Execute a command based on wParam and lParam
;    WinGet, currentProcess, ProcessName, ahk_id %lParam%
;    PlaceToolTip("Window event: " wParam " on " currentProcess)
  If (wParam = 2 OR wParam = 6) { ; HSHELL_WINDOWDESTROYED or HSHELL_REDRAW
    WinGet, currentProcess, ProcessName, ahk_id %lParam%
    ; PlaceToolTip("Window redrawn: " . currentProcess)

    If (currentProcess = "plover.exe") {
      ; Plover update
      UpdatePloverWindowStatus()
    }
    If (currentProcess = "launchy.exe") {
      Process, Exist, Launchy.exe
      LaunchyActive := (ErrorLevel != 0)
    }
  }
  If (wParam = 4 OR wParam = 32772) { ; HSHELL_WINDOWACTIVATED or HSHELL_RUDEAPPACTIVATED
    WinGet, currentProcess, ProcessName, ahk_id %lParam%
    ; PlaceToolTip("Window activated: " . currentProcess)

    ; Update Antimicro for Outlook transitions
    OutlookActive := (currentProcess = "outlook.exe") AND WinActive("Inbox ahk_id" . lParam . " ahk_exe Outlook.exe")
    UpdateAntimicro(OutlookActive)
  }
}

AntimicroPath := "C:\Users\shholmes\Dropbox\Apps\antimicro\antimicro.exe"
AntimicroExists := FileExist(AntimicroPath)

UpdateAntimicro(outlookActive) {
  global AntimicroPath, AntimicroExists
  static AntimicroOutlookActive
  if (outlookActive <> AntimicroOutlookActive) {
    profileName := outlookActive ? "Outlook" : "Mouse"
    if (AntimicroExists) {
      Run, %AntimicroPath% --profile "C:\Users\shholmes\Dropbox\Apps\antimicro\profiles\%profileName%.gamecontroller.amgp"
    }
    AntimicroOutlookActive := outlookActive
  }
}

RainmeterPath := "C:\Program Files\Rainmeter\rainmeter.exe"
RainmeterExists := FileExist(RainmeterPath)

SendRainmeterCommand(Command) {
  global RainmeterPath, RainmeterExists
  if (RainmeterExists) {
    Run, %RainmeterPath% %Command%
    ; PlaceTooltip("Send Rainmeter: " Command)
  }
}

RainmeterWindowMessage(wParam, lParam) { 
  global TimerActive
  If (wParam = 0) { ; new timer
    TimerActive = 0
    StartTimer(lParam, false)
  } Else If (wParam = 1) { ; timer ended and we didn't start it
    CancelTimer(false)
  }
}

Process, Exist, Launchy.exe
LaunchyActive := (ErrorLevel != 0)

HtArray := -1

^/::
^?::
HelpText =
(
AHK hotkeys

td: Today's Date (Friday, 29 March 2013)
yd: Yesterday's Date (Thursday, 28 March 2013)
ts: TimeStamp (2013-03-29)
tt: Today+Time (2013-05-28@11:53)

LWin: Show Launchy (Alt+F10)
Win+T: Set/cancel timer (15 by default, ctrl=2, shift=5)

Ctrl+Alt+A: Window on top
Ctrl+Alt+B: Toggle window border
Win+Shift+R: Restore all windows
Win+H: Hide current window
Win+U: Unhide window

Win+O: Lock workstation

Media Keys:
F12: Play/Pause
F11: Next
F10: Previous
Ctrl+Shift+Right/Left: Forward/Back
Ctrl+Shift+Up/Down: Volume

Explorer:
Ctrl+Alt+H: Toggle hidden files
Ctrl+Alt+E: Toggle extensions
)
PlaceTooltip(HelpText, ,5000)
return

#IfWinActive 

/**
 * Insert current date for journaling
 */
::nd:: ; legacy, was this before and I still type it all the time
::td::
FormatTime, CurrentDateTime,, dddd, d MMMM yyyy
SendInput %CurrentDateTime%
SendRaw %A_EndChar%
return

::yd:: ; 1 day ago, for journaling
today = %a_now%
today += -1, days
FormatTime, today, %today%, dddd, d MMMM yyyy 
SendInput %today%
SendRaw %A_EndChar%
return

::ts:: ; 2013-03-22 (ISO standard, doncha know!)
FormatTime, CurrentDateTime,, yyyy-MM-dd
SendInput %CurrentDateTime%
SendRaw %A_EndChar%
return

::tt:: ; 2013-05-28@11:53 (kinda ISO standard)
FormatTime, CurrentDateTime,, yyyy-MM-dd@HH:mm
; FormatTime, CurrentDateTime,, dddd, d MMMM yyyy hh:mm tt
SendInput %CurrentDateTime%
SendRaw %A_EndChar%
return

:oc:htr::
Month := "May"
If (HtArray == -1) { ; populate array
  HtArray := Object()
  Loop, read, htnames.txt
  {
    OneEntry := Object()
    Loop, Parse, A_LoopReadLine, %A_Tab%
    {
      OneEntry.Insert(A_LoopField)
    }
    HtArray.Insert(OneEntry)
  }
}
Index := HtArray._MinIndex()
OneEntry := HtArray[Index]
Name := OneEntry[1]
LastName := OneEntry[2]
Email := OneEntry[3]
Families := OneEntry[4]
StringReplace, Families, Families, /, `n
HomeTeachingGreeting = 
(
{Tab}{Tab}Home teaching in %Month%?{Tab}Hey %Name%,

It's that time of the month again{!} Which of your home teaching families did you visit in %Month%? I've got you listed as the home teacher of:

%Families%

Also, this month I'm trying to schedule some time to sit down with you for an interview. Will you let me know if you'd prefer Sundays or weeknights? I'm still trying to figure out particulars, but I'll get to you this week by phone to confirm a time (maybe this week, or sometime in the near future).

Let me know if you have any questions{!}

Thanks,

Shayne

)
SetKeyDelay, 0, 5
Send <%Email%>{Tab}
Sleep, 1000
Send %HomeTeachingGreeting%
HtArray.Remove(Index)
return

; App-specific hotkeys

#IfWinActive ResophNotes
^e::^f

#IfWinActive LCWO ; cancel these hotstrings when I'm practicing Morse code

:b0:nd::
:b0:td::
:b0:yd::
:b0:ts::
:b0:tt::
return

#IfWinActive WriteMonkey ; WriteMonkey
#c::Send !{F12} ; reset partial count
#IfWinActive

#IfWinActive ahk_class TscShellContainerClass ; RDP window

^!b::
PlaceTooltip("RDP: Toggling fullscreen.")
Send ^!{CtrlBreak}
return

LAlt & Tab::
WinGet, Style, Style, A ; active window
if (Style & 0x40000) { ; WS_SIZEBOX
  Send {Blind}{Tab}
} else {
  Send {Blind}{PgUp} ; {blind} keeps the alt key down
}
return

#w::
WinGet, Style, Style, A ; active window
if (Style & 0x40000) { ; WS_SIZEBOX
  PostMessage, 0x112, 0xF060,,, A, ; 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE
} else {
  Send !{F4}
}
return

#IfWinActive ahk_class Chrome_WidgetWin_1

^O::return

#IfWinActive ahk_class LyncConversationWindowClass

^Enter::
Send {Enter} ; Instead of starting video chat
return

/**
 * Ctrl+Backspace in Notepad
 */
#IfWinActive ahk_class Notepad
^Backspace::Send +^{Left}{Backspace}
#IfWinActive

/**
 * Outlook keys
 */
#IfWinActive ahk_class rctrl_renwnd32

/**
 * One-key Archive action in Outlook
 */
$F6::Send ^+1
$F7::Send ^+2

; Windows Explorer
#IfWinActive ahk_class CabinetWClass

; Toggle hidden files and file extensions

; Ctrl+Alt+H - Toggle hidden files
^!h::
    RegRead, HiddenFiles_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden
    If HiddenFiles_Status = 2
        RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1
    Else
        RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2
    Send, {F5}
    PlaceTooltip("Hidden files toggled (Ctrl+Alt+H)", "Window")
    Return

; Ctrl+Alt+E - Toggle extensions
^!e::
    RegRead, HiddenFiles_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt
    If HiddenFiles_Status = 1
        RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 0
    Else
        RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 1
    Send, {F5}
    PlaceTooltip("Extensions toggled (Ctrl+Alt+E)", "Window")
    Return
	
; Save and reload ahk if currently editing
#ifwinactive Mine.ahk
^s::
send ^s ; save the script
PlaceTooltip("Reloading script...")
SetTimer,ReloadScript,1000
return

ReloadScript:
SetTimer,ReloadScript,Off
Reload
return

; Save and reload rainmeter if currently editing
#IfWinActive .ini
^s::
WinGetTitle, Title, A
RegExMatch(Title, "(\w+)\.ini", SubPat)
If (SubPat <> "") {
PlaceTooltip("Reloading rainmeter skin " . SubPat1 . "...")
send ^s ; save the script
SendRainmeterCommand("[!Refresh " . SubPat1 . "]")
}
return

; Product Studio
#IfWinActive ahk_class PSWnd
^Backspace::Send +^{Left}{Backspace}
^Enter::Send {F5}
^w::Send ^{F4}
#IfWinActive

; ctrl+v paste in cmd prompt
#IfWinActive ahk_class ConsoleWindowClass
^V:: SendInput {Raw}%clipboard%
return


#IfWinActive

/**
 * Disable stupid key combinations I find annoying
 */
#u::return ; disable narrator
#Enter::return ; other narrator
#F16::return ; can't believe this is a problem, but disable shutdown swipe

$F1::
SetTitleMatchMode 2
IfWinActive, Inkscape
  Send {F1}
IfWinActive, Q10
  Send {F1}
IfWinActive, ahk_class VICE
  Send {F1}
else
  PlaceTooltip("F1 blocked. Try Shift+F1 if you really want it.")
return

+F1::Send {F1}

/**
 * Show Launchy
 */
LWin & =:: ; used to make LWin a Prefix key; see http://www.autohotkey.com/docs/Hotkeys.htm
           ; without this, the windows key doesn't work for other shortcuts like it should!

#IfWinExist Launchy ahk_class QTool
LWin::
;SetTitleMatchMode 2
;WinGet, Style, Style, A ; active window
;if ((WinActive("Virtual Machine Connection") or WinActive("Remote Desktop Connection")) and (!(Style & 0x40000)))
;{
;   Send !{Home}
;} else {
If (LaunchyActive) {
  Send !{F10}
  If (!WinExist("Launchy ahk_class QTool")) {
    LaunchyActive := 0
    Send {LWin}
  }
} Else { ; no Launchy
  Send {LWin}
}
;}
return

#IfWinActive

/**
 * Left-handed lock on Dvorak
 */
#o::
{
if (MB_GetPlayState() == MBPS_Playing) { ; If MusicBee is playing
  MB_PlayPause()
}
else if (IsMusicPlaying() && WinExist("ahk_class Chrome_WidgetWin_1")) { ; try to pause Chrome
    Send +!{Home}
}
Sleep, 200 ; wait for Win key to lift
DllCall("LockWorkStation")
Sleep, 200
SendMessage,0x112,0xF170,2,,Program Manager ; turn off monitor
}
return

; Hook into next/prev if MPC is up and running
#IfWinExist ahk_class MediaPlayerClassicW

Media_Next::
Media_Play_Pause & 0::
Media_Play_Pause & PgUp::
$F11:: ; next track
ControlSend,,{PgDn},ahk_class MediaPlayerClassicW
return

Media_Prev::
+Media_Next::
Media_Play_Pause & 9::
Media_Play_Pause & PgDn::
$F10:: ; previous track
ControlSend,,{PgUp},ahk_class MediaPlayerClassicW
return

; Remappings for MusicBee
#IfWinExist MusicBee

Pause & ScrollLock::Send {Media_Next}
Pause & PrintScreen::Send {Media_Prev}

Media_Play_Pause::
SetErgodoxConnected()
F12::
Pause::
; PlaceTooltip("Play/pause")
MB_PlayPause()
return

Media_Next::
F11::
MB_NextTrack()
return

Media_Prev::
+Media_Next::
F10::
+F11::
MB_PreviousTrack()
return

^!Right:: ; fast forward 30 secs
MB_SetPosition(MB_GetPosition() + 30000)
Return

^!Left:: ; rewind 10 secs
time := (MB_GetPosition() - 10000)
if (time < 0)
  time := 0
MB_SetPosition(time)
Return

^!Up:: ; increase volume
MB_SetVolume(MB_GetVolume()+10)
Return

^!Down:: ; decrease volume
MB_SetVolume(MB_GetVolume()-10)
Return

#IfWinExist ahk_class Chrome_WidgetWin_1
; StreamKeys hotkeys

Media_Play_Pause::
Send +!{Home}
return

Media_Next::
Send +!{PgDn}
return

+Media_Next::
Media_Prev::
Send +!{PgUp}
return

#IfWinActive

; Window commands

#w::PostMessage, 0x112, 0xF060,,, A, ; 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE
#q::Send !{F4}
#n::WinMinimize, A

^!a::
Winset, Alwaysontop, , A
WinGet, ExStyle, ExStyle, A
winistop := (ExStyle & 0x8) ; 0x8 is WS_EX_TOPMOST.
PlaceTooltip("Window " . (winistop ? "" : "no longer ") . "on top (Ctrl+Alt+A)", "Window")
return

^!b::
Winset, Style, ^0xC00000, A
WinGet, ExStyle, ExStyle, A
winisborder := (ExStyle & 0xC00000) ; 0xC00000 is WS_CAPTION
PlaceTooltip("Window " . (winisborder ? "no longer " : "") . "unbordered (Ctrl+Alt+B)", "Window")
return

^!v::
clipboard=%clipboard%
sendraw %clipboard%
return

;------------------
; Tooltip functions
ToolTipOff:
SetTimer,ToolTipOff,Off
ToolTip
return

PlaceTooltip(byref text, location="Screen", delay=1000)
{
	if (location="Window") {
		CoordMode, ToolTip, Window
		WinGetPos, X, Y, W, H, A
		X := W / 2
		Y := 25
	} else if (location="Cursor") { 
		; don't set X and Y
	} else { 
		CoordMode, ToolTip, Screen
		x := A_ScreenWidth - 180
		Y := A_ScreenHeight - 80
	}
	ToolTip, % text, X, Y
	if (delay > -1) {
		SetTimer,ToolTipOff,%delay%
	}
}

#+R:: ; Restore all windows
WinGet, id, list,,, Program Manager
Loop, %id%
{
    this_id := id%A_Index%
    WinGetTitle, this_title, ahk_id %this_id%
    if (InStr(this_title, "KeePass")) {
        continue
    }
    WinGet, this_minimized, MinMax, ahk_id %this_id%
    if (this_minimized == -1) {
        WinRestore, ahk_id %this_id%
    }
}
Return

#^t:: ; Set 2-minute timer
SetTimer(2*60)
return

#+t:: ; Set 5-minute timer
SetTimer(5*60)
return

#t:: ; Set 15-minute timer
SetTimer(15*60)
return

SetTimer(Seconds) {
  global TimerActive
  if (not TimerActive) {
    StartTimer(Seconds, true)
  } else {
    CancelTimer(true)
  }
}

StartTimer(Seconds, EventFromAHK = true)
{
  global TimerActive
  global TimerStartedTime
  global TimerStartedFromAHK

  TimerStartedTime := A_TickCount
  If (EventFromAHK) {
    Color   := "4,192,64,255"
    TimerCount = 0
    If (Seconds = 15*60) {
      Color   := "255,0,0,255"
      TimerCount = 1
    } Else If (Seconds = 5*60) {
      Color   := "96,96,128,255"
    }
    If (mod(Seconds,60) = 0) {
      PrettyTime := Seconds // 60 . " minutes"
    } Else {
      PrettyTime := Seconds . " seconds"
    }
    PlaceTooltip("Timer set for " . PrettyTime . ".", , 3000)
    SoundPlay, alarmstart.wav
    SendRainmeterCommand("[!SetVariable ActiveTimerCount " TimerCount "][!SetVariable TimerDuration " Seconds "][!Update][!SetVariable ColorTimerArc " Color " ][!EnableMeasure MeasureStartTimerAPIBang MinimalTimer][!Update]")
    delay := -1000*(Seconds)
    SetTimer, TimerEnd, %delay%
    TimerStartedFromAHK := true
  } else { ; Rainmeter; cancel any existing AHK timer
    SetTimer, TimerEnd, off
    TimerStartedFromAHK := false
  }
  TimerActive = 1
  Menu, Tray, Icon, timer.ico
}

CancelTimer(EventFromAHK = true) {
  global TimerActive
  global TimerStartedTime
  global TimerStartedFromAHK
  
  If (EventFromAHK) { ; user-initiated cancel
    SendRainmeterCommand("[SetVariable ActiveTimerCount 0][!SetVariable TimerEndOfTimer 0][!Update]")
    SoundPlay, alarmcancel.wav
    TimerEndedTime := A_TickCount
    Duration := (TimerEndedTime - TimerStartedTime) / 1000
    T = 20000101000000
    T += Duration, Seconds
    FormatTime FormdT, %T%, mm:ss
    PlaceTooltip("Timer canceled after " . FormdT, , 3000)
    SetTimer, TimerEnd, off
  } else if (TimerStartedFromAHK){ ; Rainmeter finished one of ours early
    return
  }
  TimerActive = 0
  Menu, Tray, Icon, icon.ico
  If (!IsMusicPlaying())
    BeepPcSpeakers()
}

TimerEnd:
PlaceTooltip("Time's up!", , 3000)
If (!IsMusicPlaying())
  BeepPcSpeakers()
SoundPlay, alarmsound.wav
TimerActive = 0
Menu, Tray, Icon, icon.ico
return

; Ergodox functionality

; F13::Run, "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
F14::Send μ
+F14::Send Μ
F15::Send λ
+F15::Send Λ
F16::Send α
+F16::Send Α
F17::Send ∞

F24:: ;plover launch
LaunchPlover:
If (!WinExist("Plover ahk_class wxWindowNR")) {
  PlaceToolTip("No Plover found; launching...", , 3000)
  Run, ..\Plover\plover.exe
  WinWait, Plover ahk_class wxWindowNR, , 15
}
return

+F24:: ;plover re-launch
+F23:: ;plover re-launch
If (WinExist("Plover ahk_class wxWindowNR")) {
  WinClose,,,5
}
Goto LaunchPlover
return

#^r:: ; Reload
PlaceTooltip("Reloading script...")
SetTimer,ReloadScript,1000
return

#e:: ; Substitute FreeCommander for Explorer
If WinExist("ahk_class FreeCommanderXE.SingleInst.1") {
  WinActivate
} else if FileExist("C:\Program Files (x86)\FreeCommander XE\FreeCommander.exe") {
  Run, C:\Program Files (x86)\FreeCommander XE\FreeCommander.exe,,,pid
  ; bring it to foreground when it launches
  WinWait, ahk_pid %pid%
  WinActivate, ahk_pid %pid%
} else {
  Run explorer.exe
}
return

IsMusicPlaying() {
audioMeter := VA_GetAudioMeter()

VA_IAudioMeterInformation_GetMeteringChannelCount(audioMeter, channelCount)

; "The peak value for each channel is recorded over one device
;  period and made available during the subsequent device period."
VA_GetDevicePeriod("capture", devicePeriod)

    ; Get the peak value across all channels.
    VA_IAudioMeterInformation_GetPeakValue(audioMeter, peakValue)    
    return (peakValue > 0.01)
}

; Get rid of Win+Tab, replace it with the more helpful and conventional Alt+Tab
LWin & Tab::AltTab

; Model M stuff (I've remapped the LAlt to a LWin, and RAlt to LAlt)
; RCtrl::LWin
; ScrollLock::LWin
; LCtrl & LWin::Send {Alt Down}
; LCtrl & LWin Up::Send {Alt Up}

ErgodoxConnected()
{
  return ErgodoxState
}

SetErgodoxConnected()
{
  global ErgodoxState
  If (ErgodoxState <> true) {
    PlaceTooltip("Noticed Ergodox. Setting keys right." . ErgodoxState)
    ErgodoxState := true
    Hotkey, IfWinExist, MusicBee
    Hotkey, F12, Off
    Hotkey, F11, Off
    Hotkey, F10, Off
  }
}

UpdatePloverWindowStatus() {
; Update Rainmeter
WinGetTitle, PloverTitle, ahk_class wxWindowNR ahk_exe plover.exe
If ((PloverLastStatus != -1) and InStr(PloverTitle, ": running")) {
  PloverLastStatus := -1
  SendRainmeterCommand("[!SetVariable StatusBubble -1][!Update]")
}
Else If ((PloverLastStatus != 1) and InStr(PloverTitle, ": stopped")) {
  PloverLastStatus := 1
  SendRainmeterCommand("[!SetVariable StatusBubble 1][!Update]")
}
Else If (PloverTitle = "") {
  PloverLastStatus := 0
  SendRainmeterCommand("[!SetVariable StatusBubble 0][!Update]")
}
}

#c::
WinGetTitle, Title, Google Play Music
PlaceToolTip(Title)
return

BeepPcSpeakers() {
SoundBeep 400, 40
SoundBeep 800, 40 
; SoundBeep 400
}

F13::
PlaceToolTip("Productivity mode")
HideWindow("Google Chrome")
return