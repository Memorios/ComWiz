#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
;#NoTrayIcon
;#SingleInstance force
;#KeyHistory 0
;#InstallKeybdHook
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;Main Desktop Selector Script
DetectHiddenWindows, On
hwnd:=WinExist("ahk_pid " . DllCall("GetCurrentProcessId","Uint"))
hwnd+=0x1000<<32

hVirtualDesktopAccessor := DllCall("LoadLibrary", Str, "C:\Apps\AutoHotkey\Scripts\VirtualDesktopAccessor\VirtualDesktopAccessor.dll", "Ptr") 
GoToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GoToDesktopNumber", "Ptr")
GetCurrentDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetCurrentDesktopNumber", "Ptr")
IsWindowOnCurrentVirtualDesktopProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "IsWindowOnCurrentVirtualDesktop", "Ptr")
MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "MoveWindowToDesktopNumber", "Ptr")
RegisterPostMessageHookProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "RegisterPostMessageHook", "Ptr")
UnregisterPostMessageHookProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "UnregisterPostMessageHook", "Ptr")
IsPinnedWindowProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "IsPinnedWindow", "Ptr")
RestartVirtualDesktopAccessorProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "RestartVirtualDesktopAccessor", "Ptr")
; GetWindowDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetWindowDesktopNumber", "Ptr")
activeWindowByDesktop := {}

; Restart the virtual desktop accessor when Explorer.exe crashes, or restarts (e.g. when coming from fullscreen game)
explorerRestartMsg := DllCall("user32\RegisterWindowMessage", "Str", "TaskbarCreated")
OnMessage(explorerRestartMsg, "OnExplorerRestart")
OnExplorerRestart(wParam, lParam, msg, hwnd) {
    global RestartVirtualDesktopAccessorProc
    DllCall(RestartVirtualDesktopAccessorProc, UInt, result)
}

MoveCurrentWindowToDesktop(number) {
	global MoveWindowToDesktopNumberProc, GoToDesktopNumberProc, activeWindowByDesktop
	WinGet, activeHwnd, ID, A
	activeWindowByDesktop[number] := 0 ; Do not activate
	DllCall(MoveWindowToDesktopNumberProc, UInt, activeHwnd, UInt, number)
	DllCall(GoToDesktopNumberProc, UInt, number)
}

GoToPrevDesktop() {
	global GetCurrentDesktopNumberProc, GoToDesktopNumberProc
	current := DllCall(GetCurrentDesktopNumberProc, UInt)
	if (current = 0) {
		GoToDesktopNumber(7)
	} else {
		GoToDesktopNumber(current - 1)      
	}
	return
}

GoToNextDesktop() {
	global GetCurrentDesktopNumberProc, GoToDesktopNumberProc
	current := DllCall(GetCurrentDesktopNumberProc, UInt)
	if (current = 7) {
		GoToDesktopNumber(0)
	} else {
		GoToDesktopNumber(current + 1)    
	}
	return
}

GoToDesktopNumber(num) {
	global GetCurrentDesktopNumberProc, GoToDesktopNumberProc, IsPinnedWindowProc, activeWindowByDesktop

	; Store the active window of old desktop, if it is not pinned
	WinGet, activeHwnd, ID, A
	current := DllCall(GetCurrentDesktopNumberProc, UInt) 
	isPinned := DllCall(IsPinnedWindowProc, UInt, activeHwnd)
	if (isPinned == 0) {
		activeWindowByDesktop[current] := activeHwnd
	}

	; Try to avoid flashing task bar buttons, deactivate the current window if it is not pinned
	if (isPinned != 1) {
		WinActivate, ahk_class Shell_TrayWnd
	}

	; Change desktop
	DllCall(GoToDesktopNumberProc, Int, num)
	return
}

; Windows 10 desktop changes listener
DllCall(RegisterPostMessageHookProc, Int, hwnd, Int, 0x1400 + 30)
OnMessage(0x1400 + 30, "VWMess")
VWMess(wParam, lParam, msg, hwnd) {
	global IsWindowOnCurrentVirtualDesktopProc, IsPinnedWindowProc, activeWindowByDesktop

	desktopNumber := lParam + 1
	
	; Try to restore active window from memory (if it's still on the desktop and is not pinned)
	WinGet, activeHwnd, ID, A 
	isPinned := DllCall(IsPinnedWindowProc, UInt, activeHwnd)
	oldHwnd := activeWindowByDesktop[lParam]
	isOnDesktop := DllCall(IsWindowOnCurrentVirtualDesktopProc, UInt, oldHwnd, UInt)
	if (isOnDesktop == 1 && isPinned != 1) {
		WinActivate, ahk_id %oldHwnd%
	}

	; Menu, Tray, Icon, Icons/icon%desktopNumber%.ico
	
	; When switching to desktop 1, set background pluto.jpg
	; if (lParam == 0) {
		; DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, "C:\Users\Jarppa\Pictures\Backgrounds\saturn.jpg", UInt, 1)
	; When switching to desktop 2, set background DeskGmail.png
	; } else if (lParam == 1) {
		; DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, "C:\Users\Jarppa\Pictures\Backgrounds\DeskGmail.png", UInt, 1)
	; When switching to desktop 7 or 8, set background DeskMisc.png
	; } else if (lParam == 2 || lParam == 3) {
		; DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, "C:\Users\Jarppa\Pictures\Backgrounds\DeskMisc.png", UInt, 1)
	; Other desktops, set background to DeskWork.png
	; } else {
		; DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, "C:\Users\Jarppa\Pictures\Backgrounds\DeskWork.png", UInt, 1)
	; }
}

; Switching desktops:
; Win + Ctrl + 1 = Switch to desktop 1
#1::GoToDesktopNumber(0)

; Win + Ctrl + 2 = Switch to desktop 2
#2::GoToDesktopNumber(1)
#3::GoToDesktopNumber(2)
#4::GoToDesktopNumber(3)
; Moving windowes:
; Win + Shift + 1 = Move current window to desktop 1, and go there
#Q::MoveCurrentWindowToDesktop(0)
#W::MoveCurrentWindowToDesktop(1)
#Z::MoveCurrentWindowToDesktop(2)
#C::MoveCurrentWindowToDesktop(3)


; This function creates a new virtual desktop and switches to it
;
createVirtualDesktop()
{
 global CurrentDesktop, DesktopCount
 Send, #^d
}
;
; This function deletes the current virtual desktop
;
deleteVirtualDesktop()
{
 global CurrentDesktop, DesktopCount
 Send, #^{F4}
}

LWin & `::createVirtualDesktop()
LWin & esc::deleteVirtualDesktop()

; Mouse edge Touch
#If MouseIsTouchScreenRight()
RButton::#^Right	;Right click on right edge = Next Desktop	
LButton::#^Left		;Left click on right edge = Prev Desktop
MButton::#Tab		;middle click on right edge opens task view
WheelDown::#^Right	;Right click on right edge = Next Desktop
WheelUp::#^Left		;Left click on right edge = Prev Desktop
#If

MouseIsTouchScreenRight() {
    CoordMode, Mouse, Screen ;set coordinates mode to be relative to the whole screen
    MouseGetPos, mX ;store the X coordinate of the mouse in `mX`
    if ( abs(A_ScreenWidth-mX) <= 2 ) ;if the "absolute" difference is within 2 pixels
        return true
    return false
}

#WheelDown::
{
	Send, #^{Right}
	Return
}
#WheelUp::
{
	Send, #^{Left}
	Return
}
NumpadIns & Right::
{
	Send, #^{Right}
	Return
}
NumpadIns & Left::
{
	Send, #^{Left}
	Return
}

Pause::
Suspend
Pause, , 1
return
>+Pause::ExitApp
; Set Lock keys permanently
SetCapsLockState, AlwaysOff
SetScrollLockState, AlwaysOff
return
; Turn Caps Lock into a Shift key
Capslock::Shift
return
; Always on Top
AppsKey:: Winset, Alwaysontop, , A ; RightAlt
Return
#f::Run Firefox

NumpadDiv::
	VarSetCapacity(StatePtr, 36, 0)
	DllCall("Shell32.dll\SHGetSetSettings", "Ptr", &StatePtr, "UInt", 1, "Int", 0)
	StateVal := NumGet(StatePtr, "UInt")
	If StateVal = 0
		NumPut(1, StatePtr, "UInt")
	Else
		NumPut(0, StatePtr, "UInt")
	DllCall("Shell32.dll\SHGetSetSettings", "Ptr", &StatePtr, "UInt", 1, "Int", 1)
Return

;Alt+Click to move windows
Alt & LButton::
CoordMode, Mouse  ; Switch to screen/absolute coordinates.
MouseGetPos, EWD_MouseStartX, EWD_MouseStartY, EWD_MouseWin
WinGetPos, EWD_OriginalPosX, EWD_OriginalPosY,,, ahk_id %EWD_MouseWin%
WinGet, EWD_WinState, MinMax, ahk_id %EWD_MouseWin% 
if EWD_WinState = 0  ; Only if the window isn't maximized 
    SetTimer, EWD_WatchMouse, 10 ; Track the mouse as the user drags it.
return

EWD_WatchMouse:
GetKeyState, EWD_LButtonState, LButton, P
if EWD_LButtonState = U  ; Button has been released, so drag is complete.
{
    SetTimer, EWD_WatchMouse, off
    return
}
GetKeyState, EWD_EscapeState, Escape, P
if EWD_EscapeState = D  ; Escape has been pressed, so drag is cancelled.
{
    SetTimer, EWD_WatchMouse, off
    WinMove, ahk_id %EWD_MouseWin%,, %EWD_OriginalPosX%, %EWD_OriginalPosY%
    return
}
; Otherwise, reposition the window to match the change in mouse coordinates
; caused by the user having dragged the mouse:
CoordMode, Mouse
MouseGetPos, EWD_MouseX, EWD_MouseY
WinGetPos, EWD_WinX, EWD_WinY,,, ahk_id %EWD_MouseWin%
SetWinDelay, -1   ; Makes the below move faster/smoother.
WinMove, ahk_id %EWD_MouseWin%,, EWD_WinX + EWD_MouseX - EWD_MouseStartX, EWD_WinY + EWD_MouseY - EWD_MouseStartY
EWD_MouseStartX := EWD_MouseX  ; Update for the next timer-call to this subroutine.
EWD_MouseStartY := EWD_MouseY
return

;Lock and Turnoff Monitor
end::
{
Sleep, 200
DllCall("LockWorkStation")
Sleep, 200
SendMessage,0x112,0xF170,2,,Program Manager
}
return

;TurnFilterOn
NumpadClear::
{
	Send #^c
	Return
}

;TurnOn Magnifier
NumpadEnd::
{
	Send, {Blind}#{NumPadAdd}
	Return
}


