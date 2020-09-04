use Rakuwa::Conf;
use Rakuwa::Session::Store;

class Rakuwa::Session::StoreFile does Rakuwa::Session::Store does Rakuwa::Conf {
    method get($cookie_id) {
      my $file = $.conf{'Session'}{'StoreFileDir'} ~ '/' ~ $cookie_id ~ '.json';
      if $file.IO.e {
        my $fh = open $file, :r;
        my $contents = $fh.slurp;
        $fh.close;
        return $contents;
      }
      return '{}';
    }

    method set($cookie_id, $session) {
      my $file = $.conf{'Session'}{'StoreFileDir'} ~ '/' ~ $cookie_id ~ '.json';
      my $fh = open $file, :w;
      $fh.say($session);
      $fh.close;
    }

    method remove($cookie_id) {
      my $file = $.conf{'Session'}{'StoreFileDir'} ~ '/' ~ $cookie_id ~ '.json';
      unlink $file;
    }
}
