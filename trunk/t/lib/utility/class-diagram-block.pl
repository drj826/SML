#!/usr/bin/perl

use UML::Class::Simple;

my $color = '#dddddd';

my @classes = classes_from_files
  ([
    '../../../SML/Block.pm',
    '../../../SML/Element.pm',
   ]);

my $painter = UML::Class::Simple->new(\@classes);
$painter->node_color($color);
$painter->as_png('../images/class-diagram-block.png');
$painter->as_xmi('../xmi/class-diagram-block.xmi');
