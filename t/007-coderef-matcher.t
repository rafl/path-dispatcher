#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 3;
use Path::Dispatcher;

my (@matches, @calls);

my $dispatcher = Path::Dispatcher->new;
$dispatcher->add_rule(
    Path::Dispatcher::Rule::CodeRef->new(
        matcher => sub { push @matches, $_; { positional_captures => [length > 5] } },
        block   => sub { push @calls, [@_] },
    ),
);

$dispatcher->run('foobar');

is_deeply([splice @matches], ['foobar']);
is_deeply([splice @calls], [ [] ]);

$dispatcher->run('other');
is($matches[0]->path, 'other');

