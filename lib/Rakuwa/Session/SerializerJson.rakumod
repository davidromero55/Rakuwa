use Rakuwa::Session::Serializer;
use JSON::Tiny;


class Rakuwa::Session::SerializerJson does Rakuwa::Session::Serializer {
  method serialize($data) returns Str {
    return to-json $data;
  }

  method deserialize(Str $json_str) returns Hash {
    if ($json_str.codes <= 0) {
      $json_str = '{}';
    }
    return from-json($json_str);
  }
}
