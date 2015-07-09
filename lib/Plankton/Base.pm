package Plankton::Base;
use strict;
use warnings;
use mro;

our %HAS;

sub new {
    my ($class, %args) = @_;

    my $self  = \%args;
    my %slots = do { no strict 'refs'; %{$class . '::HAS'} };

    foreach my $k ( keys %slots ) {    
        $self->{ $k } = $slots{ $k }->( $self )
            unless exists $self->{ $k };
    }

    return bless $self => $class;
}

1;

__END__