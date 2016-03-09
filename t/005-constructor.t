#!perl6

use v6;
use Test;

use XBase;

my $obj;

lives-ok { $obj = XBase.new(filename => "t/data/biblio.dbf")  }, "constructor";
isa-ok( $obj, XBase, "and it is the right kind of object");

my $lu;

lives-ok { $lu = $obj.last-update }, "get last-update";
isa-ok($lu, Date, "and it is a Version");
is($obj.records, 92, "got the right number of records");
diag "$obj";

is( $obj.header.fields.elems, 31, "and got the number of fields we expected");

for $obj.fields -> $field {
    ok($field.name !~~ /\0$/, "field name { $field.name } doesn't have nulls");
    ok($field.type ~~ XBase::DataType, "and field type is the write type of thing");
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
