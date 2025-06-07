use Rakuwa::Conf;
use Rakuwa::View;
use Cro::WebApp::Template;

class Rakuwa::User::View is Rakuwa::View {
    has %.page is rw = {
        :title('User View'),
        :description(''),
        :keywords('')
    }
    has $.template is rw = 'users/display-home.crotmp';

    method display_home () {
        $.template     = 'users/display-home.crotmp';
        $.page<title> = 'User Home';
        $.data<message> = 'Welcome to the User Home Page';
    }

    method display_login () {
        $.template     = 'users/display-login.crotmp';
        $.page<title> = 'User Login';
        $.data<message> = 'Welcome to the User Home Page';
    }

}
