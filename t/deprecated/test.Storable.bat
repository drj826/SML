@echo off

set begin=%DATE% %TIME%
echo BEGIN: %begin%

..\..\perl\perl\bin\perl.exe Storable.t

echo BEGIN: %begin%
echo END:   %DATE% %TIME%
