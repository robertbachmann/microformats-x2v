#!/bin/bash
# $Id: run-tests.sh 34 2006-03-19 18:28:28Z RobertBachmann $
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

function run_test
{
    expected_result=${filename%%.html}.atom
    tmp_file=${filename%%.html}.$1"~"
    
    if [[ "$1" == "all" ]]
    then
        run_test "4xslt"
        run_test "xalan-j"
        run_test "xsltproc"
        run_test "saxon"
        return
    fi

    echo '***' "$filename ($1)"
    
    if [[ "$1" == "4xslt" ]]
    then
        4xslt \
            -D source-uri=$source_uri \
            -D content-type=$content_type \
            $filename $xsl \
            > $tmp_file || die "Transformation failed"
    elif [[ "$1" == "xsltproc" ]]
    then
        xsltproc \
            --stringparam source-uri $source_uri \
            --stringparam content-type $content_type \
            $xsl $filename \
            > $tmp_file || die "Transformation failed"
    elif [[ "$1" == "xalan-j" ]]
    then
        java org.apache.xalan.xslt.Process -in $filename -xsl $xsl \
            -param source-uri $source_uri \
            -param content-type $content_type \
            > $tmp_file || die "Transformation failed"
    elif [[ "$1" == "saxon" ]]
    then
        java net.sf.saxon.Transform -novw $filename $xsl \
            source-uri=$source_uri \
            content-type=$content_type \
            > $tmp_file || die "Transformation failed"
    fi
    
    xmldiff -c $expected_result $tmp_file && rm $tmp_file || echo "Test failed (results stored in $tmp_file)"
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
    filename="author.html"
    source_uri="http://example.com/$filename"
    content_type="text/html"
    run_test $engine
fi

# baselang.html
if [[ $test_file == "baselang.html" || $test_file == "" ]]
then
    filename="baselang.html"
    source_uri="http://example.com/$filename"
    content_type="text/html"
    run_test $engine
fi

# concatenation.html
if [[ $test_file == "concatenation.html" || $test_file == "" ]]
then
    filename="concatenation.html"
    source_uri="http://example.com/$filename"
    content_type="text/html"
    run_test $engine
fi

# id-link.html
if [[ $test_file == "id-link.html" || $test_file == "" ]]
then
    filename="id-link.html"
    source_uri="http://example.com/$filename"
    content_type="text/html"
    run_test $engine
fi

# supportedElements.html
if [[ $test_file == "supportedElements.html" || $test_file == "" ]]
then
    filename="supportedElements.html"
    source_uri="http://example.com/$filename"
    content_type="text/html"
    run_test $engine
fi

# tag.html
if [[ $test_file == "tag.html" || $test_file == "" ]]
then
    filename="tag.html"
    source_uri="http://example.com/$filename"
    content_type="text/html"
    run_test $engine
fi

# titles.html
if [[ $test_file == "titles.html" || $test_file == "" ]]
then
    filename="titles.html"
    source_uri="http://example.com/$filename"
    content_type="text/html"
    run_test $engine
fi

# updated-published.html
if [[ $test_file == "updated-published.html" || $test_file == "" ]]
then
    filename="updated-published.html"
    source_uri="http://example.com/$filename"
    content_type="text/html"
    run_test $engine
fi
