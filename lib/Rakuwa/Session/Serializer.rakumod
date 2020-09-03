
role Rakuwa::Session::Serializer {
    method serializer($cookie-name) returns Str { ... }
    method deserializer($cookie-name, $session) returns Hash { ... }
}
