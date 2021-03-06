use strict;
use warnings;

use Test::More('no_plan');

require_ok('./tiny-html5lint.pl');

{
  my $type;
  $type = judge_type('<');
  is($type, 'starttag', '"<" is starttag');
  $type = judge_type('>');
  is($type, 'endtag', '">" is endtag');
  $type = judge_type('=');
  is($type, 'equal', '"=" is equal');
  $type = judge_type('\'');
  is($type, 'singlequote', '"\'" is singlequote');
  $type = judge_type('"');
  is($type, 'doublequote', '"\"" is doublequote');
  $type = judge_type('/');
  is($type, 'slash', '"/" is slash');
  $type = judge_type(' ');
  is($type, 'whitespace', '" " is whitespace');
  $type = judge_type("\t");
  is($type, 'whitespace', '\\t is whitespace');
  $type = judge_type("\n");
  is($type, 'whitespace', '\\n is whitespace');
  $type = judge_type('a');
  is($type, 'other', '"a" is other');
  $type = judge_type('1');
  is($type, 'other', '"1" is other');
  $type = judge_type('$');
  is($type, 'other', '"$" is other');
  $type = judge_type('!');
  is($type, 'other', '"!" is other');
}
