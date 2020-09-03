role Rakuwa::Conf {
    has %.conf = {
        App => { Name => 'Rakuwa', Version => 0.01, Language  => 'en_US', URL => 'rakuwa.net', URLLink   => 'https://rakuwa.net', Copyright => 'Rakuwa.net', HomeDir => '/usr/local/WS/Rakuwa/resources'},
        DB => { host => 'localhost', port => 3306, user => 'rakuwa', password => 'Passw0rd#', database => 'rakuwa' },
        Cookie => { Name      => 'Rakuwa', 'Max-Age' => '31536000', Domain => 'rakuwa.net', SameSite  => 'Strict', Path => '/'},
        Template => { TemplateID => 'Rakuwa', UserTemplateID => 'RakuwaUser', AdminTemplateID => 'RakuwaAdmin' },
        Security => { Key => 'RandomSecurityString' },
        Email => { Server   => 'localhost', Port => '587', Auth => 'LOGIN', User => 'hola@rakuwa.net', Password => 'MyPassword', From => 'hello@rakuwa.net', SSL => 'starttls' },
        Debug => True,
    };
}
