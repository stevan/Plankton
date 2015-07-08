package Plankton::Builder;
use strict;
use warnings;

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




sub assemble {
    my ($self, $app) = @_;

    for my $spec ( reverse @{ $self->{middlewares} } ) {
        if ( scalar @$spec == 2 ) {
            my ($mw, $args) = @$spec;
            $app = $mw->new( app => $app, @$args );
            $app->prepare_app;
        }
        else {
            die "[PANIC] WTF, this is not what I meant to do!";
        }
    }

    return $app;
}

1;

__END__