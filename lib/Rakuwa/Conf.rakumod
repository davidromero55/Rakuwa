unit module Rakuwa::Conf;
use JSON::Fast;
our %conf is export = from-json(slurp('config.json'));