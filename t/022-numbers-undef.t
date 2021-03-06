#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 2;
use Path::Dispatcher;

my @recaptures;
my $rule = Path::Dispatcher::Rule::Regex->new(
    regex => qr/^(foo)(bar)?(baz)$/,
    block => sub {
        push @recaptures, $1, $2, $3;
    },
);

my $match = $rule->match(Path::Dispatcher::Path->new("foobaz"));
is_deeply($match->result, ['foo', undef, 'baz']);

$match->run;
is_deeply(\@recaptures, ['foo', undef, 'baz']);

