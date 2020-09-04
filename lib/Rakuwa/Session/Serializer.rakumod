
role Rakuwa::Session::Serializer {
    method serialize($cookie-name) returns Str { ... }
    method deserialize($cookie-name, $session) returns Hash { ... }
}
