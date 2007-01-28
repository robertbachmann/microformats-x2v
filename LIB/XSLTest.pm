#!/usr/bin/env perl
#
# Module for testing the microformat XSLTs
#
# Copyright 2006-07 Robert Bachmann <rbach@rbach.priv.at>
#
# This work is licensed under The W3C Open Source License
# <http://www.w3.org/Consortium/Legal/copyright-software-19980720>

package XSLTest;

use warnings;
use strict;

use FindBin;
use Data::Dumper;
use Cwd;
use utf8;

sub new {    # Constructor
    my $class = shift;
    my $args = shift || {};

    my $self = {
        engines  => {
            '4XSLT'   => 0,
            'LibXSLT' => 0,
            'Saxon'   => 0,
            'Xalan-C' => 0,
            'Xalan-J' => 0,
        }
    };
    bless $self, $class;

    foreach ( keys %{$args} ) {
        $self->{$_} = $args->{$_};
    }

    eval { require XML::LibXML; require XML::LibXSLT };
    if ($@) {
        print STDERR "Please install XML::LibXSLT.\n",
            "If you're using Windows see ",
            "<http://cpan.uwinnipeg.ca/module/XML::LibXSLT>\n",
            "If you're using MacOSX see ",
            "<http://p5-xml-libxslt.darwinports.com/>\n";
        exit 1;
    }

    eval { require Text::Diff };
    if ($@) {
        print STDERR "Please install Text::Diff.\n",
            "See <http://search.cpan.org/~RBS/Text-Diff/>\n";
        exit 1;
    }

    eval { require Getopt::Long };
    if ($@) {
        print STDERR "Please install Getopt::Long.\n",
            "See <http://search.cpan.org/~JV/Getopt-Long/>\n";
        exit 1;
    }

    unless ($ENV{MICROFORMATS_TESTS}) {
        print STDERR "Please set the MICROFORMATS_TESTS environment variable\n",
            "to the path of the directory which contains the tests from http://hg.microformats.org/tests\n";
        exit 1;
    }

    $self->{test_dir} = $ENV{MICROFORMATS_TESTS};

    chdir( $self->{test_dir} ) || die "Couldn't chdir to tests directory";

    my @all_tests = $self->get_file_names_and_params();
    $self->{all_tests} = \@all_tests;

    $self->parse_cmdline_args();

    return $self;
}

sub parse_cmdline_args {    # Parse the commandline arguments from ARGV
    my $self               = shift;
    my $p                  = Getopt::Long::Parser->new();
    my $numbers_were_given = 0;
    my %opt;

    if (@ARGV) {
        $p->getoptions(
            \%opt,          '4xslt',   'libxslt|x', 'saxon',
            'xalan-c',      'xalan-j', 'q|quiet',   'all|A',
            'list-tests|l', 'help'
        );
    }
    else {
        $opt{help} = 1;
    }

    if ( $opt{help} ) {
        $self->display_help();
        exit 0;
    }

    $self->{quiet} = 1 if ( $opt{q} );

    $self->{engines}->{'4XSLT'}   = 1 if ( $opt{'4xslt'} );
    $self->{engines}->{'LibXSLT'} = 1 if ( $opt{libxslt} );
    $self->{engines}->{'Saxon'}   = 1 if ( $opt{saxon} );
    $self->{engines}->{'Xalan-C'} = 1 if ( $opt{'xalan-c'} );
    $self->{engines}->{'Xalan-J'} = 1 if ( $opt{'xalan-j'} );

    if ( $opt{all} ) {
        foreach ( keys %{ $self->{engines} } ) {
            $self->{engines}->{$_} = 1;
        }
    }

    foreach (@ARGV) {
        my $max_nr = $#{ $self->{all_tests} };
        if (/^\d+$/) {
            $numbers_were_given = 1;
            if ( $_ <= 0 or $_ >= $max_nr ) {
                print STDERR "$0: Invalid test number: $_\n"
                    . "Valid numbers are in the range from 1 to $max_nr \n";
                exit 1;
            }
            push @{ $self->{selected_tests} },
                @{ $self->{all_tests} }[ $_ - 1 ];
        }
        else {
            print STDERR "$0: unrecognized option `$_'\n"
                . "Try `$0 --help' for more information.\n";
            exit 1;
        }
    }

    $self->{selected_tests} = $self->{all_tests} if ( !$numbers_were_given );
}

sub display_help {    # Show help and exit
    print <<"HELP";
Usage: $0: [OPTIONS] [TEST-NUMBER]...
Run the test suite with the supported XSLT engines.

  -l, --list-tests         List test numbers and exit

  -q, --quiet              Supress uppress nonessential output

  -A, --all                Run the tests with all engines
  -x, --libxslt            Run the tests with libxslt (via `XML::LibXSLT')
      --4xslt              Run the tests with 4XSLT
      --saxon              Run the tests with Saxon
      --xalan-c            Run the tests with Xalan-C
      --xalan-j            Run the tests with Xalan-J
      --help               Display this help and exit
HELP
}

sub read_file {    # Return the contents of a file as a scalar
    my ( $self, $filename ) = @_;

    open my $f, '<:utf8', $filename or die "Can't open file: $filename\n";
    my @lines = <$f>;
    close $f;

    return join '', @lines;
}

sub write_file {    # Write scalar into a (new) file
    my ( $self, $filename, $data ) = @_;

    open my $f, '>:utf8', $filename or die "Can't open file: $filename\n";
    print {$f} $data;
    close $f;
}

sub get_prodid {    # Get the prodid of the XSLT file
    my ( $self, $doc ) = @_;
    my $xsl_ns = 'http://www.w3.org/1999/XSL/Transform';
    my @nodelist = $doc->getElementsByTagNameNS( $xsl_ns, 'param' );
    foreach my $n (@nodelist) {
        my ( $name, $v, $a );

        $name = $n->getAttribute('name');
        next unless $name eq 'Prodid';

        $a = $n->getAttribute('select');
        if ($a) {

            # remove first and last char
            return substr( $a, 1, length($a) - 2 );
        }
        else {
            return $n->textContent;
        }
    }
    return;
}

sub load_libxslt {    # Load an XSLT file into LibXSLT
    my $self = shift;

    my ( $parser, $libxslt, $xslt_doc );
    $parser = XML::LibXML->new();

    my $doc = $parser->parse_file( $self->{xslt_filename} )
        or die "Can't parse XSLT";

    $self->{prodid} = $self->get_prodid($doc);

    if ( $self->{engines}->{LibXSLT} ) {
        $libxslt = XML::LibXSLT->new();
        $self->{libxslt} = $libxslt->parse_stylesheet($doc)
            or die "Error in XSLT file";
    }
}

sub remove_doctype {
    my ( $self, $s_ref ) = @_;
    my $start = index( $$s_ref, '<!DOCTYPE' );
    return if ( $start == -1 );

    my $end = index( $$s_ref, '>', $start + length('<!DOCTYPE') );
    $$s_ref = substr( $$s_ref, 0, $start ) . substr( $$s_ref, $end + 1 );
}

sub run {    # Run all tests
    my $self         = shift;
    my $test_results = {};

    chdir( $FindBin::Bin . '/../..' );
    $self->load_libxslt();

    chdir( $self->{test_dir} ) || die "Couldn't chdir to tests directory";

    foreach my $test ( @{ $self->{all_tests} } ) {

        # get the expected result
        my $expected = do {
            my $s = $self->read_file( $test->{result_filename} );
            utf8::decode($s);
            $self->normalize_data($s);
        };

        # remove the DOCTYPE from the input file
        do {
            my $input = $self->read_file( $test->{input_filename} );
            $self->remove_doctype( \$input );
            $self->write_file( 'tmp-in', $input );
        };

        foreach ( sort keys %{ $self->{engines} } ) {
            my $engine = $_;
            next unless $self->{engines}->{$engine};

            my $passed;

            my $got = $self->execute_engine( $engine, $test );
            if ( !defined($got) ) { # engine error
                $test_results->{ $test->{test_name} }->{ $engine . "-result" }
                    = -1;
                next;
            }
            $got = $self->normalize_data($got);

            if ( $self->compare_result( $got, $expected ) ) {
                print "PASS ", $test->{test_name}, " [$engine]\n";
                $passed = 1;
            }
            else {
                print "FAIL ", $test->{test_name}, " [$engine]\n";
                unless ( $self->{quiet} ) {
                    my $diff = $self->make_diff( $expected, $got );
                    $test_results->{ $test->{test_name} }
                        ->{ $engine . "-diff" } = $diff;
                    print $diff;
                }
                $passed = 0;
            }

            $test_results->{ $test->{test_name} }->{ $engine . "-result" }
                = $passed;
        }
        unlink('tmp-in');
        unlink('tmp-out');
    }

    $Data::Dumper::Indent = 1;
    do { my $x = Dumper($test_results); $self->write_file( "x.txt", $x ) };

}

sub make_diff {    # Generate an unified diff
    my ( $self, $a, $b ) = @_;

    if ( substr( $a, -1, 1 ) ne "\n" ) { $a .= "\n" }
    if ( substr( $b, -1, 1 ) ne "\n" ) { $b .= "\n" }

    return Text::Diff::diff( \$a, \$b,
        { FILENAME_A => 'expected', FILENAME_B => 'got' } );
}

sub compare_result {    # Compare two resutls
    my $self = shift;
    return $_[0] eq $_[1];
}

sub execute_engine {    # Execute an XSLT engine
    my ( $self, $engine, $test ) = @_;

    if   ( $engine eq "4XSLT" )   { return $self->execute_4xslt($test); }
    if   ( $engine eq "LibXSLT" ) { return $self->execute_libxslt($test); }
    if   ( $engine eq "Saxon" )   { return $self->execute_saxon($test); }
    if   ( $engine eq "Xalan-C" ) { return $self->execute_xalan_c($test); }
    if   ( $engine eq "Xalan-J" ) { return $self->execute_xalan_j($test); }
    else                          { die "Unknwon engine ($engine)"; }
}

sub execute_4xslt {
    my ( $self, $test ) = @_;

    my @cmd;
    push @cmd, '4xslt';
    foreach my $name ( keys %{ $test->{params} } ) {
        my $value = $test->{params}->{$name};
        push( @cmd, '-D' );
        push( @cmd, $name . '=' . $value );
    }
    push @cmd, '-o';
    push @cmd, 'tmp-out';
    push @cmd, 'tmp-in';
    push @cmd, $self->{xslt_filename};

    unless ( system(@cmd) == 0 ) {
        warn "Could not execute 4XSLT";
        return;
    }
    my $s = $self->read_file('tmp-out');
    unlink('tmp-out');

    return $s;
}

sub execute_libxslt {
    my ( $self, $test ) = @_;
    my @params;

    foreach my $name ( keys %{ $test->{params} } ) {
        my $value = $test->{params}->{$name};
        push @params, ( $name, $value );
    }

    my $results = $self->{libxslt}
        ->transform_file( 'tmp-in', XML::LibXSLT::xpath_to_string(@params) );

    my $result_string = $self->{libxslt}->output_string($results);

    return $result_string;
}

sub execute_saxon {
    my ( $self, $test ) = @_;

    my @cmd;
    push @cmd, qw(java net.sf.saxon.Transform);
    push @cmd, '-novw';
    push @cmd, '-o';
    push @cmd, 'tmp-out';
    push @cmd, 'tmp-in';
    push @cmd, $self->{xslt_filename};
    foreach my $name ( keys %{ $test->{params} } ) {
        my $value = $test->{params}->{$name};
        push( @cmd, $name . '=' . $value );
    }

    unless ( system(@cmd) == 0 ) {
        warn "Could not execute Saxon";
        return;
    }

    my $s = $self->read_file('tmp-out');
    unlink('tmp-out');

    return $s;
}

sub execute_xalan_c {
    my ( $self, $test ) = @_;

    my @cmd;    #= qw(gecho);
    push @cmd, 'Xalan';
    push @cmd, '-o';
    push @cmd, 'tmp-out';

    foreach my $name ( keys %{ $test->{params} } ) {
        my $value = $test->{params}->{$name};
        push @cmd, '-p';
        push @cmd, $name;
        push @cmd, q{'} . $value . q{'};
    }
    push @cmd, 'tmp-in';
    push @cmd, $self->{xslt_filename};

    unless ( system(@cmd) == 0 ) {
        warn "Could not execute Xalan-C";
        return;
    }

    my $s = $self->read_file('tmp-out');
    unlink('tmp-out');

    return $s;
}

sub execute_xalan_j {
    my ( $self, $test ) = @_;

    my @cmd;
    push @cmd, 'java';

    # make sure Xalan-J always uses Xalan-J and not an other JAXP compilant
    # XSLT enginge for transforming. See:
    # <http://www.biglist.com/lists/xsl-list/archives/200302/msg00954.html>
    # and <http://xml.apache.org/xalan-j/usagepatterns.html#plug>
    push @cmd,
        '-D'
        . 'javax.xml.transform.TransformerFactory' . '='
        . 'org.apache.xalan.processor.TransformerFactoryImpl';
    push @cmd, 'org.apache.xalan.xslt.Process';
    push @cmd, qw(-IN tmp-in);
    push @cmd, '-XSL', $self->{xslt_filename};
    push @cmd, qw(-OUT tmp-out);

    foreach my $name ( keys %{ $test->{params} } ) {
        my $value = $test->{params}->{$name};
        push @cmd, ( '-PARAM', $name, $value );
    }

    unless ( system(@cmd) == 0 ) {
        warn "Could not execute Xalan-J";
        return;
    }
    my $s = $self->read_file('tmp-out');
    unlink('tmp-out');

    return $s;
}

sub get_file_names_and_params { die "Abstract method"; }
sub normalize_data            { die "Abstract method"; }

1;    # end of package XSLTest

package XSLTest::RFC2425Style;    # parent class for hCard and hCalendar
use strict;
use warnings;
use base qw(XSLTest);

sub normalize_data {
    my $self = shift;
    my $data = shift;

    my $source     = "http://example.com/";
    my $product_id = $self->{prodid};

    my $data_ref = do { my @a = split /\r?\n/, $data; \@a };
    my @data = $self->_sort_object($data_ref);

    my $reg2 = qr/\Q$source/;

    foreach (@data) {
        $_ =~ s{\$PRODID\$}{$product_id}g;
        $_ =~ s{\$SOURCE\$([^\$]*)$}{$source$1}g;

        #$_ =~ s{\$SOURCE\$}{$source}g;
    }
    return join( "\n", @data );
}

sub _sort_object {

    # based on Ryan King's normalize.pl
    my $self            = shift;
    my $data_ref        = shift;
    my @buffer          = ();
    my @output          = ();
    my $sort_collection = sub() {
        foreach ( sort @buffer ) {
            push @output, $_;
        }
        @buffer = ();
        push @output, $_[0];
    };

    while ( @{$data_ref} != 0 ) {
        my $line = shift @{$data_ref};
        next if ( $line =~ /^\s*$/ );

        if ( $line =~ /^BEGIN\:[A-Z]+/ ) {
            $sort_collection->($line);

            # recurse to do nested objects
            push @output, $self->_sort_object($data_ref);
        }
        elsif ( $line =~ /^END\:[A-Z]+/ ) {
            $sort_collection->($line);
            last;
        }
        elsif ( $line =~ /^[A-Z]*/ ) {
            push @buffer, $line;    # collect lines in the object
        }
    }
    return @output;
}

1;                                  # end of package XSLTest::RFC2425Style

package XSLTest::hCard;
use strict;
use warnings;
use File::Basename;
use base qw(XSLTest::RFC2425Style);

sub get_file_names_and_params {
    my $self = shift;
    my ( @file_names, @list );
    my %params = ( Source => "http://example.com/" );

    @file_names = glob('hcard/*.html');

    for (@file_names) {
        my ( $output, $input, $test ) = ( $_, $_, $_ );
        $output =~ s/\.html$/.vcf/;
        $test   =~ s/\.html$//;
        my $entry = {
            test_name       => basename($test),
            input_filename  => $input,
            result_filename => $output,
            params          => \%params
        };

        push @list, $entry;
    }

    return @list;
}

1;    # end of package XSLTest::hCard

package XSLTest::hCalendar;

use strict;
use warnings;
use base qw(XSLTest::RFC2425Style);
use File::Basename;

sub get_file_names_and_params {
    my $self = shift;
    my ( @file_names, @list );
    my %params = ( Source => "http://example.com/" );

    @file_names = glob('hcalendar/*.html');

    for (@file_names) {
        my ( $output, $input, $test ) = ( $_, $_, $_ );
        $output =~ s/\.html$/.ics/;
        $test   =~ s/\.html$//;
        my $entry = {
            test_name       => basename($test),
            input_filename  => $input,
            result_filename => $output,
            params          => \%params
        };

        push @list, $entry;
    }

    return @list;
}
1;    # end of package XSLTest::hCard

package XSLTest::XML;    # parent class for hAtom
use strict;
use warnings;
use base qw(XSLTest);
use utf8;
use XML::LibXML;

sub normalize_data {
    my ( $self, $data ) = @_;
    my ( $parser, $doc );

    utf8::encode($data);

    $parser = XML::LibXML->new();
    $parser->keep_blanks(0);

    $doc = $parser->parse_string($data);
    $doc->setEncoding('utf-8');

    return $doc->toStringC14N(0);
}

sub make_diff {    # Generate an unified diff
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

1;    # end of package XSLTest::XML

package XSLTest::hAtom;
use strict;
use warnings;
use base qw(XSLTest::XML);
use XML::LibXML;
use File::Basename;

# Read test description xml file
sub get_file_names_and_params {
    my $self = shift;

    my @list;
    my $testfile = 'hatom/tests.xml';
    die "$testfile does not exist" if not -e $testfile;
    my $parser = XML::LibXML->new();
    my $tree   = $parser->parse_file($testfile)
        or die "Can't parse $testfile";

    # Get default params
    my %default_params;
    my $root = $tree->getDocumentElement();
    foreach my $default_param_node ( $root->findnodes('default-param') ) {
        $default_params{ $default_param_node->findvalue('@name') }
            = $default_param_node->findvalue('.');
    }

    # Read all tests
    my $i = 1;
    foreach my $test_node ( $root->findnodes('test') ) {
        my $input  = $test_node->findvalue('input');
        my $output = $test_node->findvalue('output');
        my %params = %default_params;
        my $name   = do {
            my $s = basename($input);
            $s =~ s/\.html$//;
            sprintf( '%02d-%s', $i, $s );
        };

        foreach my $param_node ( $test_node->findnodes('param') ) {
            $params{ $param_node->findvalue('@name') }
                = $param_node->findvalue('.');
        }

        my $entry = {
            test_name       => $name,
            input_filename  => 'hatom/' . $input,
            result_filename => 'hatom/' . $output,
            params          => \%params
        };

        push @list, $entry;
        ++$i;
    }

    return @list;
}
1;    # end of package XSLTest::hAtom
