package mixin;

use strict;
no strict 'refs';
use vars qw($VERSION);
$VERSION = '0.02';


=head1 NAME

mixin - Mix-in inheritance, an alternative to multiple inheritance

=head1 SYNOPSIS

  package Dog;
  sub speak { print "Bark!\n" }
  sub new { my $class = shift;  bless {}, $class }

  package Dog::Small;
  use base 'Dog';
  sub speak { print "Yip!\n"; }

  package Dog::Retriever;
  use mixin::with 'Dog';
  sub fetch { print "Get your own stinking $_[1]\n" }

  package Dog::Small::Retriever;
  use base 'Dog::Small';
  use mixin qw(Dog::Small Dog::Retriever);

  my $small_retriever = Dog::Small::Retriever->new;
  $small_retriever->speak;          # Yip!
  $small_retriever->fetch('ball');  # Get your own stinking ball

=head1 DESCRIPTION

Mixin inheritance is an alternative to the usual multiple-inheritance
and solves the problem of knowing which parent will be called.
It also solves a number of tricky problems like diamond inheritence.

The idea is to solve the same sets of problems which MI solves without
the problems of MI.

=head2 Using a mixin class.

There are two steps to using a mixin-class.

First, make sure you are inherited from the class with which the
mixin-class is to be mixed.

  package Dog::Small::Retriever;
  use base 'Dog::Small';

Since Dog::Small isa Dog, that does it.  Then simply mixin the new
functionality

  use mixin 'Dog::Retriever';

and now you can use fetch().


=cut

sub import {
    my($class, @mixins) = @_;
    my $caller = caller;

    foreach my $mixin (@mixins) {
        _mixup($mixin, $caller);
    }
}

sub _mixup {
    my($mixin, $caller) = @_;

    require mixin::with;
    my($with, $pkg) = mixin::with->__mixers($mixin);

    _croak("$mixin is not a mixin") unless $with;
    _croak("$caller must be a subclass of $with")
      unless $caller->isa($with);
    _croak("$mixin should not have any superclasses") if
      grep $_ ne $with, @{$mixin.'::ISA'};


    # This has to happen here and not in mixin::with because "use
    # mixin::with" typically runs *before* the rest of the mixin's
    # subroutines are declared.
    _thieve_public_methods( $mixin, $pkg );

    push @{$caller.'::ISA'}, $pkg;
}


my %Thieved = ();
sub _thieve_public_methods {
    my($mixin, $pkg) = @_;

    return if $Thieved{$mixin}++;

    local *glob;
    while( my($sym, $glob) = each %{$mixin.'::'}) {
        next if $sym =~ /^_/;
        next unless defined $glob;
        *glob = *$glob;
        *{$pkg.'::'.$sym} = *glob{CODE} if *glob{CODE};
    }
}


sub _croak {
    require Carp;
    Carp::croak(@_);
}

sub _carp {
    require Carp;
    Carp::carp(@_);
}


=head1 AUTHOR

Michael G Schwern E<lt>schwern@pobox.comE<gt>

=cut

1;
