unit module Rakuwa::Session;

use Rakuwa::Conf;
use Rakuwa::SessionObject;
use Rakuwa::Conf;
use Rakuwa::DB;
use Cro::HTTP::Session::MySQL;


sub get-session(--> Cro::HTTP::Session::MySQL[Rakuwa::SessionObject]) is export {
    my $conf = Rakuwa::Conf.new;
    my %session_conf = $conf.get('Session');

    return Cro::HTTP::Session::MySQL[Rakuwa::SessionObject].new(
        :db(get-db),
        :expiration(Duration.new(60 * 60)),
        :cookie-name(%session_conf<name>),
    );
}


