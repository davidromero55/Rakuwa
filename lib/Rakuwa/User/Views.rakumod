use Rakuwa::Conf;
use Rakuwa::View;
use Rakuwa::Form;
use Cro::WebApp::Template;

class Rakuwa::User::Views is Rakuwa::View {
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
        my $form = Rakuwa::Form.new(
            :request($.request),
            :path(@.path),
            :name('login-form'),
            :action('/user/login'),
            :method('POST'),
            :fields-names(["email", "password"]),
            :submits-names(["login"])
        );
        $form.init;
        $form.field('email', {:type('email'), :placeholder('Email'), :required, :help('Enter your email address')});
        $form.field('password', {:type('password'), :placeholder('Password'), :required});

        $form.render;
        $.status = $form.status;
        $.content = $form.content;
    }

}
