#!perl6

use v6;
use lib 'lib';
use Test;

use XBase;

my $obj;

lives-ok { $obj = XBase.new(filename => "t/data/biblio.dbf")  }, "constructor";
isa-ok( $obj, XBase, "and it is the right kind of object");

my $lu;

lives-ok { $lu = $obj.last-update }, "get last-update";
isa-ok($lu, Date, "and it is a Version");
diag "database last-updated $lu";

done;
# vim: expandtab shiftwidth=4 ft=perl6
