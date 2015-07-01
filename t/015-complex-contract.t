#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Plankton::Component;
use Plankton::Builder::DSL;

use lib 't/015-lib/';

use MyApp::CheckRole;
use MyApp::GenerateId;
use MyApp::ValidateRequestData;
use MyApp::ResolveCollision;
use MyApp::ShardById;

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
                ['ResolveCollision'],            
                ['ShardedById'],
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
            enable "MyApp::CheckRole",           allow        => [ qw/app/ ];
            enable "MyApp::ValidateRequestData", require_data => [];
            enable "MyApp::GenerateId",          method       => "content_crc64";
            enable "MyApp::ResolveCollision";
            enable "MyApp::ShardById",           method       => "jumphash_numeric", 
                                                 num_shards   => 4;
            MyApp->new;
        }->to_app;
    }, undef, '... we did not die');

    is(exception {
        my $resp = $app->( +{ hello => 'world' } );
    }, undef, '... we did not die');
};

done_testing;

1;