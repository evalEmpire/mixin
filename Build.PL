#!/usr/bin/perl

use warnings;
use strict;

use Module::Build;

my $build = Module::Build->new(
    module_name         => "mixin",
    license             => "perl",

    recursive_test_files => 1,

    requires            => {
        "base"                  => 0,
    },
    build_requires      => {
        "Test::More"            => 0.40,
        "Test::NoWarnings"      => 0,
    },

    create_readme       => 1,
    create_license      => 1,

    meta_merge          => {
        resources       => {
            homepage    => "http://search.cpan.org/dist/mixin",
            bugtracker  => "https://rt.cpan.org/Public/Dist/Display.html?Name=mixin",
            repository  => "http://github.com/schwern/mixin",
        },
        keywords        => [qw(mixin inheritance devel)],
    }
);
$build->create_build_script;
