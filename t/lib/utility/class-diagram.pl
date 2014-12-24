#!/usr/bin/perl

use UML::Class::Simple;

my $color = '#dddddd';

my @classes = classes_from_files
  ([
    '../../../SML/Parser.pm',
    '../../../SML/Text.pm',
    '../../../SML/Options.pm',
    '../../../SML/Utilities.pm',
    '../../../SML/File.pm',
    '../../../SML/SML.pm',
    '../../../SML/Text.pm',
    '../../../SML/Line.pm',
   ]);

my $painter = UML::Class::Simple->new(\@classes);
$painter->node_color($color);
$painter->as_png('../images/class-diagram.png');
$painter->as_xmi('../images/class-diagram.xmi');
