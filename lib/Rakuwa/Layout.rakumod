use Rakuwa::Conf;
use Template6;
use Rakuwa::DB;

use Rakuwa::SessionObject;

class Rakuwa::Layout {
    has $.template is rw = "layout.crotmp";
    has Rakuwa::SessionObject $.session is rw;

    method render ($view --> Str) {
        my $db = get-db;
        my @apps;
        if ($.session.is-admin) {
            @apps = $db.query("SELECT * FROM apps WHERE active=1").hashes;
            for @apps -> %app {
                %app{'menu'} = $db.query("SELECT * FROM menus WHERE app = ? ORDER BY sort_order", "Blog").hashes;
            }
        }



        my $TT = Template6.new();
        $TT.add-path(%conf<template><template_dir> ~ '/');
        return $TT.process("layout",
                :page($view.page),
                :content($view.content),
                :user-id($.session.user-id),
                :user-name($.session.user-name),
                :is-admin($.session.is-admin),
                :role($.session.role),
                :generator("{%conf<name>} {%conf<version>}"),
                :apps(@apps),
                );
    }

}
