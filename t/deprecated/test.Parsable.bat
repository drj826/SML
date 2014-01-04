@echo off

set begin=%DATE% %TIME%
echo BEGIN: %begin%

..\..\perl\perl\bin\perl.exe Parsable.t

echo BEGIN: %begin%
echo END:   %DATE% %TIME%
