use Rakuwa::Conf;
use Rakuwa::Session::Store;
use Rakuwa::Session::Serializer;

use Cookie::Baker;
use UUID;

class Rakuwa::Session does Rakuwa::Conf {

  has %.data is rw;
  has Str $.cookie_id is rw;
  has Bool $.modified is rw; # True only if data has been modified
  has Bool $.expired is rw; # Mark session as expired
  has Bool $.is-new; # Mark session as being new
  has Bool $.change-id is rw; # Set this True if you want to keep the session, but want to change IDs
  has Bool $.no-store is rw; # Set this True if you don't want this to be stored
  has Rakuwa::Session::Store $.store is rw;
  has Rakuwa::Session::Serializer $.serializer is rw;

  method init(Str $cookie_header) {
    my %crushed = crush-cookie($cookie_header);
    $.cookie_id = %crushed{$.conf{'Session'}{'Name'}} || self.id_generator();

    say "test---";
    say $.cookie_id;

    my $store_module_name = 'Rakuwa::Session::Store' ~ $.conf{'Session'}{'Store'};
    require ::($store_module_name);
    $.store = ::($store_module_name).new();

    my $serializer_module_name = 'Rakuwa::Session::Serializer' ~ $.conf{'Session'}{'Serializer'};
    require ::($serializer_module_name);
    $.serializer = ::($serializer_module_name).new();

    my $session_data = $.store.get($.cookie_id);
    %.data = $.serializer.deserializer($session_data || '{}');
  }

  method finalize() {
      my $need-store = False;

      if (($.is-new && !$.has-keys) || $.modified || $.expired || $.change-id)
      {
          $need-store = True;
      }

      if $.no-store {
          $need-store = False;
      }

      my $set-cookie = False;
      if ($.is-new && $.keep-empty && !$.has-keys) || ($.is-new && $.modified) || $.expired || $.change-id
      {
          $set-cookie = True;
      }

      if $need-store {
          my $id = $.id;
          if $.expired {
              $.store.remove($id);
          } else {
              if $.change-id {
                  $.store.remove($id);
                  $id = self.id_generator();
                  $.id = $id;
              }

              my $val = $.serializer.serialize(%.data);
              $.store.set($id, $val);
          }
      }

      if $set-cookie {
          if $.expired {
              $.expires = 'now';
          }
      }
  }

  method id_generator() {
    my $uuid = UUID.new(:version(4));
    return $uuid.Str();
#    return sha256 (rand ~ $*PID ~ {} ~ now).encode: 'utf8-c8';
#    my $buf = sha1(rand ~ $*PID ~ {} ~ now);
#    return [~] $buf.list».fmt: "%02x";
  }

  method get($key) {
    return %.data{$key};
  }

  method set($key, $value) {
    $.modified = True;
    %.data{$key} = $value;
  }

  method remove($key) {
    $.modified = True;
    %.data{$key}:delete;
  }

  method clear() {
    $.modified = True;
    %.data = ();
  }

  method has-keys() returns Bool {
    return %.data():k.elems > 0;
  }

  method get_cookie() {
    my %options;

    if $.conf{'Session'}{'Domain'} {
        %options<domain> = $.conf{'Session'}{'Domain'};
    }

    %options<path> = $.conf{'Session'}{'Path'} || "/";

#    if ($.conf{'Session'}{'SameSite'}) {
#        %options<samesite> = $.conf{'Session'}{'SameSite'};
#    }

    if $.conf{'Session'}{'Expires'} {
        %options<expires> = $.conf{'Session'}{'Expires'};
    }

    if $.conf{'Session'}{'Secure'} {
        %options<secure> = $.conf{'Session'}{'Secure'};
    }

    if $.conf{'Session'}{'Max-Age'} {
        %options<max-age> = $.conf{'Session'}{'Max-Age'};
    }
    my $cookie = bake-cookie($.conf{'Session'}{'Name'}, $.cookie_id, |%options);
    return $cookie;
  }
}
