#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Plankton::Component;
use Plankton::Builder::DSL;

package MyApp::ValidateRequest {
    use strict;
    use warnings;

    use Plankton::Middleware;

    our @ISA; BEGIN { @ISA = ('Plankton::Middleware')   }
    our %HAS; BEGIN { %HAS = (
            %Plankton::Middleware::HAS,
            error_handler => sub { return sub { die 'VALIDATING FAIL: ' . $_[2] } }
        )
    }

    our %CONTRACT = (
        does    => [ [ 'ValidatedRequest' ] ],
        expects => {
            before => [],
            after  => [ [ 'AddFieldToRequest', '__ID__' ] ],
        }
    );

    sub call {
        my ($self, $req) = @_;
        return $self->{error_handler}->( $self, $req, 'The __ID__ field is not allowed' ) 
            if exists $req->{'__ID__'};
        return $self->next::method( $req );
    }
}

package MyApp::AddIDToRequest {
    use strict;
    use warnings;

    use Plankton::Middleware;

    our @ISA; BEGIN { @ISA = ('Plankton::Middleware')   }
    our %HAS; BEGIN { %HAS = %Plankton::Middleware::HAS }

    our %CONTRACT = (
        does    => [ [ 'AddFieldToRequest', '__ID__' ] ],
        expects => {
            before => [ [ 'ValidatedRequest' ] ],
            after  => [],
        }
    );

    our $ID = 0;
    sub call {
        my ($self, $req) = @_;
        $req->{'__ID__'} = $ID++;
        return $self->next::method( $req );
    }
}

package MyApp {
    use strict;
    use warnings;

    use Plankton::Component;

    our @ISA; BEGIN { @ISA = ('Plankton::Component')   }
    our %HAS; BEGIN { %HAS = %Plankton::Component::HAS }

    our %CONTRACT = (
        does    => [],
        expects => {
            before => [ 
                [ 'ValidatedRequest' ],
                [ 'AddFieldToRequest', '__ID__' ],
            ],
            after  => [],
        }
    );    

    sub call { +{ test => 'WOOT!' } }
}


subtest '... test it' => sub {
    my $app; 
    is(exception {
        $app = application {
            enable 'MyApp::ValidateRequest';
            enable 'MyApp::AddIDToRequest';
            MyApp->new;
        }->to_app;
    }, undef, '... we did not die');

    is(exception {
        my $resp = $app->( +{ hello => 'world' } );
    }, undef, '... we did not die');
};

done_testing;

1;