package Plankton::Builder;
use strict;
use warnings;

use Plankton::Component;
use Plankton::Middleware;
use Plankton::Middleware::Conditional;

use Plankton::Base;

our @ISA; BEGIN { @ISA = ('Plankton::Base') }
our %HAS; BEGIN { %HAS = (
        %Plankton::Base::HAS,        
        middlewares => sub { [] },
    );
}

sub add_middleware {
    my ($self, $mw, @args) = @_;
    push @{ $self->{middlewares} } => [ $mw, \@args ];
}

sub add_middleware_if {
    my ($self, $cond, $mw, @args) = @_;
    push @{ $self->{middlewares} } => [ $cond, $mw, \@args ];
}

sub assemble {
    my ($self, $app) = @_;

    for my $spec ( reverse @{ $self->{middlewares} } ) {
        if ( scalar @$spec == 2 ) {
            my ($mw, $args) = @$spec;
            $app = $mw->new( app => $app, @$args );
            $app->prepare_app;
        }
        elsif ( scalar @$spec == 3 ) {
            my ($cond, $mw, $args) = @$spec;  
            $app = Plankton::Middleware::Conditional->new( 
                app         => $app, 
                conditional => $cond, 
                middleware  => $mw->new( app => $app, @$args ) 
            );
        }
        else {
            die "[PANIC] WTF, this is not what I meant to do!";
        }
    }

    return $app;
}

1;

__END__