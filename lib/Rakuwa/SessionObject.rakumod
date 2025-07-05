use Cro::HTTP::Auth;
use JSON::Class;

class Rakuwa::SessionObject does Cro::HTTP::Auth does JSON::Class {
    has $.user-id is rw = 0;
    has Str $.user-name is rw = '';
    has Str $.user-email is rw = '';

    has @.messages = [];

    method is-logged-in(--> Bool) {
        with $.user-id {
            return True if $_ > 0;
        }
        return False;
    }

    method logout(--> Nil) {
        $.user-id = 0;
        $.user-name = '';
        $.user-email = '';
    }

    method add-msg(Str $type, Str $message, :$element = '') {
        my %msg = %(
            'type'    => $type,
            'message' => $message,
            'element' => $element
        );
        @!messages.push(%msg);
    }

    method get-msgs(--> Array) {
        my @current-messages = @!messages;
        @!messages = [];
        return @current-messages;
    }

    method get-msgs-for-elements(){
        my %msgs-by-element;
        my @my-messages = self.get-msgs;
        my @non-element-messages;
        for @my-messages -> %msg {
            my $element = %msg<element>;
            if $element {
                %msgs-by-element{$element} //= [];
                %msgs-by-element{$element}.push(%msg);
            }else {
                self.add-msg(%msg<type>, %msg<message>);
            }
        }

        return %msgs-by-element;
    }

}

subset LoggedIn of Rakuwa::SessionObject where .is-logged-in;

