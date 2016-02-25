#!/usr/bin/env perl

use strict;
use feature 'say';

my @n = qw( 29653 14442 6550 2855 4513 11236 17796 18176 12643 6888 2670 
        726 136 39 12 10 8 6 4);
say "n = ", join ", ", @n;
my @diffs = diff(@n);
say "diff = ", join ", ", @diffs;
my @signs = map { $_ > 0 ? 1 : -1 } @diffs;
say "signs = ", join ", ", @signs;

sub diff {
    my @n = @_;
    my $left = shift @n or return;
    my @diffs;
    for my $n (@n) {
        push @diffs, $n - $left;
        $left = $n
    }
    @diffs;
}

sub sign {
    my @n = @_;
    my @signs;
    for my $n (@n) {
        
    }
}
