use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    'ABSTRACT_FROM' => 'lib/Test/Fixme.pm',
    'AUTHOR'        => [ 'Graham Ollis <plicease@wdlabs.com', 'Edmund von der Burg <evdb@ecclestoad.co.uk>' ],
    'NAME'          => 'Test::Fixme',
    'VERSION_FROM'  => 'lib/Test/Fixme.pm',
    'PREREQ_PM'     => {
        'Carp'                => 0,
        'ExtUtils::MakeMaker' => 0,
        'File::Find'          => 0,
        'File::Slurp'         => 0,
        'Test::Builder'       => 0,
        'Test::More'          => 0,
    },
);
