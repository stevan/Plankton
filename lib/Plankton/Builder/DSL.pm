package Plankton::Builder::DSL;
use strict;
use warnings;

use Plankton::Builder;

our @EXPORTS = qw[
    enable
    application
];

sub import {
    my $from = shift;
    my $to   = caller;

    no strict 'refs';
    foreach my $export ( @EXPORTS ) {
        *{ $to . '::' . $export } = \&{ $from . '::' . $export };
    }

}

our $BUILDER_CLASS = 'Plankton::Builder';

our $ENABLE = sub { die 'Can only call `enable` within `application`'};

sub enable { $ENABLE->( @_ ) }

sub application (&) {
    my $block = shift;

    my $builder = $BUILDER_CLASS->new;

    no warnings 'redefine';
    local $ENABLE    = sub { $builder->add_middleware( @_ ) };

    my $app = $block->();

    $builder->validate( $app );
    return $builder->assemble( $app );
}

1;

__END__