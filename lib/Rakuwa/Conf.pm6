role Rakuwa::Conf {
    has %.conf = {
        App => { Name => 'Rakuwa', Version => 0.01, Language  => 'en_US', URL => 'rakuwa.com', URLLink   => 'https://rakuwa.com', Copyright => 'Rakuwa.com' },
        DB => { Conection => 'dbi:mysql:rakuwa', Username  => 'Rakuwa', Password  => 'MyPassword', Charset   => 'utf8', Timezone  => '-07:00', Database  => 'rakuwa' },
        Cookie => { Name      => 'Rakuwa', 'Max-Age' => '31536000', Domain => 'rakuwa.com', SameSite  => 'Strict', Path => '/'},
        Template => { TemplateID => 'Rakuwa', UserTemplateID => 'RakuwaUser', AdminTemplateID => 'RakuwaAdmin' },
        Security => { Key => 'RandomSecurityString' },
        Email => { Server   => 'localhost', Port => '587', Auth => 'LOGIN', User => 'hola@rakuwa.com', Password => 'MyPassword', From => 'hello@rakuwa.com', SSL => 'starttls' },
        Debug => True,
    };
}