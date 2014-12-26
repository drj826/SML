#!/usr/bin/perl

use UML::Class::Simple;

my $color = '#dddddd';

my @classes = classes_from_files
  ([
    '../../../SML/Division.pm',
    '../../../SML/Document.pm',
    '../../../SML/Preamble.pm',
    '../../../SML/Narrative.pm',
    '../../../SML/Section.pm',
    '../../../SML/Environment.pm',
    '../../../SML/Region.pm',
    '../../../SML/Conditional.pm',
    '../../../SML/Comment.pm',
   ]);

my $painter = UML::Class::Simple->new(\@classes);
$painter->node_color($color);
$painter->as_png('../images/class-diagram-division.png');
$painter->as_xmi('../xmi/class-diagram-division.xmi');
