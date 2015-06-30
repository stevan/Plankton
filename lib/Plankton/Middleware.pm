package Plankton::Middleware;
use strict;
use warnings;

use Plankton::Component;

our @ISA = ('Plankton::Component');
our %HAS = (
    %Plankton::Component::HAS,        
    app => sub { die 'The `app` key is required' },
);

sub call {
    my ($self, $req) = @_;
    return $self->{app}->call( $req );
}

1;

__END__