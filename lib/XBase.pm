use v6;

class XBase {

    class Field {

    }

    class VersionInfo {
        has Int $.version;
        has Bool $.memo;
        has Int $.sql;
        has Bool $.dbt;

        multi submethod BUILD(Int :$ver!) {
            $!version = $ver +& 0b00000111;
            $!memo    = Bool($ver +& 0b00001000);
            $!sql     = $ver +& 0b01110000;
            $!dbt     = Bool($ver +& 0b10000000);
        }

        method Str() {
            self.gist();
        }

        method gist() {
            "Version {$!version} file { $!dbt ?? 'with' !! 'without' } DBT";
        }

    }

    class Header {
        has Field @.fields;

        has Date $.last-update;
        has Int $.records;
        has Int $!head-length;
        has VersionInfo $.version;

        multi submethod BUILD(IO::Handle :$handle!) {
            my Buf $first-chunk = $handle.read(10);
            ( my Int $ver, my Int $yy, my Int $mm, my Int $dd, $!records, $!head-length ) = $first-chunk.unpack("CCCCLS");

            $!last-update = Date.new($yy + 1900, $mm, $dd);
            $!version = VersionInfo.new(:$ver);
        }
        method Str() {
            self.gist;
        }
        method gist() {
            $!version ~ ", {$!records} records. Last updated {$!last-update}";
        }
    }

    has $!filename;
    has IO::Handle $!handle;
    has Str  $.tablename;

    has Header $.header handles <last-update records version>;

    multi submethod BUILD(:$!filename!) {

        if $!filename.IO.r {
            $!handle = $!filename.IO.open(:bin);
            $!header = Header.new(handle => $!handle);
        }
        else {
            die "Can't open { $!filename }";
        }
    }

    method Str() {
        $!header.gist();
    }

    method gist() {
        self.Str;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
