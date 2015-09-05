:: $Id: make-docs.bat 19403 2014-03-25 19:24:46Z don.johnson $

:: Make HTML and PDF POD documentation

@echo off

MKDIR docs-pdf
MKDIR docs-html

CD docs-pdf
FOR %%F IN (*.pdf) DO DEL %%F
CD ..

CD docs-html
FOR %%F IN (*.html) DO DEL %%F
CD ..

CALL ..\perl\perl\bin\perldoc.bat -o HTML -d docs-html\SML.pm.html lib\SML.pm
CALL ..\perl\perl\bin\perldoc.bat -o LaTeX -d SML.pm.tex lib\SML.pm
CALL ..\miktex\miktex\bin\pdflatex.exe SML.pm.tex

DEL SML.pm.tex
DEL SML.pm.aux
DEL SML.pm.idx
DEL SML.pm.log

COPY SML.pm.pdf docs-pdf\SML.pm.pdf

DEL SML.pm.pdf

CD lib\SML

FOR %%F IN (*.pm) DO (

  CALL ..\..\..\perl\perl\bin\perldoc.bat -o HTML -d ..\..\docs-html\%%F.html %%F
  CALL ..\..\..\perl\perl\bin\perldoc.bat -o LaTeX -d %%F.tex %%F
  CALL ..\..\..\miktex\miktex\bin\pdflatex.exe %%F.tex

  DEL %%F.tex
  DEL %%F.aux
  DEL %%F.idx
  DEL %%F.log

  COPY %%F.pdf ..\..\docs-pdf\%%F.pdf

  DEL %%F.pdf
)

CD ..\..

CD scripts

FOR %%F IN (*.pl) DO (

  CALL ..\..\..\perl\perl\bin\perldoc.bat -o HTML -d ..\..\docs-html\%%F.html %%F
  CALL ..\..\..\perl\perl\bin\perldoc.bat -o LaTeX -d %%F.tex %%F
  CALL ..\..\..\miktex\miktex\bin\pdflatex.exe %%F.tex

  DEL %%F.tex
  DEL %%F.aux
  DEL %%F.idx
  DEL %%F.log

  COPY %%F.pdf ..\..\docs-pdf\%%F.pdf

  DEL %%F.pdf
)

CD ..\..
