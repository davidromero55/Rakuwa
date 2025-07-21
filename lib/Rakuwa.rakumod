use Rakuwa::Conf;
use Rakuwa::View;
use Rakuwa::Layout;
#use Rakuwa::DB;
use Template6;

class Rakuwa {
    method not-found ($error --> Str) {
        my $TT = Template6.new();
        $TT.add-path(%conf<template><template_dir> ~ '/');
        my $content = $TT.process("404-view",
                :$error,
                );

        return $content;
    }
}

