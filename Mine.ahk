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
IconStateArray := {timer: false, plover: false} ; set precedence for icons
SetIconState()

#Include lib
#include Gdip.ahk
#Include minimizetray.ahk
#Include MusicBeeIPC ; the path to the MusicBeeIPC SDK
#Include MusicBeeIPC.ahk

#Persistent
SetBatchLines, -1
Process, Priority,, High
ListLines Off

; Shell Hook
Gui +LastFound
hWnd := WinExist("Mine ahk_class AutoHotkey")
DllCall("RegisterShellHookWindow", UInt,hWnd)
MsgNum := DllCall("RegisterWindowMessage", Str,"SHELLHOOK")
OnMessage(MsgNum, "ShellMessage")
OnMessage(16687, "RainmeterWindowMessage") ; 16687 = MESSAGE_RAINMETER

; allow message from non-elevated Rainmeter window
DllCall("ChangeWindowMessageFilterEx", Ptr,hWnd, Uint,16687, Uint,1, ptr,0) ; 16687 = MESSAGE_RAINMETER, 1 = MSGFLT_ALLOW

EnvGet, UserProfile, UserProfile

AntimicroPath := "C:\Users\shholmes\Dropbox\Apps\antimicro\antimicro.exe"
AntimicroExists := FileExist(AntimicroPath)

LaunchOrHidePlover()
; UpdatePloverWindowStatus() 

SetTimer, UpdatePloverWindowStatus, 5000


HtArray := -1

; Set up highlighter for screenshots
Gui, ScreenshotSelection:New, -Caption +ToolWindow +LastFound
Gui, ScreenshotSelection:Color, Yellow
WinSet, Transparent, 100

CheckRainmeterTooltipHeartbeat()
SetTimer, CheckRainmeterTooltipHeartbeat, 300000 ; 5 minutes

ShellMessage(wParam, lParam) {
; Execute a command based on wParam and lParam
;    WinGet, currentProcess, ProcessName, ahk_id %lParam%
;    PlaceToolTip("Window event: " wParam " on " currentProcess)
  If (wParam = 2 OR wParam = 6) { ; HSHELL_WINDOWDESTROYED or HSHELL_REDRAW
    WinGet, currentProcess, ProcessName, ahk_id %lParam%
    ; PlaceToolTip("Window redrawn: " currentProcess)

    If (currentProcess = "plover.exe") {
      ; Plover update
      UpdatePloverWindowStatus()
    }
  }
  If (wParam = 1) { ; HSHELL_WINDOWCREATED
    WinGet, currentProcess, ProcessName, ahk_id %lParam%
    ; PlaceToolTip("Window created: " currentProcess)
    If (currentProcess = "plover.exe") {
      ; Plover launch
      global HidePloverOnNextLaunch
      If (HidePloverOnNextLaunch) {
        HidePlover()
        HidePloverOnNextLaunch := false
      }
    }
  }
  If (wParam = 4 OR wParam = 32772) { ; HSHELL_WINDOWACTIVATED or HSHELL_RUDEAPPACTIVATED
    WinGet, currentProcess, ProcessName, ahk_id %lParam%
    ; PlaceToolTip("Window activated: " currentProcess)

    ; Update Antimicro for Outlook transitions
    OutlookActive := (currentProcess = "outlook.exe")
    UpdateAntimicro(OutlookActive)
  }
}

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

RainmeterWindowMessage(wParam, lParam) { 
  global RainmeterTooltipActive
  If (wParam = 0) { ; timer start
    StartTimer(lParam, false)
  } Else If (wParam = 1) { ; timer end
    CancelTimer(false)
  } Else If (wParam = 2) { ; track change
    CheckMusicBeePlayCount()
  } Else If (wParam = 3) { ; tooltip heartbeat
    RainmeterTooltipActive := true
    SetTimer, DisableRainmeterTooltip, off
  }
}

^/::
^?::
HelpText =
(
AHK hotkeys

td: Today's Date (Friday, 29 March 2013)
yd: Yesterday's Date (Thursday, 28 March 2013)
ts: TimeStamp (2013-03-29)
tt: Today+Time (2013-05-28T11-53)

htr: Home teaching message (Chrome only)

LWin: Show Wox (Ctrl+Shift+Alt+W)
Win+T: Set/cancel timer (15 by default, ctrl=2, shift=5)

Win+O: Lock workstation
Win+Shift+O (2x): Sign out
Ctrl+Alt+V: Paste clipboard text

Window commands:
Ctrl+Alt+A: Window on top
Ctrl+Alt+B: Hide window border
Ctrl+Alt+H: Hide window from taskbar
Win+Shift+R: Restore all windows
Win+H: Hide current window
Win+U: Unhide window
Win+W: Close current window
Win+N: Minimize current window

Media Keys:
F12: Play/Pause
F11: Next
F10: Previous
Ctrl+Shift+Right/Left: Forward/Back
Ctrl+Shift+Up/Down: Volume

Explorer:
Ctrl+Alt+H: Toggle hidden files
Ctrl+Alt+E: Toggle extensions

RDP (full-screen):
Ctrl+Alt+F: Toggle full-screen			

WriteMonkey:
Win+C: Reset word count
)
PlaceTooltip(HelpText, ,5000)
return

#IfWinActive LCWO ; cancel these hotstrings when I'm practicing Morse code

:b0:nd::
:b0:td::
:b0:yd::
:b0:ts::
:b0:tt::
return

#IfWinActive Inkscape ; let Inkscape get F1, ctrl+alt+v
~^!v::
~F1::
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

:b0?:/yd:: ; I bump into this when typing prices per yard of fabric ($25/yd)
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

::tt:: ; 2013-05-28T11-53 (kinda ISO standard)
FormatTime, CurrentDateTime,, yyyy-MM-ddTHH-mm
; FormatTime, CurrentDateTime,, dddd, d MMMM yyyy hh:mm tt
SendInput %CurrentDateTime%
SendRaw %A_EndChar%
return

; App-specific hotkeys

; ResophNotes
#IfWinActive ResophNotes
^e::^f

; WriteMonkey
#IfWinActive WriteMonkey
#c::Send !{F12} ; reset partial count
^p:: ; bring up pomodoro window
Send ^ep
Sleep, 100
If WinActive("plugin_blank")
  Send {Esc}
return

; RDP Window
#IfWinActive ahk_class TscShellContainerClass
^!f::Send ^!{CtrlBreak} ; toggle full-screen
return

; Full-screen RDP window
#If WinActive("ahk_class TscShellContainerClass") and IsFullScreen()
LAlt & Tab::Send {Blind}{PgUp} ; {blind} keeps the alt key down
#w::Send !{F4}
; LWin::Send !{Home}

; RDCMan
#If WinActive("Remote Desktop Connection Manager v")
LAlt & Tab::Send {Blind}{PgUp} ; {blind} keeps the alt key down
#w::Send !{F4}

; Chrome
#IfWinActive ahk_class Chrome_WidgetWin_1
^O::return

; Skype for Business
#IfWinActive ahk_class LyncConversationWindowClass
^Enter::Send {Enter} ; Instead of starting video chat

; Notepad
#IfWinActive ahk_class Notepad
^Backspace::Send +^{Left}{Backspace}

; Outlook
#IfWinActive ahk_class rctrl_renwnd32
$F6::Send ^+1 ; One-key archive
$F7::Send ^+2

; FamilySearch
#IfWinActive FamilySearch Indexing
Space::Tab
Tab::Space
#IfWinActive

; Windows Explorer
#IfWinActive ahk_class CabinetWClass

^!h:: ; Toggle hidden files
RegRead, HiddenFiles_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden
HiddenFiles_Status := HiddenFiles_Status = 1 ? 2 : 1 ; toggle
RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, %HiddenFiles_Status%
Send, {F5}
State_Word := HiddenFiles_Status = 1 ? "shown" : "hidden"
PlaceTooltip("Hidden files " State_Word " (Ctrl+Alt+H)", "Window")
Return

^!e:: ; Toggle extensions
RegRead, Ext_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt
Ext_Status := Ext_Status = 1 ? 0 : 1 ; toggle
RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, %Ext_Status%
Send, {F5}
State_Word := Ext_Status = 0 ? "shown" : "hidden"
PlaceTooltip("File extensions " State_Word " (Ctrl+Alt+E)", "Window")
Return

; Save and reload ahk if currently editing
#ifwinactive Mine.ahk
^s::
send ^s ; save the script
PlaceTooltip("Reloading script...")
SetTimer,ReloadScript,-1000
return

ReloadScript:
Reload
return

; Save and reload rainmeter if currently editing
#IfWinActive .ini
^s::
WinGetTitle, Title, A
RegExMatch(Title, "((?:\w| )+)\\(?:\w| )+\.ini", SubPat)
If (SubPat = "")
{
    return
}
PlaceTooltip("Reloading rainmeter skin " SubPat1 "...")
send ^s ; save the script
SendRainmeterCommand("[!Refresh """ SubPat1 """]")
return

; Product Studio
#IfWinActive ahk_class PSWnd
^Backspace::Send +^{Left}{Backspace}
^Enter::Send {F5}
^w::Send ^{F4}

; ctrl+v paste in cmd prompt
#IfWinActive ahk_class ConsoleWindowClass
^V::SendInput {Raw}%clipboard%

; MediaPlayerClassic (takes over media next/prev for voice notes)
#IfWinExist ahk_class MediaPlayerClassicW

Media_Next::
Media_Play_Pause & 0::
Media_Play_Pause & PgUp::
$F11::ControlSend,,{PgDn},ahk_class MediaPlayerClassicW

Media_Prev::
+Media_Next::
Media_Play_Pause & 9::
Media_Play_Pause & PgDn::
$F10::ControlSend,,{PgUp},ahk_class MediaPlayerClassicW

; MusicBee
#If WinExist("MusicBee") && (MB_GetPlayState() != MBPS_Stopped)
Pause & ScrollLock::Send {Media_Next}
Pause & PrintScreen::Send {Media_Prev}

Media_Play_Pause::
SetErgodoxConnected()
F12::
Pause::MB_PlayPause()

Media_Next::
F11::MB_NextTrack()

Media_Prev::
+Media_Next::
F10::
+F11::MB_PreviousTrack()

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

; StreamKeys
#IfWinExist ahk_class Chrome_WidgetWin_1
Media_Play_Pause::Send +!{Home}
Media_Next::Send +^{PgDn}
+Media_Next::
Media_Prev::Send +^{PgUp}

; Show launchers
#IfWinActive
LWin & =:: ; used to make LWin a Prefix key; see http://www.autohotkey.com/docs/Hotkeys.htm
           ; without this, the windows key doesn't work for other shortcuts like it should!

#IfWinExist ahk_exe Launchy.exe
LWin::Send !{F10}

#IfWinExist ahk_exe Executor.exe
LWin::Send ^!+#w

#IfWinExist ahk_exe Wox.exe
LWin::Send ^!+#w

; Disable generally annoying hotkeys
#IfWinActive
; #u::return ; disable narrator (turned off because I've included explicit #u below for unhide)
#Enter::return ; other narrator
#F16::return ; can't believe this is a problem, but disable shutdown swipe

$F1::
if (WinActive("Inkscape") or WinActive("Q10") or WinActive("ahk_class VICE"))
  Send {F1}
else
  PlaceTooltip("F1 blocked. Try Shift+F1 if you really want it.")
return

+F1::Send {F1}

; Left-handed lock on Dvorak
#o::
LockWorkStation() {
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

#u::
goto mwt_UnMinimize

#h::
goto mwt_Minimize

; Sign out (hit it twice)
#+o::
if (SignOutStarted <> 1) {
  PlaceTooltip("Sign-out started; press it again to do it...")
  SignOutStarted := 1
  SetTimer,ResetSignOut,-1500
} else {
  PlaceTooltip("Signing out...")
  Sleep, 200
  SendMessage,0x112,0xF170,2,,Program Manager ; turn off monitor
  Shutdown, 0
}
return

ResetSignOut:
SignOutStarted = 0
return

#IfWinActive

; Window commands

#w::PostMessage, 0x112, 0xF060,,, A, ; 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE
#q::Send !{F4}
#n::WinMinimize, A

; Toggle always-on-top
^!a::
Winset, Alwaysontop, , A
WinGet, ExStyle, ExStyle, A
winistop := (ExStyle & 0x8) ; 0x8 is WS_EX_TOPMOST.
PlaceTooltip("Window " (winistop ? "" : "no longer ") "on top (Ctrl+Alt+A)", "Window")
return

; Toggle window border
^!b::
id := WinExist("A")
Winset, Style, ^0xC00000, A ; 0xC00000 = WS_CAPTION
WinGet, Style, Style, A
winisborder := (Style & 0xC00000) ; 0xC00000 = WS_CAPTION
PlaceTooltip("Window " (winisborder ? "no longer " : "") "unbordered (Ctrl+Alt+B)", "Window")
; Toggle Sizebox only if it starts with Sizebox
appwindowtoggle := (Style & 0x40000) || WinHasSizeBox_%id% ; 0x40000 = WS_SizeBox
if (appwindowtoggle) {
  WinHasSizeBox_%id% := appwindowtoggle
  WinSet, Style, ^0x40000, A ; 0x40000 = WS_SizeBox
  ; PlaceTooltip("Window has/had sizebox; state saved/restored", "Window")
}
return

; Hide a window from the taskbar
^!h::
Send {LControl Up}{LAlt Up}
; Setting Toolwindow is easy; we just assume that no windows have that set by default
WinHide, A
WinSet, ExStyle, ^0x80, A ; 0x80 = WS_EX_TOOLWINDOW
WinGet, ExStyle, ExStyle, A
winisvisible := (ExStyle & 0x80) ; 0x80 = WS_EX_TOOLWINDOW
PlaceTooltip("Window " (winisvisible ? "" : "no longer ") "hidden from the taskbar and alt-tab list(Ctrl+Alt+H)", "Window")
; Setting AppWindow appropriately is harder and requires state
id := WinExist("A")
appwindowtoggle := (ExStyle & 0x40000) || WinIsAppWindow_%id% ; 0x40000 = WS_EX_APPWINDOW
if (appwindowtoggle) {
  WinIsAppWindow_%id% := appwindowtoggle
  WinSet, ExStyle, ^0x40000, A ; 0x40000 = WS_EX_APPWINDOW
  ; PlaceTooltip("Window was/is app window; state saved/restored", "Window")
}
WinShow, A
return

^!c::
WinGet, ExStyle, ExStyle, A
WinGet, Style, Style, A
PlaceTooltip("Window style: " ExStyle ", " Style)
return 

; Raw paste
^!v::
clipboardastext=%clipboard%
send {raw}%clipboardastext%
return

#+r:: ; Restore all windows
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

; Timer
#^t:: ; Set 2-minute timer
StartTimer(2*60,, "e69124ff")
return

#+t:: ; Set 5-minute timer
StartTimer(5*60,, "6d98a1fft")
return

#t:: ; Set 15-minute timer
StartTimer(15*60,, "c5472aff", 1)
return

StartTimer(Seconds, EventFromAHK = true, ByRef Color = "4,192,64,255", TimerCount = 0)
{
  global TimerActiveStart
  
  if (TimerActiveStart and EventFromAHK) { ; cancel existing timer
    CancelTimer(true)
    return
  }

  TimerActiveStart := A_TickCount
  If (EventFromAHK) {
    If (mod(Seconds,60) = 0) {
      PrettyTime := Seconds // 60 " minutes"
    } Else {
      T = 20000101000000
      T += Seconds, Seconds
      FormatTime PrettyTime, %T%, mm:ss
    }
    PlaceTooltip("Timer set for " PrettyTime ".")
    SoundPlay, alarmstart.wav
    SendRainmeterCommand("!CommandMeasure MeasureTimerScript ""StartTimerAPI('" Seconds / 60 "','" Color "'," TimerCount ")"" MinimalTimer")
    delay := -1000*(Seconds)
    SetTimer, TimerEnd, %delay%
  } else { ; Rainmeter started a new timer: cancel any existing AHK timer
    SetTimer, TimerEnd, off
  }
  SetIconState("timer", "Timer set for " PrettyTime)
}

CancelTimer(EventFromAHK = true) {
  global TimerActiveStart

  If (EventFromAHK) { ; user-initiated cancel
    SendRainmeterCommand("!CommandMeasure MeasureTimerScript ""StartTimerAPI('-1','0','0')"" MinimalTimer")
    SoundPlay, alarmcancel.wav
    Duration := (A_TickCount - TimerActiveStart) / 1000
    T = 20000101000000
    T += Duration, Seconds
    FormatTime FormdT, %T%, mm:ss
    PlaceTooltip("Timer canceled after " FormdT)
    SetTimer, TimerEnd, off
  }
  TimerActiveStart = 0
  SetIconState("timer", false)
}

TimerEnd:
PlaceTooltip("Time's up!", , 3000)
SoundPlay, alarmsound.wav
TimerActiveStart = 0
SetIconState("timer", false)
return

CheckMusicBeePlayCount() {
  PlayCount := MB_GetFileProperty(MBFP_PlayCount)
  ; PlaceToolTip("PlayCount: " PlayCount)
  SendRainmeterCommand("[!SetVariable NowPlayingPlayCount " PlayCount "][!UpdateMeasure mPlayCount NowPlaying]")
  SkipCount := MB_GetFileProperty(MBFP_SkipCount)
  SendRainmeterCommand("[!SetVariable NowPlayingSkipCount " SkipCount "][!UpdateMeasure mSkipCount NowPlaying]")
}

; Ergodox special keys
F14::Send μ
+F14::Send Μ
F15::Send λ
+F15::Send Λ
F18::Send ♯
+F18::Send ♭
F16::Send α
+F16::Send Α
^F16::Send ∫
F17::Send ∞
^+8::
+NumpadMult::Send ×

F24::ChangePloverStatus(true)

F23::
Suspend, Off
ChangePloverStatus(false)
return

ChangePloverStatus(state) {
  DesiredState := (state ? "Enable" : "Disable")
  ControlClick, %DesiredState%, Plover ahk_class wxWindowNR
  UpdatePloverWindowStatus()
}

+F24:: ;plover re-start
+F23::
If (WinExist("Plover ahk_class wxWindowNR")) {
  WinClose,,,5
}
LaunchPlover()
return

#^r:: ; Reload
PlaceTooltip("Reloading script...")
SetTimer,ReloadScript,-1000
return

; Get rid of Win+Tab, replace it with the more helpful and conventional Alt+Tab
LWin & Tab::AltTab

; Model M stuff (I've remapped the LAlt to a LWin, and RAlt to LAlt)
; RCtrl::LWin
; ScrollLock::LWin
; LCtrl & LWin::Send {Alt Down}
; LCtrl & LWin Up::Send {Alt Up}

SetErgodoxConnected()
{
  global ErgodoxState
  If (ErgodoxState <> true) {
    ; PlaceTooltip("Noticed Ergodox. Setting keys right." ErgodoxState)
    ErgodoxState := true
    Hotkey, If, WinExist("MusicBee") && (MB_GetPlayState() != MBPS_Stopped)
    Hotkey, F12, Off
    Hotkey, F11, Off
    Hotkey, F10, Off
    ; If Ergodox, we're probably using the USB DAC; no volume control necessary
    Hotkey, ^!Up, Off
    Hotkey, ^!Down, Off
  }
}

LaunchOrHidePlover() {
If (!WinExist("Plover ahk_class wxWindowNR")) {
  LaunchPlover()
} else {
  SetTimer, HidePlover, -10
}
}

LaunchPlover() {
If (!WinExist("Plover ahk_class wxWindowNR")) {
  ; PlaceToolTip("No Plover found; launching...", , 3000)
  global HidePloverOnNextLaunch
  HidePloverOnNextLaunch := true
  Run, ..\Plover\plover.exe
}
}

HidePlover() {
If (WinExist("Plover ahk_class wxWindowNR")) {
  HideWindow("Plover ahk_class wxWindowNR")
}
}

UpdatePloverWindowStatus:
UpdatePloverWindowStatus()
return

UpdatePloverWindowStatus() {
  static PloverLastStatus = 0
  ControlGet, PloverCurrentStatus, Checked, , Enable, Plover ahk_class wxWindowNR
  PloverCurrentStatus := (PloverCurrentStatus = 1) ? -1 : ErrorLevel ? 0 : 1
  If (PloverCurrentStatus != PloverLastStatus) { ; state change 
    If ((PloverCurrentStatus = -1) != (A_IsSuspended))
      Suspend ; suspend hotkeys when Plover running
    SendRainmeterCommand("[!SetVariable IndicatorState " PloverCurrentStatus "][!Update PloverStatus]")
    SetIconState("plover", (PloverCurrentStatus = -1 ? "Plover input enabled" : false))
    PloverLastStatus := PloverCurrentStatus
    ; PlaceTooltip("Plover status: " PloverCurrentStatus)
  }
}

#c::
TrayTip, , Hi!
return

RCtrl & RButton::
TakeScreenshot() {
global UserProfile
CoordMode, Mouse, Screen
MouseGetPos, begin_x, begin_y
DrawRectangle(true)
SetTimer, rectangle, 10
KeyWait, RButton

SetTimer, rectangle, Off
Gui, ScreenshotSelection:Cancel
MouseGetPos, end_x, end_y

Capture_x := (end_x < begin_x) ? end_x : begin_x
Capture_y := (end_y < begin_y) ? end_y : begin_y
Capture_width := Abs(end_x - begin_x)
Capture_height := Abs(end_y - begin_y)

area := Capture_x . "|" . Capture_y . "|" . Capture_width . "|" Capture_height ; X|Y|W|H 

FormatTime, CurrentDateTime,, yyyy-MM-ddTHH-mm-ss

filename := UserProfile "\downloads\screenshot " CurrentDateTime ".png"

Screenshot(filename,area)
return
}

rectangle:
DrawRectangle()
return

DrawRectangle(startNewRectangle := false) {
static lastX, lastY
static xorigin, yorigin
global x1, y1, x2, y2

if (startNewRectangle) {
  MouseGetPos, xorigin, yorigin
}

CoordMode, Mouse, Screen
MouseGetPos, currentX, currentY

; Has the mouse moved?
if (lastX lastY) = (currentX currentY)
return

lastX := currentX
lastY := currentY

; Allow dragging to the left of the click point.
if (currentX < xorigin) {
x1 := currentX
x2 := xorigin
} else {
x1 := xorigin
x2 := currentX
}

; Allow dragging above the click point.
if (currentY < yorigin) {
y1 := currentY
y2 := yorigin
} else {
y1 := yorigin
y2 := currentY
}

Gui, ScreenshotSelection:Show, % "NA X" x1 " Y" y1 " W" x2-x1 " H" y2-y1
Gui, ScreenshotSelection:+LastFound
}

+F13::MouseClickTurboToggle(true) ; shift Space invader key

F13:: ; Space invader key
MouseClickTurboToggle(autoclick = false) {
  global MouseClickTurbo 
  MouseClickTurbo := !MouseClickTurbo
  If (!MouseClickTurbo) {
    SetTimer, MouseClickTurboClick, Off
  }
  If (MouseClickTurbo && autoclick) {
    SetTimer, MouseClickTurboClick, 100
  }
  PlaceToolTip("Mouse click turbo mode " (MouseClickTurbo ? "on" : "off"), "Cursor")
}

#If MouseClickTurbo

LButton::
Click
SetTimer, MouseClickTurboClick, 100
return

LButton Up::
SetTimer, MouseClickTurboClick, Off
return

MouseClickTurboClick:
Click
return

Screenshot(outfile, screen) {
pToken := Gdip_Startup()
raster := 0x40000000 + 0x00CC0020 ; get layered windows

pBitmap := Gdip_BitmapFromScreen(screen,raster)

Gdip_SetBitmapToClipboard(pBitmap)
Gdip_SaveBitmapToFile(pBitmap, outfile)
Gdip_DisposeImage(pBitmap)
Gdip_Shutdown(pToken)

PlaceTooltip("Screenshot copied and saved.")
}

; Helper functions

SetIconState(name = "timer", state = false) {
  global IconStateArray
  IconStateArray[name] := state
  for key, value in IconStateArray {
    if (value) {
      Menu, Tray, Icon, %key%.ico, , 1 ; freeze
      Menu, Tray, Tip, %value%
      return
    }
  }
  ; otherwise, reset tray icon and tooltip to default
  Menu, Tray, Icon, icon.ico
  Menu, Tray, Tip, Autohotkey`, here making your life easier
}

IsFullScreen() {
  WinGet, Style, Style, A ; active window
  return !(Style & 0x40000) ; 0x40000 = WS_SIZEBOX
}

; Tooltip
PlaceTooltip(byref text, location="Screen", delay=1000)
{
  global RainmeterTooltipActive
  delay := delay = -1 ? "off" : -delay
	if (location="Window") {
		WinGetPos, X, Y, W, H, A
		X += W / 2
		Y += H / 2
	} else if (location="Cursor") { 
		CoordMode, Mouse, Screen
		MouseGetPos, X, Y
	} else if (location="Screen") { 
		x := A_ScreenWidth - 180
		Y := A_ScreenHeight - 80
	}
  if (RainmeterTooltipActive) {
    SendRainmeterCommand("[!SetVariable Alignment """ location """ Tooltip][!SetVariable AlignmentX """ X """ Tooltip][!SetVariable AlignmentY """ Y """ Tooltip]")
    SendRainmeterCommand("[!SetVariable Message """ text """ Tooltip][!CommandMeasure ActionTimerShowFade ""Execute 2"" Tooltip]")
    SetTimer,ToolTipOffRainmeter,%delay%
    return
  } else {
    CoordMode, ToolTip, Screen
    ToolTip, % text, X, Y
    SetTimer,ToolTipOff,%delay%
  }
}

CheckRainmeterTooltipHeartbeat() {
  SendRainmeterCommand("[!CommandMeasure MeasureAhkWindowMessaging ""SendMessage 16687 3 0"" Tooltip]")
  SetTimer, DisableRainmeterTooltip, -1000 ; must be less than the heartbeat cadence
}

DisableRainmeterTooltip:
RainmeterTooltipActive := false
return

ToolTipOffRainmeter:
SendRainmeterCommand("[!CommandMeasure ActionTimerShowFade ""Execute 1"" Tooltip]")
return

ToolTipOff:
ToolTip
return

; Check if sound is being output
IsMusicPlaying() {
audioMeter := VA_GetAudioMeter()
VA_IAudioMeterInformation_GetMeteringChannelCount(audioMeter, channelCount)
VA_GetDevicePeriod("capture", devicePeriod)
VA_IAudioMeterInformation_GetPeakValue(audioMeter, peakValue)    
return (peakValue > 0.01)
}

SendRainmeterCommand(ByRef command) {
  Send_WM_COPYDATA(command, "DummyRainWClass")
}

Send_WM_COPYDATA(ByRef StringToSend, ByRef TargetWindowClass)  ; ByRef saves a little memory in this case.
; This function sends the specified string to the specified window and returns the reply.
; Cribbed from https://www.autohotkey.com/docs/commands/OnMessage.htm
{
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  ; Set up the structure's memory area.
    ; First set the structure's cbData member to the size of the string, including its zero terminator:
    SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(1, CopyDataStruct) ; Per example at https://docs.rainmeter.net/developers/
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)  ; OS requires that this be done.
    NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)  ; Set lpData to point to the string itself.
    SendMessage, 0x4a, 0, &CopyDataStruct,, ahk_class %TargetWindowClass%  ; 0x4a is WM_COPYDATA. Must use Send not Post.
    return ErrorLevel  ; Return SendMessage's reply back to our caller.
}
