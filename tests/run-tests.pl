#!/usr/bin/env perl
#
# Test script for hAtom2Atom
#
# $Id: run-tests.pl 44 2006-06-05 13:50:25Z RobertBachmann $
#
use strict;
use warnings;
use XML::LibXML;  
use XML::LibXSLT;
use XML::SemanticDiff;
use Time::Local;
use File::stat;
use open ':utf8';

my $xslt_file = '../hAtom2Atom.xsl';

my %engines = (
  '4xslt' => 0,
  'libxslt' => 0,
  'saxon' => 0,
  'xalan' => 0,
  'xsltproc' => 0
);
my %failed_test_count = %engines;

my $parser = XML::LibXML->new();
my $libxslt = XML::LibXSLT->new();
my $semdiff = XML::SemanticDiff->new();
my $xslt_doc; 
my $libxslt_xslt;

my @tests;
my @selected_tests;
my $failed;
my $start_time = timelocal(localtime);
use Data::Dumper;

@tests = &read_test_descriptions; 
&parse_cmdline;

if ($engines{'libxslt'} == 1) {
    print "Parsing $xslt_file ...\n";
    $xslt_doc = $parser->parse_file('../hAtom2Atom.xsl');
    print "Loading $xslt_file into libxslt ...\n";
    $libxslt_xslt = $libxslt->parse_stylesheet($xslt_doc) or 
        die "Error in $xslt_file";
}

print "\n";

# Run the tests
foreach (@selected_tests) {
    my $i = $_ - 1;
    printf("Test: %s <=> %s\n", $tests[$i]->{'input'}, $tests[$i]->{'output'});
    print ' $source-uri = ',$tests[$i]->{'params'}->{'source-uri'},"\n";
    print ' $sanitize-html = ',$tests[$i]->{'params'}->{'sanitize-html'},"\n";
    print ' $implicit-feed = ',$tests[$i]->{'params'}->{'implicit-feed'},"\n";
    print ' $content-type = ',$tests[$i]->{'params'}->{'content-type'},"\n";
    
    if ($engines{'libxslt'}) {
        my $ofile=$tests[$i]->{'output'};
        $ofile =~ s/\.atom/.libxslt~/;
        
        print " libxslt... ";
        
        my $results = $libxslt_xslt->transform_file(
            $tests[$i]->{'input'},
            XML::LibXSLT::xpath_to_string(
                'source-uri' => $tests[$i]->{'params'}->{'source-uri'},
                'sanitize-html' => $tests[$i]->{'params'}->{'sanitize-html'},
                'implicit-feed' => $tests[$i]->{'params'}->{'implicit-feed'},
                'content-type' => $tests[$i]->{'params'}->{'content-type'}
            )
        );
        
        open OFILE,">$ofile" or die "Can't create $ofile";
        print OFILE $libxslt_xslt->output_string($results);
        close OFILE;
        
        &compare('libxslt',$tests[$i]->{'output'},$ofile);
    }

    if ($engines{'4xslt'}) {
        my $ofile=$tests[$i]->{'output'};
        $ofile =~ s/\.atom/.4xslt~/;
        
        print " 4xslt... ";
        
        my @cmd = ('4xslt',
                   '-D', 'source-uri='    . $tests[$i]->{'params'}->{'source-uri'},
                   '-D', 'content-type='  . $tests[$i]->{'params'}->{'content-type'},
                   '-D', 'sanitize-html=' . $tests[$i]->{'params'}->{'sanitize-html'},
                   '-D', 'implicit-feed=' . $tests[$i]->{'params'}->{'implicit-feed'},
                   '-o',$ofile,$tests[$i]->{'input'}, $xslt_file);
        
        system(@cmd);
        die "Error when calling 4xslt" if ($?);
        
        &compare('4xslt',$tests[$i]->{'output'},$ofile);
    }

    if ($engines{'saxon'}) {
        my $ofile=$tests[$i]->{'output'};
        $ofile =~ s/\.atom/.saxon~/;
        
        print " Saxon... ";
        
        my @cmd = ('java','net.sf.saxon.Transform','-novw',
                   '-o',$ofile, $tests[$i]->{'input'}, $xslt_file,
                   'source-uri='    . $tests[$i]->{'params'}->{'source-uri'},
                   'content-type='  . $tests[$i]->{'params'}->{'content-type'},
                   'sanitize-html=' . $tests[$i]->{'params'}->{'sanitize-html'},
                   'implicit-feed=' . $tests[$i]->{'params'}->{'implicit-feed'}
                   );
        
        system(@cmd);
        die "Error when calling Saxon" if ($?);
        
        &compare('saxon',$tests[$i]->{'output'},$ofile);
    }

    if ($engines{'xalan'}) {
        my $ofile=$tests[$i]->{'output'};
        $ofile =~ s/\.atom/.xalan~/;
        
        print " Xalan... ";
        
        my @cmd = ('java','org.apache.xalan.xslt.Process',
                   '-out',$ofile, 
                   '-in',$tests[$i]->{'input'},
                   '-xsl',$xslt_file,
                   '-param','source-uri',    $tests[$i]->{'params'}->{'source-uri'},
                   '-param','content-type',  $tests[$i]->{'params'}->{'content-type'},
                   '-param','sanitize-html', $tests[$i]->{'params'}->{'sanitize-html'},
                   '-param','implicit-feed', $tests[$i]->{'params'}->{'implicit-feed'}
                   );
        
        system(@cmd);
        die "Error when calling Xalan" if ($?);
        
        &compare('xalan',$tests[$i]->{'output'},$ofile);
    }

    if ($engines{'xsltproc'}) {
        my $ofile=$tests[$i]->{'output'};
        $ofile =~ s/\.atom/.xsltproc~/;
        
        print " xsltproc... ";
        
        my @cmd = ('xsltproc',
                   '-o',$ofile, 
                   '--stringparam','source-uri',    $tests[$i]->{'params'}->{'source-uri'},
                   '--stringparam','content-type',  $tests[$i]->{'params'}->{'content-type'},
                   '--stringparam','sanitize-html', $tests[$i]->{'params'}->{'sanitize-html'},
                   '--stringparam','implicit-feed', $tests[$i]->{'params'}->{'implicit-feed'},
                   $xslt_file,
                   $tests[$i]->{'input'},
                   );
        
        system(@cmd);
        die "Error when calling xsltproc" if ($?);
        
        &compare('xsltproc',$tests[$i]->{'output'},$ofile);
    }
    
    print "\n";
}

print "Running the tests took ", timelocal(localtime) - $start_time," seconds.\n\n";
if ( (grep {$_ != 0} values %failed_test_count) == 0 ) {
    print "All tests passed.\n";
    exit 0;
} else {
    print "Not all tests passed.\n";
    foreach (keys %engines) {
        if ($engines{$_} != 0) {
            print "$_: ", $failed_test_count{$_} ," of ", scalar @selected_tests, " tests failed.\n";
        }
    }
    exit 1;
}


# Compare a test result
sub compare {
    my ($engine,$expected_result,$test_result) = @_;
    warn "compare wants 3 params" unless $_[2];
    
    my @diff = $semdiff->compare($test_result, $expected_result);
    if (@diff) {
        print "FAILED (result stored in $test_result)\n";
        $failed_test_count{$engine}++;
        return 0;
    } else {
        print "PASSED\n";
        unlink $test_result;
        return 1;
    }    
}

# Read test description xml file
sub read_test_descriptions {
    my @tests;
    my $tests_file = 'tests.xml';
    die "$tests_file does not exist" if not -e $tests_file;
    my $parser = XML::LibXML->new();
    my $tree = $parser->parse_file($tests_file);
    my $root = $tree->getDocumentElement;

    # Get default params
    my %default_params;  
    foreach my $default_param_node ($root->findnodes('default-param')) {
        $default_params{$default_param_node->findvalue('@name')}
         = $default_param_node->findvalue('.');
    }

    # Read all tests
    foreach my $test_node ($root->findnodes('test')) {
        my %test;
        my %params = %default_params; 

        $test{'input'}  = $test_node->findvalue('input');
        $test{'output'} = $test_node->findvalue('output');
        $test{'params'}=\%params;

        foreach my $param_node ($test_node->findnodes('param')) {
            $params{$param_node->findvalue('@name')}
             = $param_node->findvalue('.');
        }
        push @tests, \%test;
    }
    @tests;
}

# Show usage
sub usage {
    my $exit_status = $_[1] || 0;
    print <<USAGE;
Usage: $0: [OPTIONS] [TEST-NUMBER]...
Run the test suite for hAtom2Atom.xsl with the supported XSLT enginges.

  -l, --list-tests         List test numbers and exit

  -A, --all                Run the tests with all engines
  -x, --libxslt            Run the tests with libxslt (with `XML::LibXSLT') 
      --xalan              Run the tests with Xalan
      --4xslt              Run the tests with 4XSLT
      --saxon              Run the tests with Saxon
      --xsltproc           Run the tests with libxslt (with `xsltproc')
      
      --recompile          Force recompilation of $xslt_file before testing
      
      --help     display this help and exit
USAGE
    exit $exit_status;
}

# Parse the commandline options
sub parse_cmdline {
    my $numbers_given;
    
    usage unless @ARGV;
    
    foreach (@ARGV) {
        usage if ($_ eq '--help');
    }
    
    foreach (@ARGV) {
        if ($_ eq '--all' or $_ eq '-A') {
            foreach (keys %engines) {
                $engines{$_} = 1;
            }
        } elsif ($_ eq '-x' or $_ eq '--libxslt') {
            $engines{'libxslt'} = 1;
        } elsif ($_ eq '--saxon') {
            $engines{'saxon'} = 1;
        } elsif ($_ eq '--4xslt') {
            $engines{'4xslt'} = 1;
        } elsif ($_ eq '--xalan') {
            $engines{'xalan'} = 1;
        } elsif ($_ eq '--xsltproc') {
            $engines{'xsltproc'} = 1;
        } elsif ($_ eq '--list-tests' or $_ eq '-l') {
            my $i = 1;
            foreach my $test (&read_test_descriptions) {
                printf(
                        "%3s %s <=> %s\n",
                        $i,
                        $test->{'input'},
                        $test->{'output'}
                      );
                ++$i;
            }
            exit 0;
        } elsif (/^\d+$/) { 
            if ($_ <= 0 or $_ > @tests) {
                print "$0: Invalid test number: $_\n".
                      "Valid numbers are in the range from 1 to ",scalar @tests,".\n";
                exit 1;
            } else {
                $numbers_given = 1;
                push @selected_tests,$_;
            }
        } else {
            print "$0: unrecognized option `$_'\n".
                  "Try `$0 --help' for more information.\n";
            exit 1;
        }
    }
    if ( (grep {$_} values %engines) == 0 ) {
        print "$0: No XSLT engine selected\n".
              "Try `$0 --help' for more information.\n";
        exit 1;
    }
    push (@selected_tests,1..@tests) unless $numbers_given;
}
