#Include lib
#Include xinput.ahk
; Example: Control the vibration motors using the analog triggers of each controller.
XInput_Init()
Loop {
    Loop, 4 {
        if State := XInput_GetState(A_Index-1) {
            Buttons := State.wButtons
            LT := State.bLeftTrigger
            RT := State.bRightTrigger
            XButton := Buttons & XINPUT_GAMEPAD_X
            XInput_SetState(A_Index-1, 0, Buttons ? 65535 : 0)
            if (Buttons > 0) {
                PlaceTooltip(Buttons)
            }
        }
    }
    Sleep, 10
}

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

