#!/usr/bin/perl -w

use Test::More tests => 1;

my $Error;
{
    package My::Errors;
    use mixin::with 'UNIVERSAL';

    sub error { $Error = $_[1]; }
}

{
    package My::Stuff;
    use mixin 'My::Errors';

    sub new { bless {}, __PACKAGE__ }
}

my $stuff = My::Stuff->new;
$stuff->error("foo");
is $Error, "foo";
