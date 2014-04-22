#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#include lib/MusicBeeIPC
#include MusicBeeIPC.ahk

msg := "MusicBee Version: " . MB_GetMusicBeeVersionStr()
msg .= "`r`rMusicBeeIPC Version: " . MB_GetPluginVersionStr()

MsgBox,, Version, % msg

MsgBox,, Artist, % MB_GetFileTag(MBMD_Artist)

MsgBox,, Track Title, % MB_GetFileTag(MBMD_TrackTitle)

MsgBox,, Play State, % MB_GetPlayStateStr()

MsgBox,, Current Index, % MB_GetCurrentIndex()

; InputBox, jump, "Jump To", "Jump to:"
; MB_Jump(jump)

MB_Search("You", result)
msg := "Songs containing the keyword ""You"":`r"
for key, value in result
    msg .= value . "`r"

MsgBox,, Search Result, % msg

fields := ["Year"]

MB_SearchEx("2012", "Is", fields, result)
msg := "Songs released in the year 2012:`r"
for key, value in result
    msg .= value . "`r"

MsgBox,, Search Result, % msg

MsgBox,, Item Count, % "Number of items in the now playing list: " . MB_NowPlayingList_GetItemCount()

ExitApp, 0
