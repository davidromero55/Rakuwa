use Cro::HTTP::Session::Persistent;
use DB::SQLite;
use JSON::Class;

# A Cro HTTP session storage using SQLite. Expects to be parmeterized
# with the session type.
role Rakuwa::Session::SQLite[::Session] does Cro::HTTP::Session::Persistent[Session] {
    # The database connection.
    has DB::SQLite $.db is required;
    has Str $.sessions-table = 'sessions';
    has Str $.id-column = 'session_id';
    has Str $.data-column = 'data';
    has Str $.timestamp-column = 'timestamp';

    # Creates a new session by making a database table entry.
    method create(Str $session-id) {
        my $inserted = $!db.query(
            "INSERT INTO {$!sessions-table} ({$!id-column}, {$!data-column}, {$!timestamp-column}) VALUES (?, ?, CURRENT_TIMESTAMP)", 
            $session-id, '{}') || 0;
        if $inserted == 0 {
            # TODO: create a most robust mechanism for handling duplicate session IDs.
            $!db.query("DELETE FROM sessions WHERE id = ?", $session-id);
            die "Failed to create session with ID $session-id";
        }
    }

    # Loads a session from the database.
    method load(Str $session-id) {
        my $raw-data = $!db.query("SELECT {$!data-column} FROM {$!sessions-table} WHERE {$!id-column} = ?", $session-id).value;
        my $data = $raw-data ~~ Buf ?? $raw-data.decode('utf8') !! $raw-data;
        self.deserialize($data)
    }

    # Saves a session to the database.
    method save(Str $session-id, Session $session --> Nil) {
        my Str $json = self.serialize($session);
        $!db.query("UPDATE {$!sessions-table} SET {$!data-column} = ? WHERE {$!id-column} = ?", $json, $session-id);
    }

    # Clears expired sessions from the database.
    method clear(--> Nil) {
        $!db.query("DELETE FROM {$!sessions-table} WHERE {$!timestamp-column} < datetime('now', '-{self.expiration} seconds')");
    }

    # Serialize a session for storage using JSON::Class.
    method serialize(Session $s) {
        $s.to-json;
    }

    # Deserialize a session from storage using JSON::Class.
    method deserialize($d) {
        Session.from-json($d)
    }
}