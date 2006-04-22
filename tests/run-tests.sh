#!/bin/bash
# $Id: run-tests.sh 38 2006-04-22 16:42:03Z RobertBachmann $
#
# Test script for hAtom2Atom
# Requires: xmldiff <http://www.logilab.org/projects/xmldiff/>
# Requires: msys <http://www.mingw.org/> (only if you are using Windows)
#
engine=$1
test_file=$2
tmp_file=/tmp/hatom2atom.$$.tmp
xsl=../hAtom2Atom.xsl

cd `dirname $0`

function die
{
    echo $1
    exit 1
}

which xmldiff > /dev/null || \
die "Download xmldiff from <http://www.logilab.org/projects/xmldiff/>"

function show_usage
{
    echo "usage: $0 <engine> [test-file]"
    echo " engine = xsltproc | xalan-j | saxon | 4xslt | all"
    exit
}

function test_with_engine
{
    tmp_file=${result_filename%%.atom}.$1"~"
    echo " Testing with engine: $1" 
    
    if [[ "$1" == "4xslt" ]]
    then
        4xslt \
            -D source-uri=$source_uri \
            -D content-type=$content_type \
            -D implicit-feed=$implicit_feed \
            $source_filename $xsl \
            > $tmp_file || die "Transformation failed"
    elif [[ "$1" == "xsltproc" ]]
    then
        xsltproc \
            --stringparam source-uri $source_uri \
            --stringparam content-type $content_type \
            --param implicit-feed $implicit_feed \
            $xsl $source_filename \
            > $tmp_file || die "Transformation failed"
    elif [[ "$1" == "xalan-j" ]]
    then
        java org.apache.xalan.xslt.Process -in $source_filename -xsl $xsl \
            -param source-uri $source_uri \
            -param content-type $content_type \
            -param implicit-feed $implicit_feed \
            > $tmp_file || die "Transformation failed"
    elif [[ "$1" == "saxon" ]]
    then
        java net.sf.saxon.Transform -novw $source_filename $xsl \
            source-uri=$source_uri \
            content-type=$content_type \
            implicit-feed=$implicit_feed \
            > $tmp_file || die "Transformation failed"
    fi
    
    xmldiff -c $result_filename $tmp_file && rm $tmp_file || echo " Test failed (results stored in $tmp_file)"
}

function run_test
{
    echo "$source_filename -> $result_filename"
    echo " \$source-uri: '$source_uri'"
    echo " \$content-type: '$content_type'"
    echo " \$implicit-feed: $implicit_feed"

    if [[ "$1" == "all" ]]
    then
        test_with_engine "4xslt"
        test_with_engine "xalan-j"
        test_with_engine "xsltproc"
        test_with_engine "saxon"
    else
        test_with_engine $1
    fi
    echo
}

function default_values
{
  source_filename=$1
  result_filename=${source_filename%%.html}.atom
  source_uri="http://example.com/$source_filename"
  content_type="text/html"
  implicit_feed=0
}

if [[ "$1" == "" ]] ; then show_usage ; fi

if [[ ("$engine" != "xsltproc") && \
      ("$engine" != "xalan-j") && \
      ("$engine" != "saxon") && \
      ("$engine" != "4xslt") && \
      ("$engine" != "all") ]]
      then show_usage ; fi

      
      
#
# Tests 
#

# author.html
if [[ $test_file == "author.html" || $test_file == "" ]]
then
    default_values "author.html"
    run_test $engine
fi

# baselang.html
if [[ $test_file == "baselang.html" || $test_file == "" ]]
then
    default_values "baselang.html"
    run_test $engine
fi

# concatenation.html
if [[ $test_file == "concatenation.html" || $test_file == "" ]]
then
    default_values "concatenation.html"
    run_test $engine
fi

# id-link.html
if [[ $test_file == "id-link.html" || $test_file == "" ]]
then
    default_values "id-link.html"
    run_test $engine
fi

# singleEntry.html
if [[ $test_file == "singleEntry.html" || $test_file == "" ]]
then
    default_values "singleEntry.html"
    result_filename="singleEntry-a.atom"
    implicit_feed=0
    run_test $engine

    default_values "singleEntry.html"
    result_filename="singleEntry-b.atom"
    implicit_feed=1
    run_test $engine    
fi

# supportedElements.html
if [[ $test_file == "supportedElements.html" || $test_file == "" ]]
then
    default_values "supportedElements.html"
    run_test $engine
fi

# tag.html
if [[ $test_file == "tag.html" || $test_file == "" ]]
then
    default_values "tag.html"
    run_test $engine
fi

# titles.html
if [[ $test_file == "titles.html" || $test_file == "" ]]
then
    default_values "titles.html"
    run_test $engine
fi

# updated-published.html
if [[ $test_file == "updated-published.html" || $test_file == "" ]]
then
    default_values "updated-published.html"
    run_test $engine
fi
