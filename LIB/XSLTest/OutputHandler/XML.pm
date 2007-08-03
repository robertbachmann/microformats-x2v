# Class for handling XML test ouput
#
# Copyright 2006-07 Robert Bachmann <rbach@rbach.priv.at>
#
# This work is licensed under The W3C Open Source License
# <http://www.w3.org/Consortium/Legal/copyright-software-19980720>

package XSLTest::OutputHandler::XML;

use strict;
use warnings;
use base qw(XSLTest::OutputHandler);
use utf8;

require XML::LibXML;

sub new {             # Constructor
    my $class = shift;
    my $self  = $class->SUPER::new( @_ );
    bless( $self, $class );
    return $self;
}

sub normalize_data {  # Normalize data
    my ( $self, $data ) = @_;
    my ( $parser, $doc );

    utf8::encode($data);

    $parser = XML::LibXML->new();
    $parser->keep_blanks(0);

    $doc = $parser->parse_string($data);
    $doc->setEncoding('utf-8');

    return $doc->toStringC14N(0);
}

sub make_diff {       # Generate an unified diff
    my ( $self, $a, $b ) = @_;
    my ( $parser, $doc1, $doc2 );

    $parser = XML::LibXML->new();
    $parser->keep_blanks(0);

    utf8::encode($a);
    $doc1 = $parser->parse_string($a);
    $doc1->setEncoding('utf-8');
    $a = $doc1->toString(1);

    utf8::encode($b);
    $doc2 = $parser->parse_string($b);
    $doc2->setEncoding('utf-8');
    $b = $doc2->toString(1);

    return $self->SUPER::make_diff( $a, $b );
}

1;
