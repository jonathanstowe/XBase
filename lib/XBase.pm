
use v6;

use experimental :pack;

class XBase {
    enum DataType ( 'Character' => "C", 
                    'Number'    => "N", 
                    'Logical'   => "L", 
                    'DateStamp'      => "D", 
                    'Memo'      => "M", 
                    'Float'     => "F", 
                    'Binary'    => "B",
                    'General'   => "G",
                    'Picture'   => "P",
                    'Currency'  => "Y",
                    'DateTime'  => "T",
                    'Integer'   => "I",
                    'VariField' => "V",
                    'Variant'   => "X",
                    'Timestamp' => '@',
                    'Double'    => 'O',
                    'Autoinc'   => '+' );

    class FieldDescription {
        has Str $.name;
        has DataType $.type;
        has Int $!address;
        has Int $.length;
        has Int $.decimal;
        has Bool $.indexed;

        multi submethod BUILD(Buf :$descriptor!) {

            ($!name, my Str $type, $!address, $!length, $!decimal, my Int $wa, my Int $sf, my Int $idx ) = $descriptor.unpack("Z11ALCCx2Cx2Cx2C");
            $!name ~~ s/\x[0]+$//;
            $!indexed = Bool($idx);
            $!type = DataType($type);
        }

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
        has FieldDescription @.fields;

        has Dateish $.last-update;
        has Int $.records;
        has Int $!head-length;
        has VersionInfo $.version;
        has Int $!record-length;

        multi submethod BUILD(IO::Handle :$handle!) {
            my Buf $first-chunk = $handle.read(10);
            ( my Int $ver, my Int $yy, my Int $mm, my Int $dd, $!records, $!head-length ) = $first-chunk.unpack("CCCCLS");

            $!last-update = Date.new($yy + 1900, $mm, $dd);
            $!version = VersionInfo.new(:$ver);

            my Buf $second-chunk = $handle.read(22);
            ($!record-length, my Int $incomplete, my Int $encrypted, my Int $mdx, my Int $lang) = $second-chunk.unpack("Sx2CCx4x8CCx2");

            repeat {
                my Buf $descriptor = $handle.read(32);
                @!fields.push(FieldDescription.new(:$descriptor));
            } while $handle.tell() < $!head-length - 1;

            my $eoh = $handle.read(1);

            if $eoh[0] != 0x0D {
                die "Malformed header";
            }

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

    has Header $.header handles <last-update records version fields>;

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
