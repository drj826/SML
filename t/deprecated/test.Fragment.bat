@echo off

set begin=%DATE% %TIME%
echo BEGIN: %begin%

..\..\perl\perl\bin\perl.exe Fragment.t

echo BEGIN: %begin%
echo END:   %DATE% %TIME%
