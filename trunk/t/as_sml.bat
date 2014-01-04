@echo off

:: USAGE: as_sml.bat library\testdata\td-000020.txt

set doc=%1
set perl=..\..\perl\perl\bin\perl.exe

%perl% as_sml.pl %doc%
