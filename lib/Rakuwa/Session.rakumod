unit module Rakuwa::Session;

use Rakuwa::Conf;
use Rakuwa::SessionObject;
use Rakuwa::Conf;
use Rakuwa::DB;
use Cro::HTTP::Session::MySQL;

my $db = get-db;
sub get-session(--> Cro::HTTP::Session::MySQL[Rakuwa::SessionObject]) is export {
    say "Creating new session handler...";
    return Cro::HTTP::Session::MySQL[Rakuwa::SessionObject].new(
        :$db,
        :expiration(Duration.new(60 * 60)),
        :cookie-name(%conf<session><name>),
    );
}
sub free-session-db( --> Nil) is export {
    say "Freeing session database connection...";
    $db.db.finish;
}

