use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'         => 'Test::Fixme',
    'VERSION_FROM' => 'lib/Test/Fixme.pm',
    'PREREQ_PM'    => {
        'Carp'                => 0,
        'ExtUtils::MakeMaker' => 0,
        'File::Finder'        => 0,
        'File::Slurp'         => 0,
        'Test::Builder'       => 0,
        'Test::More'          => 0,
    },
);
