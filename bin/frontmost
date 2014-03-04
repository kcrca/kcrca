#!/usr/bin/osascript
tell application "System Events" to set frntProc to name of every process whose frontmost is true and visible is not false
if length of frntProc = 0 then
	display dialog "No frontmost process!" & the error_message buttons {"OK"} default button 1
end if
set output to item 1 of frntProc
