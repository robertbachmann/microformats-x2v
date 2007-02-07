#!/usr/bin/env perl
use strict;
use FindBin; use File::Spec;
use lib "$FindBin::Bin/../LIB/"; require XSLTest;

my $xslt = File::Spec->rel2abs('../hatom/hAtom2Atom.xsl', $FindBin::Bin);
my $t = XSLTest::hAtom->new( {xslt_filename => $xslt} );
$t->run();
exit 0;
