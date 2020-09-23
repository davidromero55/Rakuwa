use Rakuwa::Conf;
use Rakuwa::Common;

class Rakuwa::Form does Rakuwa::Common does Rakuwa::Conf {
    has Hash::MultiValue $.params is rw;
    has Str $.id is rw;
    has Str $.name is rw;
    has Str $.method is rw = 'POST';
    has @.fields is rw;
    has @.submits is rw = [qw/Save/];
    has %.values is rw;

    submethod TWEAK() {

        # Default ID
        $!id = $!rakuwa.controller{View} ~ '_form';

        ## Default name
        if (!$.name) {
            $!name = $!id;
        }

    # Fields
#    $self->{fields} = {};
#    foreach my $field_name (@{$self->{params}->{fields}}){
#        $self->{fields}->{$field_name} = {name=>$field_name, class=>'form-control form-control-sm'};
#    }
#
#    $self->{tabs} = [];
#
#    # Submits
#    $self->{submits} = {};
#    my @btn_class = ('btn-primary','btn-secondary','btn-danger','btn-secondary','btn-secondary','btn-secondary');
#    foreach my $submit_name (@{$self->{params}->{submits}}){
#        $self->{submits}->{$submit_name} = {type => 'submit', name=>$submit_name, class=>'btn mr-1 ' . shift(@btn_class)};
#    }
#
#    # Default Action
#    if(!$self->{params}->{action}){
#        $self->{params}->{action} = $ENV{SCRIPT_URL} || $ENV{REQUEST_URI};
#        if($self->{params}->{action} =~ /\?/){
#            $self->{params}->{action} =~ s/(\?.*)//;
#        }
#    }
#
#    # Default class
#    $self->{params}->{class} .= 'form-horizontal needs-validation' if(!$self->{params}->{class});
#
#    # Control fields
#    $self->field('_submit',{type=>'hidden', value=>''});
#    $self->field('_submitted',{type=>'hidden', value=>$self->{id}});
    }

    method render returns Str {






        return "Form";
    }
}
