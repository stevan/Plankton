package Plankton::Middleware::Conditional;
use strict;
use warnings;

use Plankton::Middleware;

our @ISA; BEGIN { @ISA = ('Plankton::Middleware') }
our %HAS; BEGIN { %HAS = (
        %Plankton::Middleware::HAS,        
        conditional => sub { die 'The `conditional` key is required' },
        middleware  => sub { die 'The `middleware` key is required'  },
    );
}

sub call {
    my ($self, $req) = @_;

    # if we meet this condition, diverge ...
    if ( $self->{conditional}->( $req ) ) {
        return $self->{middleware}->call( $req );
    }

    # go about our normal lives ...
    return $self->{app}->call( $req );
}

1;

__END__