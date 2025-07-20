unit module Rakuwa::DB;

use Rakuwa::Conf;
use DB::MySQL;

my $db;

sub init-db is export {

    $db = DB::MySQL.new(
        :host(%conf<db><host>),
        :port(%conf<db><port>),
        :user(%conf<db><user>),
        :password(%conf<db><password>),
        :database(%conf<db><database>),
        :charset(%conf<db><charset>),
        );
}

sub get-db is export {
    if $db {
        return $db;
    } else {
        init-db;
    }
    return $db;
}

sub finalize-db is export {
    $db.finish;
}
