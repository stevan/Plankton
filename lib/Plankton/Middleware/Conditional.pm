package Plankton::Middleware::Conditional;
use strict;
use warnings;
use mro;

use Plankton::Middleware;

our @ISA = ('Plankton::Middleware');
our %HAS = (
    %Plankton::Middleware::HAS,        
    conditional => sub { die 'The `conditional` key is required' },
    middleware  => sub { die 'The `middleware` key is required'  },
);

sub call {
    my ($self, $req) = @_;
    if ( $self->{conditional}->( $req ) ) {
        return $self->{middleware}->call( $req );
    } else {
        return $self->next::method( $req );            
    }
}

1;

__END__
