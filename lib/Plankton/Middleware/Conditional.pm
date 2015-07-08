package Plankton::Middleware::Conditional;
use strict;
use warnings;

use Plankton::Middleware;

our @ISA; BEGIN { @ISA = ('Plankton::Middleware') }
our %HAS; BEGIN { %HAS = (
        %Plankton::Middleware::HAS,        
        condition  => sub { die 'The `condition` key is required' },
        middleware => sub { die 'The `middleware` key is required'  },
    );
}

sub call {
    my ($self, $req) = @_;
    my $app = $self->{condition}->( $req ) ? $self->{middleware} : $self->{app};
    return $app->call( $req );
}

1;

__END__