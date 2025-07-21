use Rakuwa::Conf;
use Rakuwa::Layout;
use Template6;
use Rakuwa::SessionObject;

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
            my $layout = Rakuwa::Layout.new(:$.session);
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


}
