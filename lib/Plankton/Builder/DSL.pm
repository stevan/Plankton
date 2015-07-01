package Plankton::Builder::DSL;
use strict;
use warnings;

use Plankton::Builder;

our @EXPORTS = qw[
    enable
    enable_if
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

our $ENABLE = our $ENABLE_IF = sub { die 'Can only call `enable` and `enable_if` within `application`'};

sub enable    { $ENABLE->( @_ )    }
sub enable_if { $ENABLE_IF->( @_ ) }

sub application (&) {
    my $block = shift;

    my $builder = $BUILDER_CLASS->new;

    no warnings 'redefine';
    local $ENABLE    = sub { $builder->add_middleware( @_ )    };
    local $ENABLE_IF = sub { $builder->add_middleware_if( @_ ) };

    my $app = $block->();

    $builder->validate( $app );
    return $builder->assemble( $app );
}

1;

__END__