@echo off

set begin=%DATE% %TIME%
echo BEGIN: %begin%

..\perl\perl\bin\prove -I lib

echo BEGIN: %begin%
echo END:   %DATE% %TIME%

PAUSE
