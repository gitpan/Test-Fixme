use strict;
use warnings;

use Test::More tests => 2;

# Load the module.
use_ok 'Test::Fixme';

# Check we have a version.
ok $Test::Fixme::VERSION, "check we have a version number";

