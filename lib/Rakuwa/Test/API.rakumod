use Rakuwa::API;

class Rakuwa::Test::API does Rakuwa::API {

    method do_home () returns Hash {
        %.json{'ENV'} = {};
        %.json{'PARAMS'} = {};
        for $.rakuwa.request.env.kv  -> $key, $val {
            %.json{'ENV'}{$key} = $val;
        }

        for $.rakuwa.params.kv -> $key, $val {
            %.json{'PARAMS'}{$key} = $val;
        }

        my $date = '';
        if $.rakuwa.db.defined {
            $.json{'date'} = $.rakuwa.db.query('SELECT NOW()').arrays[0];
        }
        %.json{"status"} = $.SUCCESS;
        %.json{"msg"}    = "Basic example and ENV vars.";

        return %.json;
    }

    method do_success () returns Hash {
        %.json{"status"} = $.SUCCESS;
        %.json{"msg"} = "Success example.";
        %.json{"random_number"} = (1^..5).rand;
        return %.json;
    }

    method do_error () returns Hash {
        %.json{"status"} = $.ERROR;
        %.json{"msg"} = "Error example.";
        %.json{"random_number"} = (1^..5).rand;
        return %.json;
    }

}
