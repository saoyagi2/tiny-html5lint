use strict;
use warnings;

use Test::More('no_plan');

require_ok('./tiny-html5lint.pl');

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
<div class=red>
</div>
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
