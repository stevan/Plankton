package MyApp::CheckRole {
    use strict;
    use warnings;

    use Plankton::Middleware;

    our @ISA; BEGIN { @ISA = ('Plankton::Middleware') }
    our %HAS; BEGIN { %HAS = (
            %Plankton::Middleware::HAS,
            allowed_roles => sub { [] }
        )
    }

    our %CONTRACT = (
        does    => [ [ 'CheckRoles' ] ],
        expects => {
            before => [],
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