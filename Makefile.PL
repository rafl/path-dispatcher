use inc::Module::Install;

name       'Path-Dispatcher';
all_from   'lib/Path/Dispatcher.pm';
repository 'http://github.com/bestpractical/path-dispatcher';

requires 'Any::Moose';
requires 'Try::Tiny';

build_requires 'Test::Exception';

WriteAll;

