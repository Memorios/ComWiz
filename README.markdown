This is just a custom modification of VirtualDesktopAccessor by  Ciantic to create functions like the linux desktop manager Compiz
This is my custom set, it's easy to create, select and navigate to other virtual desktops, with mouse or hotkey

Mouse Triggers:
RButton::#^Right	;Right click on desktop right edge = Next Desktop	
LButton::#^Left		;Left click on desktop right edge = Prev Desktop
MButton::#Tab		;middle click on desktop right edge to opens task view (to see All Virtual Desktops)
WheelDown::#^Right	;roll down mouse wheel on desktop right edge = Next Desktop
WheelUp::#^Left	;roll up mouse wheel on desktop right edge = Prev Desktop

HotKeys: 
Windows key + `  will create a new Virtual Desktop Next to current one
Windows key + esc will remove and merge current desktop

Windows key + 1  Will open desktop 1
Windows key + 2  Will go to desktop 2
Windows key + 3  Will open desktop 3
Windows key + 4  Will open desktop 4

Windows key + Q  Will move current window to desktop 1
Windows key + W  Will move current window to desktop 2
Windows key + Z  Will move current window to desktop 3
Windows key + C  Will move current window to desktop 4

There are some bugs in newer Windows 10 version, I'm not a professional coder, so if you want help me to fix them.
Personally I added some other functions for my personal use, feel free to change or remove them and recompile the ahk file

*You need to have VirtualDesktopAccessor.dll in the same folder as .ahk or compiled version, otherwise hotkeys wont work

------------------------------------------

This is based on VirtualDesktopAccessor.dll

DLL for accessing Windows 10 (tested with 1809 build 17663) Virtual Desktop features from e.g. AutoHotkey. MIT Licensed, see LICENSE.txt (c) Jari Pennanen, 2015-2018

Download the VirtualDesktopAccessor.dll from directory x64\Release\VirtualDesktopAccessor.dll in the repository. This DLL works only on 64 bit Windows 10.

You probably first need the [VS 2017 runtimes vc_redist.x64.exe and/or vc_redist.x86.exe](https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads), if they are not installed already. I've built the DLL using VS 2017, and Microsoft is not providing those runtimes (who knows why) with Windows 10 yet.
