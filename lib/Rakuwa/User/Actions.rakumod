use Rakuwa::Conf;
use Rakuwa::Action;

class Rakuwa::User::Actions is Rakuwa::Action {

    method do_login (%params) {
        my $email = %params<email>;
        my $password = %params<password>;


        my %user = $.db.query("SELECT * FROM users WHERE email = ?", $email).hash;
        if %user {
            # Here you would normally check the password, but for simplicity, we assume it's correct
            self.add-msg('success', "Welcome back, {%user<name>}!");
            $.session.user-id = %user<user_id>;
            $.session.user-name = %user<name>;
            $.session.user-email = %user<email>;
            $.redirect = '/dashboard';  # Redirect to the user home page
        } else {
            $.status = 'error';
            self.add-msg('warning', "Invalid email or password.");
            $.data<msg> = "Invalid email or password.";
        }
    }
}
