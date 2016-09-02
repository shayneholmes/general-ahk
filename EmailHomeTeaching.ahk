#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Greeting =
(%
Hey %Name%,

%SeasonalGreeting%It's that time of the month again: Which of your home teaching families did you visit in %Month%? As a reminder, your home teaching families are:

%Families%

Did any of your families have needs that we can help with?

Thanks,

Shayne
)

InitializeVariables()
GenerateEmails()
CreateUI()
AdvanceMail()
UpdateUI()
return

InitializeVariables() {
global
; Get config information from file
local Params := Object()
VariablesSet := false
Loop, read, emailaccountinfo.tsv
{
  Loop, Parse, A_LoopReadLine, %A_Tab%
  {
    VariablesSet := true
    Params.Insert(A_LoopField)
  }
  FromAddress := Params[1]
  Username := Params[2]
  Password := Params[3]
}
if !(VariablesSet) {
  MsgBox, No email account info found!`nPlace email account in emailaccountinfo.tsv.
  ExitApp
}
}

GenerateEmails() {
global
; Monthly items
local Date := A_Now
Date += -25, days
FormatTime, Month, %Date%, MMMM
; Month := "July" ; optional override
SeasonalGreeting := ""
If (Month == "June") {
  SeasonalGreeting := "Happy Independence Day (almost){!} " ; optional seasonal stuff
}
; Transform from .txt file into emails
Emails := Object()
HtArray := Object()
Loop, read, htnames.txt
{
  ; Parse an entry
  OneEntry := Object()
  Loop, Parse, A_LoopReadLine, %A_Tab%
  {
    OneEntry.Insert(A_LoopField)
  }
  Name := OneEntry[1]
  LastName := OneEntry[2]
  Email := OneEntry[3]
  Families := OneEntry[4]
  StringReplace, Families, Families, /, `n, All

  ; Turn it into an email
  OneEmail := Object()
  OneEmail["ToAddress"] := Email
  OneEmail["Subject"] := "Home teaching in " Month "?"
  Transform, Body, Deref, %Greeting% ; expand variables dynamically
  OneEmail["Body"] := Body
    
  Emails.Insert(OneEmail)
}
CurrentMail_enum := Emails._NewEnum()
}

CreateUI() {
global
Gui, New,, Email sender v0.01 by Shayne Holmes
Gui, Add, Edit, vToAddress w600
Gui, Add, Edit, vSubject w600
Gui, Add, Edit, vBody h600 w600 VScroll
Gui, Add, Button, gSend Section, Send
Gui, Add, Button, gShowNextMail ys, Skip
}

UpdateUI() {
global
ToAddress := CurrentMail["ToAddress"]
Subject := CurrentMail["Subject"]
Body := CurrentMail["Body"]
GuiControl, Text, ToAddress, %ToAddress%
GuiControl, Text, Subject, %Subject%
GuiControl, Text, Body, %Body%
Gui, Show
}

AdvanceMail() {
global
if IsObject(CurrentMail_enum)
{
  if !(CurrentMail_enum.Next(Key, CurrentMail))
  {
    Gui, Hide
    MsgBox, , Email sender, All done! Click to exit.
    ExitApp
  }
  UpdateUI()
}
}

SendMail() {
global
Run, mailsend.exe -to %ToAddress% -from %FromAddress% -ssl -smtp smtp.gmail.com -port 465 -sub "%Subject%" -M "%Body%" +cc +bc -q -auth-plain -user "%Username%" -pass "%Password%",, Hide
Tooltip, Message sent to %ToAddress%.
SetTimer, RemoveToolTip, -1000
return
}

Send:
Gui, Submit, NoHide
SendMail()
AdvanceMail()
return

ShowNextMail:
Tooltip, %ToAddress% skipped.
SetTimer, RemoveToolTip, -1000
AdvanceMail()
return

GuiClose:
ExitApp

RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
return
