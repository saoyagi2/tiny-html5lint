#!/usr/bin/env perl

use strict;
use warnings;

use utf8;
use Encode;
use open IO => ":utf8";
binmode(STDOUT, ":utf8");

if($0 eq __FILE__) {
  if(@ARGV < 1) {
    print "usage : tiny-html5lint.pl tariget-html\n";
    exit;
  }
  print "$ARGV[0]\n";

  open my $fh, '<', $ARGV[0] or die $!;
  my $buffer = join('', <$fh>);
  close $fh;
  my $result_ref = html5lint($buffer);
  print $result_ref->{'message'};
  exit $result_ref->{'code'};
}

sub html5lint {
  my $buffer = shift;
  my $line = 1;
  my $column = 1;
  my $state = "text";
  my $error;
  my %result = (
    'code' => 0,
    'message' => ''
  );
  foreach my $c (split(//, $buffer)) {
    my $type = judge_type($c);
    ($state, $error) = transite_state($state, $type);
    if($error ne "") {
      $result{'message'} .= "$error($line:$column)\n";
      $result{'code'} = 1;
    }

    if($c eq "\n") {
      $line++;
      $column = 1;
    }
    else {
      $column++;
    }
  }
  return \%result;
}

sub transite_state {
  my ($state, $type) = @_;
  my ($new_state, $error);
  my $transite_matrix = {
    "starttag_slash" => "tagname",
    "starttag_exclamation" => "tagname",
    "starttag_alphabet" => "tagname",
    "tagname_endtag" => "text",
    "tagname_whitespace" => "whitespace",
    "tagname_alphabet" => "tagname",
    "tagname_decimal" => "tagname",
    "whitespace_endtag" => "text",
    "whitespace_slash" => "whitespace",
    "whitespace_whitespace" => "whitespace",
    "whitespace_alphabet" => "attributename",
    "whitespace_singlequote" => "attributevalue1",
    "whitespace_doublequote" => "attributevalue2",
    "equal_singlequote" => "attributevalue1",
    "equal_doublequote" => "attributevalue2",
    "equal_alphabet" => "atributevalue0",
    "equal_decimal" => "attributevalue0",
    "attributename_endtag" => "text",
    "attributename_equal" => "equal",
    "attributename_whitespace" => "whitespace",
    "attributename_alphabet" => "attributename",
    "attributename_decimal" => "attributename",
    "attributevalue0_alphabet" => "attributevalue0",
    "attributevalue0_decimal" => "attributevalue0",
    "attributevalue0_other" => "attributevalue0",
    "attributevalue1_starttag" => "attributevalue1",
    "attributevalue1_endtag" => "attributevalue1",
    "attributevalue1_singlequote" => "whitespace",
    "attributevalue1_doublequote" => "attributevalue1",
    "attributevalue1_equal" => "attributevalue1",
    "attributevalue1_slash" => "attributevalue1",
    "attributevalue1_exclamation" => "attributevalue1",
    "attributevalue1_whitespace" => "attributevalue1",
    "attributevalue1_alphabet" => "attributevalue1",
    "attributevalue1_decimal" => "attributevalue1",
    "attributevalue1_other" => "attributevalue1",
    "attributevalue2_starttag" => "attributevalue2",
    "attributevalue2_endtag" => "attributevalue2",
    "attributevalue2_equal" => "attributevalue2",
    "attributevalue2_singlequote" => "attributevalue2",
    "attributevalue2_doublequote" => "whitespace",
    "attributevalue2_slash" => "attributevalue2",
    "attributevalue2_exclamation" => "attributevalue2",
    "attributevalue2_whitespace" => "attributevalue2",
    "attributevalue2_alphabet" => "attributevalue2",
    "attributevalue2_decimal" => "attributevalue2",
    "attributevalue2_other" => "attributevalue2",
    "text_starttag" => "starttag",
    "text_equal" => "text",
    "text_singlequote" => "text",
    "text_doublequote" => "text",
    "text_slash" => "text",
    "text_exclamation" => "text",
    "text_whitespace" => "text",
    "text_alphabet" => "text",
    "text_decimal" => "text",
    "text_other" => "text"
  };
  if(defined($transite_matrix->{"${state}_${type}"})) {
    return ($transite_matrix->{"${state}_${type}"}, "");
  }
  else {
    if(defined($transite_matrix->{"text_${type}"})) {
      return ($transite_matrix->{"text_${type}"}, 'unexpect charactor');
    }
    else {
      return('text', 'unexpect charactor');
    }
  }
}

sub judge_type {
  my $c = shift;

  if($c eq '<') {
    return 'starttag';
  }
  elsif($c eq '>') {
    return 'endtag';
  }
  elsif($c eq '=') {
    return 'equal';
  }
  elsif($c eq '\'') {
    return 'singlequote';
  }
  elsif($c eq '"') {
    return 'doublequote';
  }
  elsif($c eq '/') {
    return 'slash';
  }
  elsif($c eq '!') {
    return 'exclamation';
  }
  elsif($c =~ /\s/) {
    return 'whitespace';
  }
  elsif($c =~ /[a-zA-Z]/) {
    return 'alphabet';
  }
  elsif($c =~ /\d/) {
    return 'decimal';
  }
  else {
    return 'other';
  }
}

1;
