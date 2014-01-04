@echo off

set test=%1
set perl=..\..\perl\perl\bin\perl.exe

set begin=%DATE% %TIME%
echo BEGIN: %begin%

%perl% %test%

echo BEGIN: %begin%
echo END:   %DATE% %TIME%
