use Rakuwa::Conf;
use Rakuwa::Layout;
use Template6;
use Rakuwa::SessionObject;
use Rakuwa::DB;

class Rakuwa::View {
    has %.page is rw = {
        :title(%conf<name>),
        :description(''),
        :keywords('')
    }
    has Int $.status is rw = 0; # Default status code
    has %.headers is rw;
    has $.content is rw = "";
    has $.template is rw = ""; # Default template
    has %.data is rw = {
    };
    has @.path is rw = ();
    has $.request is rw;
    has $.db is rw = get-db();
    has Rakuwa::SessionObject $.session is rw = $!request.auth;

    has @.buttons is rw = ();

    method render (%vars={}) {
        # Prepare the view for rendering
        self.prepare_for_render(%vars);

        if $.status == 0 {
            $.status = 200; # Default status code
            my $TT = Template6.new();
            $TT.add-path(%conf<template><template_dir> ~ '/');
            $.content = $TT.process(self.template,
                    :data(%.data),
                    :page(%.page),
                    :msg(self.get-msgs),
                    );
        }

        if $.status == 200 {
            my $layout = Rakuwa::Layout.new(:$.session, :$.db, :$.request);
            self.page = %.page;
            self.buttons = @.buttons;
            $.content = $layout.render(self);
        }
    }

    method prepare_for_render (%vars={}) {
        $.data<vars> = %vars;

        # Prepare the view for rendering
        # Override this method in subclasses if needed
    }

    method add-msg(Str $type, Str $message, :$element = '') {
        $!request.auth.add-msg($type,$message, :$element);
    }

    method get-msgs(--> Str) {
        my @msgs = $!request.auth.get-msgs;
        my $html-alerts = '';
        for @msgs -> %msg {
            # Create HTML alert messages
            $html-alerts ~= "<div class='alert alert-{%msg<type>}' role='alert'>";
            $html-alerts ~= "<strong>{%msg<message>}</strong>";
            $html-alerts ~= "</div>";
        }
        return $html-alerts;
    }

    method _tag (Str $tag, Hash $attributes, $content='', :$onlystart = False --> Str) {
        # Helper method to create HTML tags with attributes and content
        my $attrs = '';
        for $attributes.kv -> $key, $value {
            $attrs ~= "$key=\"$value\" ";
        }
        if $onlystart {
            return "<{$tag} {$attrs}>";
        } else {
            if $tag eq 'img' {
                return "<{$tag} {$attrs} />";
            }
            return "<{$tag} {$attrs}>{$content}</{$tag}>";
        }

    }

    method add-button (Str $label, Str $url, :$class = 'btn btn-sm btn-secondary', :$id = 'btn', :$icon = '') {
        my $icon_html = '';
        $icon_html = "<span class=\"material-symbols-outlined\">{$icon}</span> " if $icon ne '';

        @.buttons.push(self._tag('a', {
            :href($url),
            :type('button'),
            :$class,
            :$id,
        }, "{$icon_html}{$label}"));
    }

    method exists (--> Bool) {
        if (self.can("{self.get-view-function-name}")) {
            return True;
        }
        return False;
    }

    method execute() {
        # Execute the action function if it exists
        my $view-function = self.get-view-function-name;
        self."$view-function"();
        self.render;
        self.free;
    }

    method get-view-function-name ( --> Str) {
        # Get the view function name from the path
        my $ViewName = "display_home";
        with @.path[0] {
            $ViewName = "display_" ~ @.path[0].lc;
            $ViewName ~~ s:g/\W//; # Sanitize the function name
        }
        return $ViewName;
    }

    method get-selectbox-data (Str $sql) {
        my @data = $.db.query($sql).arrays;

        my %data = {
            :options([]),
            :labels({}),
        };
        for @data -> @row {
            my $value = @row[0];
            my $label = @row[1];
            %data<options>.push($value);
            %data<labels>{$value} = $label;
        }
        return %data;
    }
    method free () {
        # Finalize the view, clean up resources if needed
        $!db.finish;
    }

}
