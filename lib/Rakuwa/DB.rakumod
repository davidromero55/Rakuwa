unit module Rakuwa::DB;

use Rakuwa::Conf;
use DB::MySQL;

my $db;

sub init-db is export {
    my $conf = Rakuwa::Conf.new;
    my %db_conf = $conf.get('DB');

    if %db_conf {
        $db = DB::MySQL.new(
            :host(%db_conf<host>),
            :port(%db_conf<port>),
            :user(%db_conf<user>),
            :password(%db_conf<password>),
            :database(%db_conf<database>),
            :charset('utf8mb4')
        );
    } else {
        die "Database configuration not found in Rakuwa::Conf";
    }
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
