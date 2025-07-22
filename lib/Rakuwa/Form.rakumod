use Rakuwa::Conf;
use Rakuwa::View;
use Template6;
use HTML::Escape;
use Digest::SHA256::Native;

class Rakuwa::Form is Rakuwa::View {
    has $.id is rw = "";
    has Str $.title is rw = '';
    has $.name is rw = "";
    has $.method is rw = 'post';
    has $.action is rw = '';
    has @.fields-names is rw = ();
    has %.fields is rw = {};
    has @.submits-names is rw = ();
    has %.submits is rw = {};
    has @.submit-classes is rw = ('btn-primary', 'btn-secondary', 'btn-danger', 'btn-secondary',
                                  'btn-secondary', 'btn-secondary');
    has $.template is rw = 'form';
    has $.class is rw = 'needs-validation';
    has $.request is rw;
    has @.path is rw = ();
    has %.form-attributes is rw = {};

    has $.form_start is rw = '';
    has $.form_end is rw = '</form>';
    has $.multipart is rw = False; # Default to False

    has %.field_message;
    has $.default_field_class = 'form-control form-control-sm';

    has %.values is rw = {};

    method init () {

        # Set form ID and name
        if ($.id.chars == 0) {
            if @.path.elems > 1 {
                $.id = @.path[1].lc;
            }elsif @.path.elems > 0 {
                $.id = @.path[0].lc;
            } else {
                $.id = 'rakuwa_form';
            }
        }
        if ($.name.chars == 0) {
            $.name = $.id;
        }

        # Fields
        for @.fields-names -> $field_name {
            %.fields{$field_name} =  {:name($field_name), :class('' )};
        }

        # Submits
        for @.submits-names -> $submit_name {
            %.submits{$submit_name} =  {:type('submit'), :name($submit_name )};
        }

        # Action
        if ($.action eq '') {
            if ($.request.path) {
                $.action = "/";
                if $.request.path_segments.elems > 0 {
                    $.action = $.action ~ @.request.path_segments[0];
                }
                if $.request.path_segments.elems > 1 {
                    $.action = $.action ~ "/" ~ @.request.path_segments[1];
                }
            }
        }

        # Control fields
        self.field('_submit', {:type('hidden'), :value('')});
        self.field('_submitted', {:type('hidden'), :value($.id)});

        # CSRF token
        my $csrf_token = sha256-hex(%conf<security><csrf_token> ~ $.session.user-id ~ time);
        $.session.csrf-token = $csrf_token;
        self.field('_csrf', {:type('hidden'), :value($csrf_token)});

        # Get errors messages if any
        %.field_message = {};
        my %messages_arrays = $.session.get-msgs-for-elements();
        for %messages_arrays.keys -> $field_name {
            my @messages = %messages_arrays{$field_name};
            my $message = '';
            for @messages -> @message {
                for @message -> %message {
                    $message ~= %message<message> ~ ' ';
                }
            }
            %.field_message{$field_name} = $message;
        }

    }

    method field (Str $field_name, %attrs) {
        if (%.fields{$field_name}:!exists) {
            @.fields-names.push: $field_name;
        }

        %.fields{$field_name} = %attrs if %attrs;
        %.fields{$field_name}{'name'} = $field_name;
        %.fields{$field_name}{"class"} = $.default_field_class unless $.fields{$field_name}{"class"};
    }

    method submit ($name, %attrs) {
        @.submits-names.push: $name unless @.submits-names.grep({ $_ eq $name });

        $.submits{$name} = %attrs if %attrs;
        $.submits{$name}{'type'} = 'submit' unless $.submits{$name}{'type'};
        $.submits{$name}{'name'} = $name unless $.submits{$name}{'name'};
    }

    method prepare_fields () {
        for @.fields-names -> $field_name {
            self.prepare-field($field_name);
        }

        # Submits
        my $id = 0;
        for @.submits-names -> $submit_name {
            self.prepare-submit($submit_name, $id);
            $id++;
        }

        # Form enclosing
        $.form_start = self.get-form-start();
        $.form_end = '</form>';

    }

    method prepare-submit ($submit_name, $id) {
        %.submits{$submit_name}{'label'} = self.create_label($submit_name) unless $.submits{$submit_name}{'label'};
        %.submits{$submit_name}{'class'} = 'btn btn-sm ' ~ @.submit-classes[$id] unless $.submits{$submit_name}{'class'};
        %.submits{$submit_name}{'submit'} = self.get_submit($submit_name);
    }

    method get_submit ($submit_name --> Str) {
        my $submit_html = '';

        if (!%.submits{$submit_name}{'type'}) {
            %.submits{$submit_name}{'type'} = 'submit';
        }

        %.submits{$submit_name}{'onclick'} = 'this.form._submit.value = this.name;';
        given %.submits{$submit_name}{'type'} {
            when ('submit') {
                %.submits{$submit_name}{"class"} = 'btn btn-secondary' unless %.submits{$submit_name}{"class"};
                for %.submits{$submit_name}.keys -> $key {
                    next if $key eq 'id';
                    next if $key eq 'name';
                    next if $key eq 'type';
                    $submit_html ~= "$key=\"" ~ %.submits{$submit_name}{$key} ~ "\" ";
                }
                return '<button name="' ~ $submit_name ~ '" id="' ~ $submit_name ~ '" type="' ~ %.submits{$submit_name}{'type'} ~ '" ' ~ $submit_html ~ '>' ~ %.submits{$submit_name}{'label'} ~ '</button>';
            }
            when ('btn') {
                %.submits{$submit_name}{"class"} = 'btn btn-secondary' unless %.submits{$submit_name}{"class"};
                for %.submits{$submit_name}.keys -> $key {
                    next if $key eq 'id';
                    next if $key eq 'name';
                    next if $key eq 'type';
                    $submit_html ~= "$key=\"" ~ %.submits{$submit_name}{$key} ~ "\" ";
                }
                return '<button name="' ~ $submit_name ~ '" id="' ~ $submit_name ~ '" type="' ~ %.submits{$submit_name}{'type'} ~ '" ' ~ $submit_html ~ '>' ~ %.submits{$submit_name}{'label'} ~ '</button>';
            }
            default {
                return 'Submit type "' ~ %.submits{$submit_name}{'type'} ~ '" not recognized.';
            }
        }
    }

    method prepare-field ($field_name) {
        %.fields{$field_name}{'type'} = 'text' unless %.fields{$field_name}{'type'}:exists;
        %.fields{$field_name}{'name'} = $field_name;
        %.fields{$field_name}{'id'} = $field_name unless $.fields{$field_name}{'id'};
        %.fields{$field_name}{'label'} = self.create_label($field_name) unless $.fields{$field_name}{'label'};
        %.fields{$field_name}{'html_label'} = '<label for="' ~ $.fields{$field_name}{'id'} ~ '">' ~ $.fields{$field_name}{'label'} ~ '</label>' unless $.fields{$field_name}{'html_label'};
        %.fields{$field_name}{'placeholder'} = %.fields{$field_name}{'label'} unless $.fields{$field_name}{'placeholder'};

        # Value handling
        if ($.request.query-hash{$field_name}:exists && $.request.query-hash{$field_name} ne '') {
            # If the field is in the query hash, use that value
            %.fields{$field_name}{'value'} = $.request.query-hash{$field_name};
        } elsif (%.values{$field_name}:exists && %.values{$field_name} ne '') {
            # If the field has a value in the values hash, use that
            %.fields{$field_name}{'value'} = %.values{$field_name};
        } else {
            # Otherwise, set the value to an empty string if it doesn't exist
            %.fields{$field_name}{'value'} = '' unless %.fields{$field_name}{'value'}:exists;
        }


        %.fields{$field_name}{'help'} //= '' unless %.fields{$field_name}{'help'}:exists;
        if (%.fields{$field_name}{'help'} ne '') {
            %.fields{$field_name}{'help'} = '<div id="' ~ $field_name ~ 'Help" class="form-text">' ~ %.fields{$field_name}{'help'} ~ '</div>';
        }

        %.fields{$field_name}{'error'} //= '' unless %.fields{$field_name}{'error'}:exists;
        if (%.fields{$field_name}{'error'} ne '') {
            %.fields{$field_name}{'error'} = '<div id="' ~ $field_name ~ 'Error" class="invalid-feedback">' ~ %.fields{$field_name}{'error'} ~ '</div>';
        }

        %.fields{$field_name}{'message'} = '';
        if (%.field_message{$field_name}) {
            %.fields{$field_name}{'message'} = '<span class="badge rounded-pill text-bg-warning">' ~ %.field_message{$field_name} ~ '</span>';
        }

        %.fields{$field_name}{'field'} = self.get-field($field_name);
    }

    method get-field (Str $field_name --> Str) {
        my $field_html = '';

        my %field = %.fields{$field_name};

        if (%field{'type'} eq 'hidden') {
            $field_html = '<input type="' ~ %field{'type'} ~ '" name="' ~ %field{'name'} ~ '" id="' ~ %field{'id'} ~ '" value="' ~ %field{'value'} ~ '" />';
            return $field_html;
        }

        if (%field{'type'} eq 'file') {
            $field_html ~= '<input type="' ~ %field{'type'} ~ '" name="' ~ %field{'name'} ~ '" id="' ~ %field{'id'} ~ '" ';
            for %field.keys -> $key {
                next if $key eq 'id';
                next if $key eq 'name';
                next if $key eq 'label';
                next if $key eq 'type';
                next if $key eq 'html_label';
                next if $key eq 'help';
                next if $key eq 'error';
                next if $key eq 'message';
                if (%field{$key}:exists) {
                    $field_html ~= "$key=\"" ~ %field{$key} ~ "\" ";
                }
            }
            $.multipart = True; # Set multipart for file uploads
            $field_html ~= '/>';
            return $field_html;

        }

        if (%field{'type'} eq 'checkbox') {
            %field{'class'} = "form-check-input" unless %field{'class'} ne $.default_field_class;

            if (%field{'value'}:exists && %field{'value'} eq '1') {
                %field{'checked'} = 'checked';
            }
            %field{'value'} = '1';

            $field_html ~= '<input type="' ~ %field{'type'} ~ '" name="' ~ %field{'name'} ~ '" id="' ~ %field{'id'} ~ '" ';
            for %field.keys -> $key {
                next if $key eq 'id';
                next if $key eq 'name';
                next if $key eq 'label';
                next if $key eq 'type';
                next if $key eq 'html_label';
                next if $key eq 'help';
                next if $key eq 'error';
                next if $key eq 'message';
                if (%field{$key}:exists) {
                    $field_html ~= "$key=\"" ~ %field{$key} ~ "\" ";
                }
            }
            $field_html ~= '/>';
            return $field_html;
        }

        if (%field{'type'} eq 'textarea') {
            $field_html ~= '<textarea name="' ~ %field{'name'} ~ '" id="' ~ %field{'id'} ~ '" ';
            for %field.keys -> $key {
                next if $key eq 'id';
                next if $key eq 'name';
                next if $key eq 'label';
                next if $key eq 'type';
                next if $key eq 'html_label';
                next if $key eq 'help';
                next if $key eq 'error';
                next if $key eq 'message';
                next if $key eq 'value';
                if (%field{$key}:exists) {
                    $field_html ~= "$key=\"" ~ %field{$key} ~ "\" ";
                }
            }
            $field_html ~= '>' ~ escape-html(%field{'value'}) ~ '</textarea>';
            return $field_html;
        }

        if (%field{'type'} eq 'select') {
            $field_html ~= '<select name="' ~ %field{'name'} ~ '" id="' ~ %field{'id'} ~ '" ';
            for %field.keys -> $key {
                next if $key eq 'id';
                next if $key eq 'name';
                next if $key eq 'label';
                next if $key eq 'type';
                next if $key eq 'html_label';
                next if $key eq 'help';
                next if $key eq 'error';
                next if $key eq 'message';
                next if $key eq 'options';
                next if $key eq 'labels';
                next if $key eq 'selectname';
                if (%field{$key}:exists) {
                    $field_html ~= "$key=\"" ~ %field{$key} ~ "\" ";
                }
            }
            $field_html ~= '>';
            if (%field{'selectname'}:exists) {
                $field_html ~= '<option value="">' ~ escape-html(%field{'selectname'}) ~ '</option>';
            }
            for %field<options>.Array -> $option {
                my $selected = '';
                if ($option eq %field{'value'}) {
                    $selected = ' selected="selected"';
                }
                my $option-label = $option;
                say %field{'labels'}.raku;
                if (%field{'labels'}.Hash:exists($option)) {
                    $option-label = %field{'labels'}{$option} // $option;
                }
                $field_html ~= '<option value="' ~ $option ~ '"' ~ $selected ~ '>' ~ escape-html($option-label) ~ '</option>';
            }
            $field_html ~= '</select>';
            return $field_html;
        }

        if (%field{'type'} eq 'radio') {
            %field{'class'} = "form-check-input" unless %field{'class'} ne $.default_field_class;
            for %field<options>.Array -> $option {
                my $selected = '';
                if ($option eq %field{'value'}) {
                    $selected = ' checked="checked"';
                }
                my $option_id = %field{'id'} ~ '-' ~ $option;
                $option_id = $option_id.subst(/\W/, '', :g);

                my $option-label = $option;
                say %field{'labels'}.raku;
                if (%field{'labels'}.Hash:exists($option)) {
                    $option-label = %field{'labels'}{$option} // $option;
                }

                $field_html ~= '<div class="form-check">';
                $field_html ~= '<input type="radio" name="' ~ %field{'name'} ~ '" id="' ~ $option_id ~ '" value="' ~ $option ~ '"' ~ $selected ~ ' ';
                for %field.keys -> $key {
                    next if $key eq 'id';
                    next if $key eq 'name';
                    next if $key eq 'label';
                    next if $key eq 'type';
                    next if $key eq 'html_label';
                    next if $key eq 'help';
                    next if $key eq 'error';
                    next if $key eq 'message';
                    next if $key eq 'options';
                    next if $key eq 'labels';
                    if (%field{$key}:exists) {
                        $field_html ~= "$key=\"" ~ %field{$key} ~ "\" ";
                    }
                }
                $field_html ~= '/>';
                $field_html ~= '<label class="form-check-label" for="' ~ $option_id ~ '">' ~ $option-label ~ '</label>';
                $field_html ~= '</div>';
            }
            return $field_html;
        }

        $field_html ~= '<input type="' ~ %field{'type'} ~ '" name="' ~ %field{'name'} ~ '" id="' ~ %field{'id'} ~ '" ';
        for %field.keys -> $key {
            next if $key eq 'id';
            next if $key eq 'name';
            next if $key eq 'label';
            next if $key eq 'type';
            next if $key eq 'html_label';
            next if $key eq 'help';
            next if $key eq 'error';
            next if $key eq 'message';
            if (%field{$key}:exists) {
                $field_html ~= "$key=\"" ~ %field{$key} ~ "\" ";
            }
        }
        $field_html ~= '/>';
        return $field_html;
    }

    method create_label ($field_name --> Str) {
        my $name = $field_name;
        $name .= subst(/_/, ' ', :g);
        $name .= subst(/\-/, ' ', :g);
        return $name.tclc;
    }

    method get-form-start (--> Str) {
        my $form_start = '';
        for %.form-attributes.keys -> $key {
            next if $key eq 'id';
            next if $key eq 'name';
            next if $key eq 'method';
            next if $key eq 'action';
            next if $key eq 'class';
            $form_start ~= "$key=\"" ~ %.form-attributes{$key} ~ "\" ";
        }
        $form_start ~= 'id="' ~ $.id ~ '" ';
        $form_start ~= 'name="' ~ $.name ~ '" ';
        $form_start ~= 'method="' ~ $.method ~ '" ';
        $form_start ~= 'action="' ~ $.action ~ '" ';
        $form_start ~= 'class="' ~ $.class ~ '" ';
        if ($.multipart) {
            $form_start ~= 'enctype="multipart/form-data" ';
        }
        $form_start = '<form ' ~ $form_start ~ '>';
        return $form_start;
    }

    method render (%vars={}) {
        # Prepare the view for rendering
        self.prepare_fields;

        $.status = 200;
        my $TT = Template6.new(:include-path([%conf<template><template_dir> ~ '/']));
        $TT.add-path(%conf<template><template_dir> ~ '/');

        my @fields-array;
        my @hidden-fields;
        for @.fields-names -> $field_name {
            if (%.fields{$field_name}{'type'} eq 'hidden') {
                @hidden-fields.push: %.fields{$field_name};
                next;
            } else {
                @fields-array.push: %.fields{$field_name};
            }
        }
        my @submits-array;
        for @.submits-names -> $submit_name {
            @submits-array.push: %.submits{$submit_name};
        }

        # clone @fields-array into a hash using the name for hash keys
        my %fields-hash = @fields-array.map({ $_<name> => $_ }).Hash;

        $.content = $TT.process($.template,
                :title($.title),
                :form_start($.form_start),
                :form_end($.form_end),
                :fields(@fields-array),
                :%fields-hash,
                :@hidden-fields,
                :submits(@submits-array),
                :msg(self.get-msgs),
                :debug(%conf<debug>));
    }

}
