use Rakuwa::Page;
use Rakuwa::Conf;
use Crust::Request;

class Rakuwa::Layout does Rakuwa::Page does Rakuwa::Conf {
    has Crust::Request $.request;
    has Hash::MultiValue $.params;
    has %.controller;

    method process (Str $content, %vars, Str $default_template_file) returns Str {
        my $template_file = $default_template_file;
        if $.controller{'Layout'} eq 'Public' {
            if $template_file.codes == 0 {
                $template_file = 'templates/' ~ $.conf<Template><TemplateID> ~ '/layout.html';
                #        }
                #    }elsif($self->{Zera}->{_Layout} eq 'User'){
                #        if (!$template_file) {
                #            if($self->{Zera}->{_SESS}->{_sess}{user_id}){
                #                $template_file = 'templates/' . $conf->{Template}->{UserTemplateID} . '/layout.html'
                #            }else{
                #                $template_file = 'templates/' . $conf->{Template}->{UserTemplateID} . '/layout_out.html'
                #            }
                #        }
                #    }elsif($self->{Zera}->{_Layout} eq 'Admin'){
                #        if (!$template_file) {
                #            if($self->{Zera}->{_SESS}->{_sess}{user_id} and $self->{Zera}->{_SESS}->{_sess}{is_admin}){
                #                $template_file = 'templates/' . $conf->{Template}->{AdminTemplateID} . '/layout.html'
                #            }else{
                #                $template_file = 'templates/' . $conf->{Template}->{AdminTemplateID} . '/layout_out.html'
                #            }
                #        }
                #    }else{
                #        if (!$template_file) {
                #            $template_file = 'templates/' . $conf->{Template}->{TemplateID} . '/layout.html'
                #        }
            }

            #    my $tt = Zera::Com::template();
            #    my $tt_vars = {
            #        conf    => $conf,
            #        content => $content,
            #        vars    => $vars,
            #        page    => $self->{Zera}->{_PAGE},
            #        msg     => $self->{Zera}->get_msg(),
            #        Zera    => $self->{Zera},
            #    };
            #
            #    $tt->process($template_file, $tt_vars, \$HTML) or $HTML = $tt->error();
            #    return $HTML;
            return $template_file;
        }
    }
}

