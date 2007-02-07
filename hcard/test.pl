#!/usr/bin/env perl
use strict;
use FindBin; use File::Spec;
use lib "$FindBin::Bin/../LIB/"; require XSLTest;

my $xslt = File::Spec->rel2abs('./xhtml2vcard.xsl', $FindBin::Bin);
my $t = XSLTest::hCard->new( {xslt_filename => $xslt} );
$t->run();
exit 0;
