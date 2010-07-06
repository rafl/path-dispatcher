package Path::Dispatcher::Match;
use Any::Moose;

use Path::Dispatcher::Path;
use Path::Dispatcher::Rule;

has path => (
    is       => 'rw',
    isa      => 'Path::Dispatcher::Path',
    required => 1,
);

has leftover => (
    is  => 'rw',
    isa => 'Str',
);

has rule => (
    is       => 'rw',
    isa      => 'Path::Dispatcher::Rule',
    required => 1,
);

has positional_captures => (
    is      => 'ro',
    isa     => 'ArrayRef',
    default => sub { [] },
);

has named_captures => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} },
);

sub run {
    my $self = shift;
    my @args = @_;

    local $_ = $self->path;

    return $self->_run_with_capture_vars(
        sub { $self->rule->run(@args) },
    );
}

sub _run_with_capture_vars {
    my $self = shift;
    my $code = shift;

    # clear $1, $2, $3, %+ so they don't pollute the number vars for the block
    "x" =~ /x/;

    # populate $1, $2, etc for the duration of $code
    # it'd be nice if we could use "local" but it seems to break tests
    my $i = 0;
    no strict 'refs';

    # populate %+
    *+ = $self->named_captures;

    my @positional = @{ $self->positional_captures };
    my $assignments = join "\n",
        map { "local *$_ = \\(\$positional[$_-1]);" }
        1 .. @positional;

    eval "
        $assignments;
        \$code->();
    ";
}

__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;

__END__

=head1 NAME

Path::Dispatcher::Match - the result of a successful rule match

=head1 SYNOPSIS

    my $rule = Path::Dispatcher::Rule::Tokens->new(
        tokens => [ 'attack', qr/^\w+$/ ],
        block  => sub { attack($2) },
    );

    my $match = $rule->match("attack dragon");

    $match->path             # "attack dragon"
    $match->leftover         # empty string (populated with prefix rules)
    $match->rule             # $rule

    $match->run                          # causes the player to attack the dragon
    $match->run_with_capture_vars($code) # runs $code with $1=attack $2=dragon

=head1 DESCRIPTION

If a L<Path::Dispatcher::Rule> successfully matches a path, it creates one or
more C<Path::Dispatcher::Match> objects.

=head1 ATTRIBUTES

=head2 rule

The L<Path::Dispatcher::Rule> that created this match.

=head2 path

The path that the rule matched.

=head2 leftover

The rest of the path. This is populated when the rule matches a prefix of the
path.

=head1 METHODS

=head2 run

Executes the rule's codeblock with the same arguments. If L</set_number_vars>
is true, then L</run_with_number_vars> is used, otherwise the rule's codeblock
is invoked directly.

=head2 run_with_number_vars coderef, $1, $2, ...

Populates the number variables C<$1>, C<$2>, ... then executes the coderef.

Unfortunately, the only way to achieve this (pre-5.10 anyway) is to match a
regular expression. Both a string and a regex are constructed such that
matching will produce the correct capture variables.

=cut

