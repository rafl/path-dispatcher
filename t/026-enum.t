#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 8;
use Path::Dispatcher;

my @calls;

my $dispatcher = Path::Dispatcher->new;
$dispatcher->add_rule(
    Path::Dispatcher::Rule::Enum->new(
        enum   => ['foo', 'bar'],
        block  => sub { push @calls, [$1, $2] },
    ),
);

$dispatcher->run('foo');
is_deeply([splice @calls], [ ['foo', undef] ], "correctly populated number vars from enum");

$dispatcher->run('bar');
is_deeply([splice @calls], [ ['bar', undef] ], "correctly populated number vars from enum");

$dispatcher->run('jhdsaskjh');
is_deeply([splice @calls], [ ], "no match");


$dispatcher = Path::Dispatcher->new;
$dispatcher->add_rule(
    Path::Dispatcher::Rule::Enum->new(
        enum   => ['foo', 'bar'],
        block  => sub { push @calls, [$1, $2] },
        case_sensitive => 0,
    ),
);

$dispatcher->run('foo');
is_deeply([splice @calls], [ ['foo', undef] ], "correctly populated number vars from enum");

$dispatcher->run('bar');
is_deeply([splice @calls], [ ['bar', undef] ], "correctly populated number vars from enum");

$dispatcher->run('jhdsaskjh');
is_deeply([splice @calls], [ ], "no match");

$dispatcher->run('FoO');
is_deeply([splice @calls], [ ['FoO', undef] ], "correctly populated number vars from enum");

$dispatcher->run('bAR');
is_deeply([splice @calls], [ ['bAR', undef] ], "correctly populated number vars from enum");

