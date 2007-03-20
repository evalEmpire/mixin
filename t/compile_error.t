#!/usr/bin/perl -w

use lib 't/lib';
use Test::More tests => 2;

{
    package Dog;
    sub new { bless {}, shift }
}

eval q{
    package Dog::Small;
    use base qw(Dog);
    use mixin qw(Dog::CompileError);
};
isnt($@, "");

eval q{
    package Dog::Small;
    use base qw(Dog);
    use mixin qw(Does::Not::Exist);
};
isnt($@, "");
