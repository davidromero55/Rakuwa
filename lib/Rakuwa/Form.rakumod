use Rakuwa::Conf;
use Rakuwa::Common;

class Rakuwa::Form does Rakuwa::Common does Rakuwa::Conf {
    has Hash::MultiValue $.params is rw;
    has Str $.id is rw;
    has Str $.name is rw;
    has Str $.method is rw = 'POST';
    has Str $.action is rw;
    has %.vars is rw;
    has @.fields is rw;
    has %.fieldsAttrs is rw;
    has @.submits is rw = [qw/Save/];
    has %.values is rw;
    has @.tabs is rw;
    has @.btnClass is rw = ('btn-primary','btn-secondary','btn-danger','btn-secondary','btn-secondary','btn-secondary');
    has Str $.class is rw = 'form-horizontal needs-validation';

    submethod TWEAK() {

        # Default ID
        $!id = $!rakuwa.controller{'View'} ~ '_form';

        ## Default name
        if (!($!name)) {
            $!name = $!id;
        }

#    # Fields
#    $self->{fields} = {};
#    foreach my $field_name (@{$self->{params}->{fields}}){
#        $self->{fields}->{$field_name} = {name=>$field_name, class=>'form-control form-control-sm'};
#    }

#    # Submits
#    foreach my $submit_name (@{$self->{params}->{submits}}){
#        $self->{submits}->{$submit_name} = {type => 'submit', name=>$submit_name, class=>'btn mr-1 ' . shift(@btn_class)};
#    }
#
#    # Default Action
        if (!$!action) {
            $!action = $!rakuwa.env{'SCRIPT_URL'} || $!rakuwa.env{'REQUEST_URI'};
            if ($!action ~~ /\?/) {
                $!action ~~ s/(\?.*)//;
            }
        }

        # Control fields
        self.field('_submit',{'type'=>'hidden', 'value'=>''});
        self.field('_submitted',{type=>'hidden', value=> $!id});
    }

    method field (Str $name, %attr){
        # Prevent null
        unless ( %.fieldsAttrs.EXISTS-KEY($name) ) {
            %.fieldsAttrs{$name} = { :$name, class=>'form-control form-control-sm'};
        }

        # Fill attributes
        for %attr.kv -> $key, $value {
            %.fieldsAttrs{$name}{$key} = $value;
        }

        # Push field to fields
        push(@.fields,$name) unless (@.fields.Set{$name});
    }

    method render returns Str {
        self!prepare_fields();

#        my $template_file = $self->{params}->{template} || 'zera_form';
#$template_file = ($self->{params}->{template} || 'zera_form_tabs') if($self->{tabs});
#    # Look for an available template
#    # 1. Current module template file
#    # 2. Current module lib file
#    # 3. template default file
#    # 4. Zera default file
#    my $current_template_dir = '';
#    if($self->{Zera}->{_Layout} eq 'Public'){
#        $current_template_dir = 'templates/' . $conf->{Template}->{TemplateID} . '/';
#    }elsif($self->{Zera}->{_Layout} eq 'User'){
#        $current_template_dir = 'templates/' . $conf->{Template}->{UserTemplateID} . '/';
#    }elsif($self->{Zera}->{_Layout} eq 'Admin'){
#        $current_template_dir = 'templates/' . $conf->{Template}->{AdminTemplateID} . '/';
#    }
#    if(-e($current_template_dir . $self->{Zera}->{ControllerName} . '/' . $template_file . '.html')){
#        $template_file = $current_template_dir . $self->{Zera}->{ControllerName} . '/' . $template_file . '.html';
#    }elsif(-e('Zera/' . $self->{Zera}->{ControllerName} . '/tmpl/' . $template_file . '.html')){
#        $template_file = 'Zera/' . $self->{Zera}->{ControllerName} . '/tmpl/' . $template_file . '.html';
#    }elsif(-e($current_template_dir . $template_file . '.html')){
#        $template_file = $current_template_dir . $template_file . '.html';
#    }elsif(-e('Zera/tmpl/' . $template_file . '.html')){
#        $template_file = 'Zera/tmpl/' . $template_file . '.html';
#    }else{
#        $self->{Zera}->add_msg('danger','Template ' . $template_file . '.html not found.');
#        return $self->{Zera}->get_msg();
#    }
#
#    my $tt = Zera::Com::template();
#    $vars->{vars}     = $self->{vars};
#    $vars->{tabs}     = $self->{tabs};
#    $vars->{conf}     = $conf;
#    $vars->{msg}      = $self->{Zera}->get_msg();
#    $vars->{page}     = $self->{Zera}->{_PAGE};
#    $vars->{sub_name} = $self->{Zera}->{sub_name};

        my $HTML = ' Form ';
        #$tt->process($template_file, $vars, \$HTML) || die $tt->error(), "\n";
        return $HTML;
    }

    method !prepare_fields {
        # Fields
        $.vars{'fields'} = [];
        for @.fields -> $fieldName {
            %.vars{'fields'}.append(self!prepare_field($fieldName));
        }

#
#    # Submits
#    $self->{vars}->{submits} = [];
#    foreach my $submit_name (@{$self->{params}->{submits}}){
#        push (@{$self->{vars}->{submits}},$self->_prepare_submit($submit_name));
#    }
#
#    # Form enclosing
#    $self->{vars}->{form_start} = $self->_get_form_start();
#    $self->{vars}->{form_end}   = '</form>';
    }

    method !prepare_field (Str $fieldName) returns Hash {

        # Process the attributes
        %.fieldsAttrs{$fieldName}{'label'} = self!create_label($fieldName) unless (%.fieldsAttrs{$fieldName}{'label'}.defined);

        %.fieldsAttrs{$fieldName}{'placeholder'} = self!create_label($fieldName) unless (%.fieldsAttrs{$fieldName}{'placeholder'}.defined);

        #    if((defined $self->param($field_name))){
        #        $self->{fields}->{$field_name}->{value} = $self->param($field_name);
        #    }

        # create te html
        %.fieldsAttrs{$fieldName}{'field'} = self!get_field($fieldName);

        return %.fieldsAttrs{$fieldName};
    }

    method !create_label (Str $fieldName) returns Str {
        my $label = $fieldName;
        $label ~~ s:g/_/ /;
        return $label.tc;
    }

    method !get_field (Str $fieldName) returns Str {
        my $fieldHtml = '';

        unless ( %.fieldsAttrs{$fieldName}{'type'}.defined ) {
            %.fieldsAttrs{$fieldName}{'type'} = 'text';
        }

        if ( %.values{$fieldName}.defined ) {
            %.fieldsAttrs{$fieldName}{'value'} = %.values{$fieldName};
        }

        given %.fieldsAttrs{$fieldName}{'type'} {
            when 'password' {
                for %.fieldsAttrs{$fieldName}.kv -> $key, $value {
                    next if ($key eq 'id');
                    next if ($key eq 'name');
                    next if ($key eq 'type');
                    next if ($key eq 'invalid_msg');
                    next if ($key eq 'help');
                    next if ($key eq 'override');
                    next if ($key eq 'label');
                    next if ($key eq 'value');
                    next if ($key eq 'span');
                    $fieldHtml = $fieldHtml ~ $key ~ '="' ~ $value ~ '" ';
                }
                $fieldHtml = '<input name="' ~ $fieldName ~ '" id="' ~ $fieldName ~ '" type="' ~ %.fieldsAttrs{$fieldName}{'type'} ~ '" ' ~ $fieldHtml ~ '/>';
             }
            default {
                for %.fieldsAttrs{$fieldName}.kv -> $key, $value {
                    next if ($key eq 'id');
                    next if ($key eq 'name');
                    next if ($key eq 'type');
                    next if ($key eq 'invalid_msg');
                    next if ($key eq 'help');
                    next if ($key eq 'override');
                    next if ($key eq 'label');
                    next if ($key eq 'span');
                    $fieldHtml = $fieldHtml ~ $key ~ '="' ~ $value ~ '" ';
                }
                $fieldHtml = '<input name="' ~ $fieldName ~ '" id="' ~ $fieldName ~ '" type="' ~ %.fieldsAttrs{$fieldName}{'type'} ~ '" ' ~ $fieldHtml ~ '/>';
            }
        }
#    switch ($self->{fields}->{$field_name}->{type}) {
#        case 'select' {
#            my $field_options = '';
#            foreach my $key(keys %{$self->{fields}->{$field_name}}){
#                next if($key eq 'id');
#                next if($key eq 'name');
#                next if($key eq 'type');
#                next if($key eq 'invalid_msg');
#                next if($key eq 'help');
#                next if($key eq 'override');
#                next if($key eq 'selectname');
#                next if($key eq 'label');
#                next if($key eq 'labels');
#                next if($key eq 'value');
#                next if($key eq 'span');
#                if($key eq 'options'){
#                    foreach my $option(@{$self->{fields}->{$field_name}->{$key}}){
#                        $field_options .= '<option';
#                        $field_options .= (($option eq $self->{fields}->{$field_name}->{value}) ? ' selected="1"':'');
#                        $field_options .= ' value="'.$option.'"';
#                        if($self->{fields}->{$field_name}->{labels}){
#                            if($self->{fields}->{$field_name}->{labels}->{$option}){
#                                $field_options .= '>'.$self->{fields}->{$field_name}->{labels}->{$option}.'</option>';
#                            }else{
#                                $field_options .= '>'.$option.'</option>';
#                            }
#                        }else{
#                            $field_options .= '>'.$option.'</option>';
#                        }
#                    }
#                }else{
#                    $field_html .= $key . '="' . $self->{fields}->{$field_name}->{$key} . '" ';
#                }
#            }
#
#            $field_html  = '<select name='.$field_name.'  '.$field_html.'>';
#            $field_html .= ($self->{fields}->{$field_name}->{selectname} ? '<option value="">' . $self->{fields}->{$field_name}->{selectname} . '</options>':'<option value="">Select an option</options>');
#            $field_html .= $field_options.'</select>';
#        }
#        case 'checkbox' {
#            $self->{fields}->{$field_name}->{class} = 'form-check-input' if($self->{fields}->{$field_name}->{class} eq 'form-control form-control-sm');
#            foreach my $key (keys %{$self->{fields}->{$field_name}}) {
#                next if($key eq 'id');
#                next if($key eq 'name');
#                next if($key eq 'type');
#                next if($key eq 'invalid_msg');
#                next if($key eq 'help');
#                next if($key eq 'override');
#                next if($key eq 'label');
#                next if($key eq 'span');
#                if($key eq 'value'){
#                    if($self->{fields}->{$field_name}->{$key}){
#                        $field_html .= ' checked="1" ';
#                    }
#                }else{
#                    $field_html .= $key . '="' . $self->{fields}->{$field_name}->{$key} . '" ';
#                }
#            }
#            $field_html  = '<input name="' . $field_name . '" id="' . $field_name . '" type="' . $self->{fields}->{$field_name}->{type} . '" value="1" ' . $field_html .'/>';
#            if($self->{fields}->{$field_name}->{check_label}){
#                $field_html .= "\n".'<label class="form-check-label" for="' . $field_name . '">' . $self->{fields}->{$field_name}->{check_label} . '</label>';
#            }else{
#                $field_html .= "\n".'<label class="form-check-label" for="' . $field_name . '">' . $self->{fields}->{$field_name}->{label} . '</label>' if($self->{fields}->{$field_name}->{label});
#            }
#        }
#        case 'textarea' {
#            foreach my $key (keys %{$self->{fields}->{$field_name}}) {
#                next if($key eq 'id');
#                next if($key eq 'name');
#                next if($key eq 'type');
#                next if($key eq 'invalid_msg');
#                next if($key eq 'help');
#                next if($key eq 'override');
#                next if($key eq 'label');
#                next if($key eq 'value');
#                next if($key eq 'span');
#                $field_html .= $key . '="' . $self->{fields}->{$field_name}->{$key} . '" ';
#            }
#            $self->{fields}->{$field_name}->{value} = '' if(!$self->{fields}->{$field_name}->{value});
#            my $value = $self->{fields}->{$field_name}->{value};
#            $value =~ s/&/&amp;/g;
#            $value =~ s/</&lt;/g;
#            $value =~ s/>/&gt;/g;
#            $field_html = '<textarea name="' . $field_name . '" id="' . $field_name . '" ' . $field_html .'>'.$value.'</textarea>';
#        }
#        case 'file' {
#            $self->{fields}->{$field_name}->{class} = 'custom-file-input' if(($self->{fields}->{$field_name}->{class} eq 'form-control form-control-sm'));
#            foreach my $key (keys %{$self->{fields}->{$field_name}}) {
#                next if($key eq 'id');
#                next if($key eq 'name');
#                next if($key eq 'type');
#                next if($key eq 'invalid_msg');
#                next if($key eq 'help');
#                next if($key eq 'override');
#                next if($key eq 'label');
#                next if($key eq 'value');
#                next if($key eq 'span');
#                $field_html .= $key . '="' . $self->{fields}->{$field_name}->{$key} . '" ';
#            }
#            $field_html = '<input name="' . $field_name . '" id="' . $field_name . '" type="' . $self->{fields}->{$field_name}->{type} . '" ' . $field_html .'/>' .
#                '<label class="custom-file-label" for="' . $field_name . '"></label>';
#
#            $self->{params}->{enctype} ="multipart/form-data";
#        }
#    }
        return $fieldHtml;
    }

}
