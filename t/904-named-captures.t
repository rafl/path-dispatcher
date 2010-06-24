#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 9;
use Test::Exception;
use Path::Dispatcher;

my @vars;

"abc" =~ /(?<head>.)(.)(?<tail>.)/;
is_deeply([$1, $2, $3, $4, \%+], ["a", "b", "c", undef, {head=>'a',tail=>'c'}]);

my $dispatcher = Path::Dispatcher->new(
    rules => [
        Path::Dispatcher::Rule::Tokens->new(
            tokens => [qr/(?<style>bus)/, qr/(?<auto>train)/],
            block  => sub { push @vars, [$1, $2, $3, \%+] },
        ),
    ],
);

is_deeply([splice @vars], []);
is_deeply([$1, $2, $3, $4], ["a", "b", "c", undef]);
is_deeply([$1, $2, $3, $4, \%+], ["a", "b", "c", undef, {head=>'a',tail=>'c'}]);

my $dispatch = $dispatcher->dispatch("bus train");

is_deeply([splice @vars], []);
is_deeply([$1, $2, $3, $4], ["a", "b", "c", undef]);
is_deeply([$1, $2, $3, $4, \%+], ["a", "b", "c", undef, {head=>'a',tail=>'c'}]);

$dispatch->run;

is_deeply([splice @vars], [['bus', 'train', undef, {auto=>'train',style=>'bus'}]]);

TODO: {
    local $TODO = "we stomp on capture vars..";
    is_deeply([$1, $2, $3, $4, \%+], ["a", "b", "c", undef, {head=>'a',tail=>'c'}]);
};

