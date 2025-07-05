use Rakuwa::Conf;
use Rakuwa::View;
use Rakuwa::Form;
use DB::MySQL;
use Rakuwa::DB;

class Rakuwa::User::Views is Rakuwa::View {

    method display_home () {
        $.template    = 'user/display-home';
        %.page<title> = 'My Account';
        my $db = get-db;
        %.data<user> = $db.query("SELECT * FROM users WHERE user_id = ?", $.session.user-id).hash;
    }

    method display_login () {
        $.template     = 'user/display-login';
        $.page<title> = 'User Login';
        $.data<message> = 'Welcome to the User Home Page';
        my $form = Rakuwa::Form.new(
                :title('User Login'),
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

    method display_updatepassword () {
        %.page<title> = 'Update Password';
        my $form = Rakuwa::Form.new(
                :title('Update Password'),
                :request($.request),
                :path(@.path),
                :name('updatepassword-form'),
                :action('/user/updatepassword'),
                :method('POST'),
                :fields-names(["name", "current-password", "new-password", "confirm-new-password"]),
                :submits-names(["Update Password"])
                );
        $form.init;
        $form.field('name', {:type('text'), :placeholder('Name'), :readonly, :value($.session.user-name)});
        $form.field('current-password', {:type('password'), :placeholder('Current Password'), :required, :help('Enter your current password')});
        $form.field('new-password', {:type('password'), :placeholder('New Password'), :required, :help('Enter your new password')});
        $form.field('confirm-new-password', {:type('password'), :placeholder('Confirm New Password'), :required, :help('Re-enter your new password')});
        $form.render;
        $.status = $form.status;
        $.content = $form.content;
    }

}
