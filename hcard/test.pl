#!/usr/bin/env perl
use strict;
use FindBin; use File::Spec;
use lib "$FindBin::Bin/../LIB/"; require XSLTest;

chdir($FindBin::Bin);
my $xslt = File::Spec->rel2abs('./xhtml2vcard.xsl');
my $t = XSLTest::hCard->new( {xslt_filename => $xslt} );
$t->run();
exit 0;
