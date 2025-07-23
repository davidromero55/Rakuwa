use Rakuwa::Conf;
use Template6;
use Rakuwa::SessionObject;

class Rakuwa::Layout {

    has $.template-dir is rw = 'main';
    has $.template is rw = "layout.crotmp";
    has Rakuwa::SessionObject $.session is rw;
    has $.db is rw;
    has $.request is rw;


    method render ($view --> Str) {
        my @apps;
        if ($.session.is-admin) {
            @apps = $.db.query("SELECT * FROM apps WHERE active=1").hashes;
            for @apps -> %app {
                %app{'menu'} = $.db.query("SELECT * FROM menus WHERE app = ? ORDER BY sort_order", "Blog").hashes;
            }
        }

        my $buttons = $view.buttons.join("");
        if $buttons.chars > 0 {
            $buttons = $view._tag('div',{:class('btn-group btn-group-sm'),:role('group') },$buttons);
        }

        my $TT = Template6.new();
        $TT.add-path(%conf<template><template_dir> ~ '/' ~ $.template-dir ~ '/');
        return $TT.process("layout",
                :page($view.page),
                :content($view.content),
                :user-id($.session.user-id),
                :user-name($.session.user-name),
                :is-admin($.session.is-admin),
                :role($.session.role),
                :generator("{%conf<name>} {%conf<version>}"),
                :@apps,
                :$buttons,
                );
    }

}
