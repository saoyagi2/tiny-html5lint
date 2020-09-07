use strict;
use warnings;

use Test::More('no_plan');

require_ok('./tiny-html5lint.pl');

# html5lint
{
  my $result_ref;

  # emtpry string
  $result_ref = html5lint(<<"HTML"
HTML
  );
  is($result_ref->{'code'}, 0, "html5lint exit code 'empty string'");
  is($result_ref->{'message'}, "", "html5lint message 'empty string'");

  # ok html
  $result_ref = html5lint(<<"HTML"
<!DOCTYPE html>
<html>
<body id = "contaner">
<br />
</boty>
</html>
HTML
  );
  is($result_ref->{'code'}, 0, "html5lint exit code 'ok html'");
  is($result_ref->{'message'}, "", "html5lint message 'ok html'");

  # tag broken html
  $result_ref = html5lint(<<"HTML"
<!DOCTYPE html>
<html
<body>
</boty>
</html>
HTML
  );
  is($result_ref->{'code'}, 1, "html5lint exit code 'tag borken html'");
  is($result_ref->{'message'}, "unexpect charactor(3:1)\n", "html5lint message 'tag borken html'");

  # tag broken html
  $result_ref = html5lint(<<"HTML"
<!DOCTYPE html>
<html>
<body>
</boty>>
</html>
HTML
  );
  is($result_ref->{'code'}, 1, "html5lint exit code 'tag borken html'");
  is($result_ref->{'message'}, "unexpect charactor(4:8)\n", "html5lint message 'tag borken html'");
}

# judge_type
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
