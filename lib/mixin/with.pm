package mixin::with;

use strict;
no strict 'refs';
use vars qw($VERSION);
$VERSION = 0.02;

=head1 NAME

mixin::with - declaring a mix-in class

=head1 SYNOPSIS

    package Dog::Retriever;
    use mixin::with 'Dog';


=head1 DESCRIPTION

mixin::with is used to declare mix-in classes.

=head2 Creating a mixin class.

There are three critical differences between a normal subclass and one
intended to be mixin.

=over 4

=item 1. It can have no superclasses.

=item 2. It can have no private methods.  Instead, use private functions.

C<_private($self, @args)>  instead of  C<$self->_private(@args);>

=item 3. The mixin class is useless on it's own.

You can't just "use Dog::Retriever" alone and expect it to do
anything useful.  It must be mixed.

=back

Mixin classes useful for those that I<add new functionality> to an
existing class.  If you find yourself doing:

    package Foo::ExtraStuff;
    use base 'Foo';

    package Bar;
    use base qw(Foo Foo::ExtraStuff);

it's a good indication that Foo::ExtraStuff might do better as a mixin.

=head2 How?

Basic usage is simple:

    package Foo::Extra;
    use mixin::with 'Foo';

    sub new_thing {
        my($self) = shift;
        ...normal method...
    }

C<use mixin::with 'Foo'> is I<similar> to subclassing from 'Foo'.

All public methods of Foo::Extra will be mixed in.  mixin::with
considers all methods that don't start with an '_' as public.

=cut

my %Mixers = ();
my $Tmp_Counter = 0;
sub import {
    my($class, $mixed_with) = @_;
    my $mixin = caller;

    my $tmp_pkg = __PACKAGE__.'::tmp'.$Tmp_Counter++;
    $Mixers{$mixin} = { mixed_with => $mixed_with,
                        tmp_pkg    => $tmp_pkg,
                      };

    require base;

    eval sprintf q{
        package %s;
        base->import($mixed_with);
    }, $mixin;

    return 1;
}


sub __mixers {
    my($class, $mixin) = @_;

    return @{$Mixers{$mixin}}{'mixed_with', 'tmp_pkg'};
}


sub _carp {
    require Carp;
    Carp::carp(@_);
}


=head1 AUTHOR

Michael G Schwern <schwern@pobox.com>

=head1 SEE ALSO

L<mixin>, L<ruby> from which I stole this idea.

=cut

1;

