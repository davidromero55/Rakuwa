#!/usr/bin/raku

use lib ".";
use lib "/usr/local/WS/Rakuwa/lib/";
use lib "/usr/local/WS/p6-Crust/lib/";

use FastCGI::NativeCall::PSGI;
use Crust::Builder;
use Rakuwa::Handler;

my &app = builder {
      mount "/" , sub (%env) {

            if (%env{'psgi.input'}) {
                  %env{'p6w.input'} = %env{'psgi.input'}.decode;
            }
            my $Handler = Rakuwa::Handler.new();
            start { $Handler.call(%env) };

#      my $HTML = '';
#      for %env.kv -> $key, $value {
#          $HTML = $HTML ~ " $key = $value <br>";
#      }
#      start { 200, [Content-Type => "text/html"], [$HTML] };
      }
};
my $psgi = FastCGI::NativeCall::PSGI.new(socket => 0);
$psgi.run(&app);
