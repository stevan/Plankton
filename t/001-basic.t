#!perl

use strict;
use warnings;

use Test::More;

package Base {
    use strict;
    use warnings;

    our %HAS;

    sub new {
        my ($class, %args) = @_;

        my %self = %args;
        my %proto = do { no strict 'refs'; %{$class . '::HAS'} };
        foreach my $k ( keys %proto ) {
            $self{ $k } = $proto{ $k }->() 
                unless exists $args{ $k };
        }

        bless \%self => $class;
    }
}

package Component {
    use strict;
    use warnings;

    our @ISA = ('Base');
    our %HAS = (
        application => sub { die 'The `application` key is required' },
        %Base::HAS,
    );

    sub call {
        my ($self, $req) = @_;
        return ref $self->{application} eq 'CODE'
            ? $self->{application}->( $req )
            : $self->{application}->call( $req );
    }
}

package Middleware {
    use strict;
    use warnings;

    our @ISA = ('Component');
    our %HAS = %Component::HAS;

}

package Middleware::Conditional {
    use strict;
    use warnings;

    our @ISA = ('Middleware');
    our %HAS = (
        conditional => sub { die 'The `conditional` key is required' },
        middleware  => sub { die 'The `middleware` key is required'  },
        %Middleware::HAS
    );

    sub call {
        my ($self, $req) = @_;
        if ( $self->{conditional}->( $req ) ) {
            return $self->{middleware}->call( $req );
        } else {
            return $self->SUPER::call( $req );            
        }
    }
}

package Builder {
    use strict;
    use warnings;

    our @ISA = ('Base');
    our %HAS = (
        middlewares => sub { [] },
        %Base::HAS,
    );

    sub add_middleware {
        my ($self, $mw, @args) = @_;
        push @{ $self->{middlewares} } => [ $mw, \@args ];
    }

    sub add_middleware_if {
        my ($self, $cond, $mw, @args) = @_;
        push @{ $self->{middlewares} } => [ $cond, $mw, \@args ];
    }

    sub wrap {
        my($self, $app) = @_;

        for my $spec ( reverse @{ $self->{middlewares} } ) {
            if ( scalar @$spec == 2 ) {
                my ($mw, $args) = @$spec;
                $app = $mw->new( application => $app, @$args );
            }
            elsif ( scalar @$spec == 3 ) {
                my ($cond, $mw, $args) = @$spec;  
                $app = Middleware::Conditional->new( 
                    application => $app, 
                    conditional => $cond, 
                    middleware  => $mw->new( application => $app, @$args ) 
                );
            }
            else {
                die "WTF, this is not what I meant to do!";
            }
        }

        return $app;
    }
}

# DSL

sub enable    {}
sub enable_if {}

sub application (&) {
    my $block = shift;

    my $builder = Builder->new;

    no warnings 'redefine';
    local *enable    = sub { $builder->add_middleware( @_ )    };
    local *enable_if = sub { $builder->add_middleware_if( @_ ) };

    my $app = $block->();

    return $builder->wrap( $app );
}

# --------------------------------------------------

package Middleware::AddShitToResponse {
    use strict;
    use warnings;

    our @ISA = ('Middleware');
    our %HAS = %Middleware::HAS;

    sub call {
        my ($self, $req) = @_;
        warn join ", " => $self, grep { $_ ne 'application' } keys %$self;
        my $resp = $self->SUPER::call( $req );
        $resp->{$_} = $self->{$_} foreach grep { $_ ne 'application' } keys %$self;
        $resp;
    }
}

my $app = application {

    enable 'Middleware::AddShitToResponse' => (bar => 10);
    enable 'Middleware::AddShitToResponse' => (
        baz   => 20,
        gorch => 30
    );

    enable_if sub { $_[0]->{hello} }, 
        'Middleware::AddShitToResponse' => (goodbye => 'cruel world');        

    Component->new( application => sub { +{ test => 'WOOT!' } } );
};


use Data::Dumper;
warn Dumper $app->call( +{ hello => 1 } );

done_testing;

1;