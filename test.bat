@echo off

set begin=%DATE% %TIME%
echo BEGIN: %begin%

cd t
..\..\app\perl\perl\bin\perl.exe run_unit_tests.pl
cd ..

echo BEGIN: %begin%
echo END:   %DATE% %TIME%
