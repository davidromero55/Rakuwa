use Rakuwa::Session::Store;

class Rakuwa::Session::StoreMemory does Rakuwa::Session::Store {
    has %.data;
    method get($cookie-name) {
        return %.data{$cookie-name};
    }

    method set($cookie-name, $session) {
        %.data{$cookie-name} = $session;
    }

    method remove($cookie-name) {
        %.data{$cookie-name}:delete;
    }
}
