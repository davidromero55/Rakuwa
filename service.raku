use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Routes;

my Cro::Service $http = Cro::HTTP::Server.new(
    :http(<1.1>),
    :host(%*ENV<RAKUWA_HOST> || die("Missing RAKUWA_HOST in environment")),
    :port(%*ENV<RAKUWA_PORT> || die("Missing RAKUWA_PORT in environment")),
    :application(routes()),
    :after([
        Cro::HTTP::Log::File.new(:logs($*OUT), :errors($*ERR))
    ])
);
$http.start;
say "Listening at http://%*ENV<RAKUWA_HOST>:%*ENV<RAKUWA_PORT>";
react {
    whenever signal(SIGINT) {
        say "Shutting down...";
        $http.stop;
        done;
    }
}
