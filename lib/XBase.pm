use v6;

class XBase {


    class Field {

    }
    class Header {
        has Field @.fields;

        has Date $.last-update;
        has Int $.records;
        has Int $!head-length;

        multi submethod BUILD(IO::Handle :$handle!) {
            my Buf $first-chunk = $handle.read(10);
            ( my Int $ver, my Int $yy, my Int $mm, my Int $dd, $!records, $!head-length ) = $first-chunk.unpack("CCCCLS");

            $!last-update = Date.new($yy + 1900, $mm, $dd);
        }

    }

    has $!filename;
    has IO::Handle $!handle;
    has Str  $.tablename;

    has Header $.header handles <last-update records>;

    multi submethod BUILD(:$!filename!) {

        if $!filename.IO.r {
            $!handle = $!filename.IO.open(:bin);
            $!header = Header.new(handle => $!handle);
        }
        else {
            die "Can't open { $!filename }";
        }
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
