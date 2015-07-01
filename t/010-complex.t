#!perl

use strict;
use warnings;

use Test::More;

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
        does    => [ [ ValidatedRequest => undef ] ],
        expects => {
            before => [],
            after  => [ [ AddFieldToRequest => '__ID__' ] ],
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
        does    => [ [ AddFieldToRequest => '__ID__' ] ],
        expects => {
            before => [ [ ValidatedRequest => undef ] ],
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
                [ ValidatedRequest  => undef ],
                [ AddFieldToRequest => '__ID__' ],
            ],
            after  => [],
        }
    );    

    sub call { +{ test => 'WOOT!' } }
}


my $app = application {

    enable 'MyApp::ValidateRequest';
    enable 'MyApp::AddIDToRequest';

    MyApp->new;

}->to_app;

subtest '... test it' => sub {
    my $resp = $app->( +{ hello => 'world' } );

    use Data::Dumper;
    warn Dumper $resp;
};

done_testing;

1;