package Plankton::Component;
use strict;
use warnings;

use Plankton::Base;

our @ISA = ('Plankton::Base');
our %HAS = %Plankton::Base::HAS;

sub call;

sub prepare_app { return }

sub to_app {
    my ($self) = @_;
    $self->prepare_app;
    return sub { $self->call( @_ ) };
}

1;

__END__
