package MyApp::ShardById {
    use strict;
    use warnings;

    use Plankton::Middleware;

    our @ISA; BEGIN { @ISA = ('Plankton::Middleware')   }
    our %HAS; BEGIN { %HAS = %Plankton::Middleware::HAS }

    our %CONTRACT = (
        does    => [ [ 'ShardedById' ], [ 'Retryable' ] ],
        expects => {
            before => [
                [ 'GeneratedId' ],
                [ 'ResolveCollision' ],
            ],
            after  => [],
        }
    );

    # dummy it up for now ...
    sub call {
        my ($self, $req) = @_;
        return $self->next::method( $req );
    }
}

1;

__END__