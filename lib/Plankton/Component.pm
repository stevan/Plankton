package Plankton::Component;
use strict;
use warnings;

use Plankton::Base;

our @ISA = ('Plankton::Base');
our %HAS = (
    %Plankton::Base::HAS,        
    application => sub { die 'The `application` key is required' },
);

sub call {
    my ($self, $req) = @_;
    return ref $self->{application} eq 'CODE'
        ? $self->{application}->( $req )
        : $self->{application}->call( $req );
}

1;

__END__
