package Plankton::Base;
use strict;
use warnings;

our %HAS;

sub new {
    my ($class, %args) = @_;
    my $self  = \%args;
    my %proto = do { no strict 'refs'; %{$class . '::HAS'} };
    foreach my $k ( keys %proto ) {
        $self->{ $k } = $proto{ $k }->( $self ) 
            unless exists $args{ $k };
    }
    return bless $self => $class;
}

1;

__END__