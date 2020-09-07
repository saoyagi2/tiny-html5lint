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
    "starttag_slash" => "slash",
    "starttag_other" => "tagname",
    "slash_other" => "tagname",
    "slash_endtag" => "text",
    "tagname_endtag" => "text",
    "tagname_whitespace" => "whitespace",
    "tagname_other" => "tagname",
    "whitespace_endtag" => "text",
    "whitespace_slash" => "slash",
    "whitespace_equal" => "equal",
    "whitespace_whitespace" => "whitespace",
    "whitespace_other" => "attributename",
    "whitespace_singlequote" => "attributevalue1",
    "whitespace_doublequote" => "attributevalue2",
    "equal_singlequote" => "attributevalue1",
    "equal_doublequote" => "attributevalue2",
    "equal_whitespace" => "equal",
    "equal_other" => "atributevalue0",
    "attributename_endtag" => "text",
    "attributename_equal" => "equal",
    "attributename_whitespace" => "whitespace",
    "attributename_other" => "attributename",
    "attributevalue0_other" => "attributevalue0",
    "attributevalue1_starttag" => "attributevalue1",
    "attributevalue1_endtag" => "attributevalue1",
    "attributevalue1_singlequote" => "whitespace",
    "attributevalue1_doublequote" => "attributevalue1",
    "attributevalue1_equal" => "attributevalue1",
    "attributevalue1_slash" => "attributevalue1",
    "attributevalue1_whitespace" => "attributevalue1",
    "attributevalue1_other" => "attributevalue1",
    "attributevalue2_starttag" => "attributevalue2",
    "attributevalue2_endtag" => "attributevalue2",
    "attributevalue2_equal" => "attributevalue2",
    "attributevalue2_singlequote" => "attributevalue2",
    "attributevalue2_doublequote" => "whitespace",
    "attributevalue2_slash" => "attributevalue2",
    "attributevalue2_whitespace" => "attributevalue2",
    "attributevalue2_other" => "attributevalue2",
    "text_starttag" => "starttag",
    "text_equal" => "text",
    "text_singlequote" => "text",
    "text_doublequote" => "text",
    "text_slash" => "text",
    "text_whitespace" => "text",
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
  elsif($c =~ /\s/) {
    return 'whitespace';
  }
  else {
    return 'other';
  }
}

1;
