use Rakuwa::Session::Serializer;
use JSON::Tiny;


class Rakuwa::Session::SerializerJson does Rakuwa::Session::Serializer {
  method serializer($data) returns Str {
    return to-json $data;
  }

  method deserializer(Str $json_str) returns Hash {
    if ($json_str.codes <= 0) {
      $json_str = '{}';
    }
    return from-json($json_str);
  }
}
