package Plankton::Builder;
use strict;
use warnings;

use Plankton::Base;

use Plankton::Middleware::Conditional;

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

sub validate {
    my ($self, $app) = @_;

    use Data::Dumper;

    my @all = (@{ $self->{middlewares} }, [ ref $app, $app ]);

    warn join '' => ('-' x 80), "\n";
    warn "... Going through all the components and middleware ...\n";

    for ( my $i = 0; $i < scalar @all; $i++ ) {
        my $spec = $all[ $i ];
        #warn Dumper $spec;

        my $mw = (scalar @$spec == 2 ? $spec->[0] : (scalar @$spec == 3 ? $spec->[1] : die "WTF!"));

        warn join '' => ('-' x 80), "\n";
        warn "... CHECKING: $mw\n";

        if ( my $contract = do { no strict 'refs'; \%{$mw . '::CONTRACT'} } ) {
            warn "...>>> Found contract for: $mw\n";
            #warn Dumper $contract;
            if ( my $expects = $contract->{expects} ) {
                warn "......>>> Found expects\n";
                if ( my @before = @{ $expects->{before} } ) {
                    warn ".........>>> Found expects->before\n";
                    foreach my $before ( @before ) {
                        warn "............ got before: " . $before->[0] . "\n";
                        my $has_been_fullfilled = 0;
                        for ( my $j = $i-1; $j >= 0; $j-- ) {
                            my $candidate    = $all[ $j ];
                            my $candidate_mw = (scalar @$candidate == 2 ? $candidate->[0] : (scalar @$candidate == 3 ? $candidate->[1] : die "WTF!"));
                            warn "................ Checking against items before it $candidate_mw (i($i) j($j))\n";
                            my $does         = do { no strict 'refs'; ${$candidate_mw . '::CONTRACT'}{does} };
                            foreach my $thing ( @$does ) {
                                #warn "COMPARING: " . (Dumper { "${mw}::expects::before" => $before, "${candidate_mw}::does" => $thing }) . "\n";
                                $has_been_fullfilled = 1
                                    if ($thing->[0] // 'undef') eq ($before->[0] // 'undef') 
                                    && ($thing->[1] // 'undef') eq ($before->[1] // 'undef');
                            } 
                            last if $has_been_fullfilled;
                        }
                        if ($has_been_fullfilled) {
                            warn "!!!!!!.......... >>> HORRAY, (" . (join ", " => map { $_ // 'undef' } @$before)  . ") has been fullfilled for $mw\n";
                        }
                        else {
                            die "[PANIC] WTF, the before contract (" . (join ", " => map { $_ // 'undef' } @$before)  . ") has not been fullfilled for $mw";
                        }
                    }
                }
                else {
                    warn ".........<<< No expects->before\n";
                }

                if ( my @after = @{ $expects->{after} } ) {
                    warn ".........>>> Found expects->after\n";
                    foreach my $after ( @after ) {
                        warn "............ got after: " . $after->[0] . "\n";
                        my $has_been_fullfilled = 0;
                        for ( my $j = $i; $j < scalar @all; $j++ ) {
                            my $candidate    = $all[ $j ];
                            my $candidate_mw = (scalar @$candidate == 2 ? $candidate->[0] : (scalar @$candidate == 3 ? $candidate->[1] : die "WTF!"));
                            warn "................ Checking against items after it $candidate_mw (i($i) j($j))\n";
                            my $does         = do { no strict 'refs'; ${$candidate_mw . '::CONTRACT'}{does} };
                            foreach my $thing ( @$does ) {
                                #warn "COMPARING: " . (Dumper { "${mw}::expects::before" => $after, "${candidate_mw}::does" => $thing }) . "\n";
                                $has_been_fullfilled = 1
                                    if ($thing->[0] // 'undef') eq ($after->[0] // 'undef') 
                                    && ($thing->[1] // 'undef') eq ($after->[1] // 'undef');
                            } 
                            last if $has_been_fullfilled;
                        }
                        if ($has_been_fullfilled) {
                            warn "!!!!!!.......... >>> HORRAY, (" . (join ", " => map { $_ // 'undef' } @$after)  . ") has been fullfilled for $mw\n";
                        }
                        else {
                            die "[PANIC] WTF, the after contract (" . (join ", " => map { $_ // 'undef' } @$after)  . ") has not been fullfilled for $mw";
                        }
                    }
                }
                else {
                    warn ".........<<< No expects->after\n";
                }
            }
        }
        else {
            warn "......<<< no expects\n";
        }
    }

    warn join '' => ('-' x 80), "\n";
}

sub assemble {
    my ($self, $app) = @_;

    for my $spec ( reverse @{ $self->{middlewares} } ) {
        if ( scalar @$spec == 2 ) {
            my ($mw, $args) = @$spec;
            $app = $mw->new( app => $app, @$args );
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