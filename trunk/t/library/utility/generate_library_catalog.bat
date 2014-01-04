::####################################################################
::
:: generate_library_catalog.bat
::
::####################################################################

@echo off

set perl=..\..\..\..\perl\perl\bin\perl.exe
set script=generate_library_catalog.pl

%perl% %script%

pause