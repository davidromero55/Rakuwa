unit module Rakuwa::Session;

use Rakuwa::Conf;
use Rakuwa::SessionObject;
use Rakuwa::Conf;
#use Cro::HTTP::Session::MySQL;
use DB::SQLite;
use Rakuwa::Session::SQLite;

my $db = DB::SQLite.new(filename => %conf<db><sessions_filename>);;
sub get-session(--> Rakuwa::Session::SQLite[Rakuwa::SessionObject]) is export {
    say "Creating new session handler...";
    # return Cro::HTTP::Session::MySQL[Rakuwa::SessionObject].new(
    #     :$db,
    #     :expiration(Duration.new(60 * 60)),
    #     :cookie-name(%conf<session><name>),
    # );

    return Rakuwa::Session::SQLite[Rakuwa::SessionObject].new(
        :$db,
        :expiration(Duration.new(60 * 60)),
        :cookie-name(%conf<session><name>),
    );

}
sub free-session-db( --> Nil) is export {
    say "Freeing session database connection...";
    $db.db.finish;
}

