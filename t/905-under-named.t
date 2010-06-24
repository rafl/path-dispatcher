#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 2;
use Test::Exception;
use Path::Dispatcher;

my @pos;
my @named;

my $dispatcher = Path::Dispatcher->new(
    rules => [
        Path::Dispatcher::Rule::Under->new(
            predicate => Path::Dispatcher::Rule::Regex->new(
                regex  => qr/(?<type>\w+)/,
                prefix => 1,
            ),
            rules => [
                Path::Dispatcher::Rule::Tokens->new(
                    tokens => [qr/(?<operation>\w+)/, qr/(?<id>\d+)/],
                    block  => sub {
                        push @pos, [$1, $2, $3, $4];
                        push @named, \%+;
                    },
                ),
            ],
        ),
    ],
);

$dispatcher->run("ticket update 10");
is_deeply([splice @pos], [['ticket', 'update', 10, undef]]);
is_deeply([splice @named], [{
    type      => 'ticket',
    operation => 'update',
    id        => 10,
}]);

