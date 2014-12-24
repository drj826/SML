#!/usr/bin/perl

use UML::Class::Simple;

my $color = '#dddddd';

my @classes = classes_from_files
  ([
    '../../../SML/Environment.pm',
    '../../../SML/Assertion.pm',
    '../../../SML/Attachment.pm',
    '../../../SML/Audio.pm',
    '../../../SML/Epigraph.pm',
    '../../../SML/Figure.pm',
    '../../../SML/Include.pm',
    '../../../SML/Keypoints.pm',
    '../../../SML/Listing.pm',
    '../../../SML/Preformatted.pm',
    '../../../SML/Quotation.pm',
    '../../../SML/Revisions.pm',
    '../../../SML/Sidebar.pm',
    '../../../SML/Source.pm',
    '../../../SML/Table.pm',
    '../../../SML/Video.pm',
   ]);

my $painter = UML::Class::Simple->new(\@classes);
$painter->node_color($color);
$painter->as_png('../images/class-diagram-environment.png');
$painter->as_xmi('../images/class-diagram-environment.xmi');
