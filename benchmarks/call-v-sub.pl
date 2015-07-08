#!perl

use strict;
use warnings;

use Benchmark qw[ cmpthese ];

use Plankton::Middleware;
use Plankton::Component;
use Plankton::Builder::DSL;

use Plack::Builder;
use Plack::Component;
use Plack::Middleware;

BEGIN {

    package MyPlanktonApp::Middleware {
        use strict;
        use warnings;

        our @ISA; BEGIN { @ISA = ('Plankton::Middleware')   }
        our %HAS; BEGIN { %HAS = %Plankton::Middleware::HAS }

        sub call {
            my ($self, $req) = @_;
            return $self->{app}->call( $req );
        }
    }

    package MyPlanktonApp {
        use strict;
        use warnings;

        our @ISA; BEGIN { @ISA = ('Plankton::Component')   }
        our %HAS; BEGIN { %HAS = %Plankton::Component::HAS }

        sub call { [200, [], []] }
    }

    package MyPlackApp::Middleware {
        use strict;
        use warnings;

        our @ISA; BEGIN { @ISA = ('Plack::Middleware') }

        sub call {
            my ($self, $req) = @_;
            return $self->{app}->( $req );
        }
    }

    package MyPlackApp {
        use strict;
        use warnings;

        our @ISA; BEGIN { @ISA = ('Plack::Component') }

        sub call { [200, [], []] }
    }
}

my ($middleware_depth, $iterations) = @ARGV;

$middleware_depth ||= 1;
$iterations       ||= 100;

my $plankton_app = application {
    wrap 'MyPlanktonApp::Middleware'
        for 0 .. $middleware_depth;
    MyPlanktonApp->new;
};

my $plack_app = builder {
    enable sub { MyPlackApp::Middleware->wrap( $_[0] ) }
        for 0 .. $middleware_depth;
    MyPlackApp->new;
};

cmpthese($iterations, {
    'plankton' => sub { my $resp = $plankton_app->call({}) },
    'plack'    => sub { my $resp = $plack_app->({}) },
});

