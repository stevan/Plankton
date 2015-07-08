package Plankton::Middleware;
use strict;
use warnings;

use Plankton::Component;

our @ISA; BEGIN { @ISA = ('Plankton::Component') }
our %HAS; BEGIN { %HAS = (
        %Plankton::Component::HAS,        
        app => sub { die 'The `app` key is required' },
    );
}

1;

__END__