::####################################################################
::
:: update_item_listings.bat
::
:: $Id: update_item_listings.bat 2634 2011-06-07 13:52:40Z don.johnson $
::
::--------------------------------------------------------------------
:: DESCRIPTION
::
::     Update item listings included in documents.
::
::####################################################################

cd ..\..

..\..\perl\perl\bin\perl.exe files\scripts\include_related.pl --problems  frd-sml.txt      > incl\frd-sml-problems.txt
..\..\perl\perl\bin\perl.exe files\scripts\include_related.pl --solutions frd-sml.txt      > incl\frd-sml-solutions.txt
..\..\perl\perl\bin\perl.exe files\scripts\include_related.pl --tests     frd-sml.txt      > incl\frd-sml-tests.txt

..\..\perl\perl\bin\perl.exe files\scripts\include_related.pl --problems  frd-publish.txt  > incl\frd-publish-problems.txt
..\..\perl\perl\bin\perl.exe files\scripts\include_related.pl --solutions frd-publish.txt  > incl\frd-publish-solutions.txt
..\..\perl\perl\bin\perl.exe files\scripts\include_related.pl --tests     frd-publish.txt  > incl\frd-publish-tests.txt

..\..\perl\perl\bin\perl.exe files\scripts\include_related.pl --problems  sdd-publish.txt  > incl\sdd-publish-problems.txt
..\..\perl\perl\bin\perl.exe files\scripts\include_related.pl --solutions sdd-publish.txt  > incl\sdd-publish-solutions.txt
..\..\perl\perl\bin\perl.exe files\scripts\include_related.pl --tests     sdd-publish.txt  > incl\sdd-publish-tests.txt

