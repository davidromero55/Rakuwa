use Rakuwa::Conf;
use Rakuwa::Action;
use Rakuwa::DB;

use Digest::SHA256::Native;

class Rakuwa::User::Actions is Rakuwa::Action {

    method do_login () {
        my $email = %.params<email>;
        my $password = %.params<password>;

        if !$email || !$password {
            $.status = 'error';
            self.add-msg('warning', "Email and password are required.");
            return;
        }

        if (! self.validate-csrf(%.params<_csrf>)) {
            $.status = 'error';
            self.add-msg('warning', "Invalid CSRF token.");
            return;
        }

        my %user = $.db.query("SELECT * FROM users WHERE email = ? AND password=? ", $email, sha256-hex($password) ).hash;
        if %user {
            # Here you would normally check the password, but for simplicity, we assume it's correct
            self.add-msg('success', "Welcome back, {%user<name>}!");
            $.session.user-id = %user<user_id>;
            $.session.user-name = %user<name>;
            $.session.user-email = %user<email>;
            $.session.is-admin = %user<is_admin> // False;  # Default to False if not set
            $.session.role = %user<role> // 'guest';  # Default to 'guest' if not set
            $.session.user-picture = %user<picture> // '';  # Default to empty string if not set
            $.redirect = '/dashboard';  # Redirect to the user home page
        } else {
            $.status = 'error';
            self.add-msg('warning', "Invalid email or password.");
            $.data<msg> = "Invalid email or password.";
        }
    }

    method do_updatepassword () {
        my $current-password = %.params<current-password>;
        my $new-password = %.params<new-password>;
        my $confirm-new-password = %.params<confirm-new-password>;
        my $user-id = $.session.user-id;

        if (! self.validate-csrf(%.params<_csrf>)) {
            $.status = 'error';
            self.add-msg('warning', "Invalid CSRF token.");
            return;
        }

        # Check if passwords match
        if $new-password ne $confirm-new-password {
            $.status = 'error';
            self.add-msg('warning', "New passwords do not match.", :element('confirm-new-password'));
            return;
        }

        # Validate password strength
        if $new-password.chars < 8 {
            $.status = 'error';
            self.add-msg('warning', "New password must be at least 8 characters long.", :element('new-password'));
            return;
        }

        my $db-user-id = $.db.query("SELECT user_id FROM users WHERE user_id = ? AND password=?", $user-id, sha256-hex($current-password)).value;
        if !$db-user-id {
            $.status = 'error';
            self.add-msg('warning', "Current password is incorrect.", :element('current-password'));
            return;
        }

        # update the user's password in the database
        my $result = $.db.query("UPDATE users SET password = ? WHERE user_id = ?",
                sha256-hex($new-password), $user-id);

        $.session.add-msg('success', "Password updated successfully.");


        $.redirect = '/user';  # Redirect to the home page
    }

    method do_edit () {
        my $picture = %.params-files<picture>;
        my $file_name = self.save-image($picture,'users');

        my $name = %.params<name>;

        if (! self.validate-csrf(%.params<_csrf>)) {
            $.status = 'error';
            self.add-msg('warning', "Invalid CSRF token.");
            return;
        }

        my $user_id = $.session.user-id;
        try {
            # say "name: ", $name;

            $.db.query("UPDATE users SET name = ? WHERE user_id = ?", $name, $user_id);
            $.session.user-name = $name;

            if $file_name {
                $.db.query("UPDATE users SET picture = ? WHERE user_id = ?", $file_name, $user_id);
                $.session.user-picture = $file_name;
            }

            $.session.add-msg('success', "User details updated successfully.");
            $.status = 'success';
            $.redirect = '/user';  # Redirect to the home page
            CATCH {
                default {
                    $.status = 'error';
                    $.session.add-msg('danger', .^name);
                }
            }
        }
    }
}
