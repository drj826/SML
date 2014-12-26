#!/usr/bin/perl

use UML::Class::Simple;

my $color = '#dddddd';

my @classes = classes_from_files
  ([
    '../../../SML/Region.pm',
    '../../../SML/Demo.pm',
    '../../../SML/Exercise.pm',
    '../../../SML/Item.pm',
    '../../../SML/Slide.pm',
    '../../../SML/Problem.pm',
    '../../../SML/Result.pm',
    '../../../SML/Role.pm',
    '../../../SML/Solution.pm',
    '../../../SML/Task.pm',
    '../../../SML/Test.pm',
   ]);

my $painter = UML::Class::Simple->new(\@classes);
$painter->node_color($color);
$painter->as_png('../images/class-diagram-region.png');
$painter->as_xmi('../xmi/class-diagram-region.xmi');
