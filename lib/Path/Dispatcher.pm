package Path::Dispatcher;
use Any::Moose;
use 5.010;

our $VERSION = '0.15';

use Path::Dispatcher::Rule;
use Path::Dispatcher::Dispatch;
use Path::Dispatcher::Path;

use constant dispatch_class => 'Path::Dispatcher::Dispatch';
use constant path_class     => 'Path::Dispatcher::Path';

with 'Path::Dispatcher::Role::Rules';

has name => (
    is      => 'rw',
    isa     => 'Str',
    default => do {
        my $i = 0;
        sub {
            my $self = shift;
            join '-', blessed($self), ++$i;
        },
    },
);

sub dispatch {
    my $self = shift;
    my $path = $self->_autobox_path(shift);

    my $dispatch = $self->dispatch_class->new;

    for my $rule ($self->rules) {
        $self->dispatch_rule(
            rule     => $rule,
            dispatch => $dispatch,
            path     => $path,
        );
    }

    return $dispatch;
}

sub dispatch_rule {
    my $self = shift;
    my %args = @_;

    my @matches = $args{rule}->match($args{path});

    $args{dispatch}->add_matches(@matches);

    return @matches;
}

sub run {
    my $self = shift;
    my $path = shift;

    my $dispatch = $self->dispatch($path);

    return $dispatch->run(@_);
}

sub complete {
    my $self = shift;
    my $path = $self->_autobox_path(shift);

    my %seen;
    return grep { !$seen{$_}++ } map { $_->complete($path) } $self->rules;
}

sub _autobox_path {
    my $self = shift;
    my $path = shift;

    unless (blessed($path) && $path->isa('Path::Dispatcher::Path')) {
        $path = $self->path_class->new(
            path => $path,
        );
    }

    return $path;
}

# We don't export anything, so if they request something, then try to error
# helpfully
sub import {
    my $self    = shift;
    my $package = caller;

    if (@_) {
        Carp::croak "'use Path::Dispatcher (@_)' called by $package. Did you mean to use Path::Dispatcher::Declarative?";
    }
}

__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;

__END__

=head1 NAME

Path::Dispatcher - flexible and extensible dispatch

=head1 SYNOPSIS

    use Path::Dispatcher;
    my $dispatcher = Path::Dispatcher->new;

    $dispatcher->add_rule(
        Path::Dispatcher::Rule::Regex->new(
            regex => qr{^/(foo)/},
            block => sub { warn $1; },
        )
    );

    $dispatcher->add_rule(
        Path::Dispatcher::Rule::Tokens->new(
            tokens    => ['ticket', 'delete', qr/^\d+$/],
            delimiter => '/',
            block     => sub { delete_ticket($3) },
        )
    );

    my $dispatch = $dispatcher->dispatch("/foo/bar");
    die "404" unless $dispatch->has_matches;
    $dispatch->run;

=head1 DESCRIPTION

We really like L<Jifty::Dispatcher> and wanted to use it for L<Prophet>'s
command line.

The basic operation is that of dispatch. Dispatch takes a path and a list of
rules, and it returns a list of matches. From there you can "run" the rules
that matched. These phases are distinct so that, if you need to, you can
inspect which rules were matched without ever running their codeblocks.

You want to use L<Path::Dispatcher::Declarative> which gives you some sugar
inspired by L<Jifty::Dispatcher>.

=head1 ATTRIBUTES

=head2 rules

A list of L<Path::Dispatcher::Rule> objects.

=head2 name

A human-readable name; this will be used in the debugging hooks. In
L<Path::Dispatcher::Declarative>, this is the package name of the dispatcher.

=head1 METHODS

=head2 add_rule

Adds a L<Path::Dispatcher::Rule> to the end of this dispatcher's rule set.

=head2 dispatch path -> dispatch

Takes a string (the path) and returns a L<Path::Dispatcher::Dispatch> object
representing a list of matches (L<Path::Dispatcher::Match> objects).

=head2 run path, args

Dispatches on the path and then invokes the C<run> method on the
L<Path::Dispatcher::Dispatch> object, for when you don't need to inspect the
dispatch.

The args are passed down directly into each rule codeblock. No other args are
given to the codeblock.

=head2 complete path -> strings

Given a path, consult each rule for possible completions for the path. This is
intended for tab completion. You can use it with L<Term::ReadLine> like so:

    $term->Attribs->{completion_function} = sub {
        my ($last_word, $line, $start) = @_;
        my @matches = map { s/^.* //; $_ } $dispatcher->complete($line);
        return @matches;
    };

This API is experimental and subject to change. In particular I think I want to
return an object that resembles L<Path::Dispatcher::Dispatch>.

=head1 AUTHOR

Shawn M Moore, C<< <sartak at bestpractical.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-path-dispatcher at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Path-Dispatcher>.

=head1 SEE ALSO

=over 4

=item L<Jifty::Dispatcher>

=item L<Catalyst::Dispatcher>

=item L<HTTPx::Dispatcher>

=item L<Mojolicious::Dispatcher>

=item L<Path::Router>

=item L<http://github.com/bestpractical/path-dispatcher-debugger> - Not quite ready for release

=back

=head1 COPYRIGHT & LICENSE

Copyright 2008-2010 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

