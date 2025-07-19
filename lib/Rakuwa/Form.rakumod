use Rakuwa::Conf;
use Rakuwa::View;
use Template6;

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
    has $.template is rw = 'form.tt';
    has $.class is rw = 'needs-validation';
    has $.request is rw;
    has @.path is rw = ();
    has %.form-attributes is rw = {};

    has $.form_start is rw = '';
    has $.form_end is rw = '</form>';
    has $.multipart is rw = False; # Default to False

    has %.field_message;

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
            %.fields{$field_name} =  {:name($field_name), :class('form-control form-control-sm' )};
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
        %.fields{$field_name}{"class"} = 'form-control form-control-sm' unless $.fields{$field_name}{"class"};
    }

    method submit ($name, %attrs) {
        # Prevent null
        if (%.submits{$name}.exists($name)) {
            @.submits-names.push: $name;
        }

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
        %.fields{$field_name}{'value'} //= '' unless %.fields{$field_name}{'value'}:exists;
        if $.request.query-hash{$field_name}:exists {
            %.fields{$field_name}{'value'} = $.request.query-hash{$field_name};
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
            %field{'class'} = "form-check-input" // False;

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
        my $template = $.template;
        my $TT = Template6.new(:include-path([%.conf<Template><template_dir> ~ '/']));
        $TT.add-path(%.conf<Template><template_dir> ~ '/');

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

        $.content = $TT.process("form",
                :title($.title),
                :form_start($.form_start),
                :form_end($.form_end),
                :fields(@fields-array),
                :@hidden-fields,
                :submits(@submits-array),
                :msg(self.get-msgs),
                :debug(%.conf<App><debug>));
    }

}
