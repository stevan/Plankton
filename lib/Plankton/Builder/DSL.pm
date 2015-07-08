package Plankton::Builder::DSL;
use strict;
use warnings;

use Plankton::Builder;

our @EXPORTS = qw[
    wrap
    wrap_if
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

our $WRAP = our $WRAP_IF = sub { die 'Can only call `wrap` and `wrap_if` from within `application`'};

sub wrap    ($@)  { $WRAP->( @_ ) }
sub wrap_if (&$@) { $WRAP_IF->( @_ ) }

sub application (&) {
    my $block = shift;

    my $builder = $BUILDER_CLASS->new;

    no warnings 'redefine';
    local $WRAP    = sub { $builder->add_middleware( @_ ) };
    local $WRAP_IF = sub { $builder->add_middleware_if( @_ ) };

    my $app = $block->();
     
    return $builder->assemble( $app );
}

1;

__END__