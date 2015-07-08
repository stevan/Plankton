package Plankton::Builder::DSL;
use strict;
use warnings;

use Plankton::Builder;

our @EXPORTS = qw[
    wrap
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

our $WRAP = sub { die 'Can only call `wrap` within `application`'};

sub wrap { $WRAP->( @_ ) }

sub application (&) {
    my $block = shift;

    my $builder = $BUILDER_CLASS->new;

    no warnings 'redefine';
    local $WRAP = sub { $builder->add_middleware( @_ ) };

    my $app = $block->();
     
    return $builder->assemble( $app );
}

1;

__END__