unit module Rakuwa::Session;

use Rakuwa::Conf;
use Rakuwa::SessionObject;
use Rakuwa::Conf;
use Rakuwa::DB;
use Cro::HTTP::Session::MySQL;


sub get-session(--> Cro::HTTP::Session::MySQL[Rakuwa::SessionObject]) is export {

    return Cro::HTTP::Session::MySQL[Rakuwa::SessionObject].new(
        :db(get-db),
        :expiration(Duration.new(60 * 60)),
        :cookie-name(%conf<session><name>),
    );
}


