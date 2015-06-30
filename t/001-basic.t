#!perl

use strict;
use warnings;

use Test::More;

use Plankton::Component;
use Plankton::Builder::DSL;

package MyApp {
    use strict;
    use warnings;

    use Plankton::Component;

    our @ISA; BEGIN { @ISA = ('Plankton::Component')   }
    our %HAS; BEGIN { %HAS = %Plankton::Component::HAS }

    sub call { +{ test => 'WOOT!' } }
}

package MyApp::AddShitToResponse {
    use strict;
    use warnings;

    use Plankton::Middleware;

    our @ISA; BEGIN { @ISA = ('Plankton::Middleware')   }
    our %HAS; BEGIN { %HAS = %Plankton::Middleware::HAS }

    sub call {
        my ($self, $req) = @_;
        #warn join ", " => $self, grep { $_ ne 'application' } keys %$self;
        my $resp = $self->next::method( $req );
        $resp->{$_} = $self->{$_} foreach grep { $_ ne 'application' } keys %$self;
        $resp;
    }
}

my $app = application {

    enable 'MyApp::AddShitToResponse' => (bar => 10);
    enable 'MyApp::AddShitToResponse' => (
        baz   => 20,
        gorch => 30
    );

    enable_if sub { $_[0]->{hello} }, 
        'MyApp::AddShitToResponse' => (goodbye => 'cruel world');        

    MyApp->new;
};

subtest 'test it w/out conditional' => sub {
    my $resp = $app->call( +{ hello => 0 } );

    is($resp->{test},  'WOOT!', '... got the right value for `test`');
    is($resp->{bar},   10,      '... got the right value for `bar`');
    is($resp->{baz},   20,      '... got the right value for `baz`');
    is($resp->{gorch}, 30,      '... got the right value for `gorch`');
    ok(not(exists $resp->{goodbye}), '... our conditional did not fire');
};


subtest 'test it w/ conditional' => sub {
    my $resp = $app->call( +{ hello => 1 } );

    is($resp->{test},  'WOOT!', '... got the right value for `test`');
    is($resp->{bar},   10,      '... got the right value for `bar`');
    is($resp->{baz},   20,      '... got the right value for `baz`');
    is($resp->{gorch}, 30,      '... got the right value for `gorch`');
    ok(exists $resp->{goodbye}, '... our conditional did fire');
    is($resp->{goodbye}, 'cruel world', '... got the right value for `goodbye`');
};

done_testing;

1;