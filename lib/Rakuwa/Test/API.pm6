use Rakuwa::API;

class Rakuwa::Test::API does Rakuwa::API {

    method do_home () returns Hash {
        %.JSON{'ENV'} = {};
        %.JSON{'PARAMS'} = {};
        for $.rakuwa.request.env.kv  -> $key, $val {
            %.JSON{'ENV'}{$key} = $val;
        }

        for $.rakuwa.params.kv -> $key, $val {
            %.JSON{'PARAMS'}{$key} = $val;
        }

        my $date = '';
        if $.rakuwa.db.defined {
            $.JSON{'date'} = $.rakuwa.db.query('SELECT NOW()').arrays[0];
        }



        return %.JSON;
    }
}
