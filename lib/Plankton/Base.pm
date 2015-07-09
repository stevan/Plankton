package Plankton::Base;
use strict;
use warnings;
use mro;

our %HAS;

sub new {
    my ($class, %args) = @_;

    my $proto = \%args;        
    my $self  = {};    
    my %slots = do { no strict 'refs'; %{$class . '::HAS'} };

    $self->{ $_ } = exists $proto->{ $_ } 
        ? $proto->{ $_ } 
        : $slots{ $_ }->( $proto )
            foreach keys %slots;

    return bless $self => $class;
}

1;

__END__