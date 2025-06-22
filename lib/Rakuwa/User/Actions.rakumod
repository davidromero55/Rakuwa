use Rakuwa::Conf;
use Rakuwa::Action;

class Rakuwa::User::Actions is Rakuwa::Action {

    method do_login () {
        my $email = $.request.query-value("email");
        my $password = $.request.query-value("password");

        say "Rakuwa: Attempting to log in user with email: $email";
        # Here you would typically validate the email and password
        # against a database or other user store.
        if $email && $password {
            $.status = 'success';
            $.data<msg> = "Login successful for user: $email";
            $.redirect = '/user/home';  # Redirect to the user home page
        } else {
            $.status = 'error';
            $.data<msg> = "Invalid email or password.";
        }
    }
}
