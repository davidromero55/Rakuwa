use Rakuwa;
use Rakuwa::Conf;
use Crust::Request;
use Template6;

class Rakuwa::Layout does Rakuwa::Conf {
    has Rakuwa $.rakuwa;

    method process (Str $content, %vars, Str $default_template_file) returns Str {
        my $template_file = $default_template_file;
        if $.rakuwa.controller{'Layout'} eq 'Public' {
            if $template_file.codes == 0 {
                $template_file = 'templates/' ~ $.conf<Template><TemplateID> ~ '/layout';
            }
#        } elsif $.rakuwa.controller{'Layout'} eq 'User' {
#            if $template_file.codes == 0 {
#                if($self->{Zera}->{_SESS}->{_sess}{user_id}){
#                    $template_file = 'templates/' . $conf->{Template}->{UserTemplateID} . '/layout.html'
#                }else{
#                    $template_file = 'templates/' . $conf->{Template}->{UserTemplateID} . '/layout_out.html'
#                }
#            }
#        }elsif($self->{Zera}->{_Layout} eq 'Admin'){
#            if (!$template_file) {
#                if($self->{Zera}->{_SESS}->{_sess}{user_id} and $self->{Zera}->{_SESS}->{_sess}{is_admin}){
#                    $template_file = 'templates/' . $conf->{Template}->{AdminTemplateID} . '/layout.html'
#                }else{
#                    $template_file = 'templates/' . $conf->{Template}->{AdminTemplateID} . '/layout_out.html'
#                }
#            }
        } else {
            if $template_file.codes == 0 {
                $template_file = 'templates/' ~ $.conf<Template><TemplateID> ~ '/layout';
            }
        }


        my $TT = Template6.new(path => [$.conf{'App'}{'HomeDir'} ~ '/']);
#            #            msg     => $self->{Zera}->get_msg(),
        return $TT.process($template_file, :page($.rakuwa.page), :content($content), :vars(%vars), :conf($.conf));
    }
}
