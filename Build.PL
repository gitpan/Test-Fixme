use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
    module_name => 'Test::Fixme',
    license     => 'perl',
    requires    => {
	'Module::Build' => 0,
	'File::Finder'  => 0,
	'File::Slurp'   => 0,
	'Test::Builder' => 0,
        'Carp'          => 0,
    },
);

$build->create_build_script;

