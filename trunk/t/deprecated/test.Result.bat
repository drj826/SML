@echo off

set begin=%DATE% %TIME%
echo BEGIN: %begin%

..\..\perl\perl\bin\perl.exe Result.t

echo BEGIN: %begin%
echo END:   %DATE% %TIME%
