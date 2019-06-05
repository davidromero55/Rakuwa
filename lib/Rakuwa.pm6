use Crust::Request;

class Rakuwa does Callable
{
    has $.status  is rw;
    has @.headers is rw;
    has @.body    is rw;
    has Crust::Request $.request is rw;

    method CALL-ME(%env) {
        self.call(%env);
    }

    method call(%env) {
        $.request = Crust::Request.new(%env);

        

        $.status  = 200;
        @.headers = [ 'Content-Type' => 'text/html' ];
        @.body    = [ '<html><head><title>Hi</title></head>',
                      '<body>',
                      'I just want you to see me ..',
                      $.request.user-agent(),
                      '..</body>',
                      '</html>',
                    ];

        return $.status, @.headers, @.body;
    }
}
