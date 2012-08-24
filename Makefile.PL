use strict;
use warnings;
use 5.006000;

use ExtUtils::MakeMaker;

WriteMakefile(
    'ABSTRACT_FROM'    => 'lib/Test/Fixme.pm',
    'AUTHOR'           => [ 'Graham Ollis <plicease@cpan.org>', 'Edmund von der Burg <evdb@ecclestoad.co.uk>' ],
    'NAME'             => 'Test::Fixme',
    'VERSION_FROM'     => 'lib/Test/Fixme.pm',
    'LICENSE'          => 'perl',
    'MIN_PERL_VERSION' => '5.006000',
    'PREREQ_PM'     => {
        'Carp'                => 0,
        'ExtUtils::MakeMaker' => 0,
        'File::Find'          => 0,
        'Test::Builder'       => 0,
        'Test::More'          => 0,
    },
    META_MERGE => {
        resources => {
            bugtracker => 'https://github.com/plicease/Test-Fixme/issues',
            homepage   => 'http://search.cpan.org/dist/Test-Fixme/',
            repository => 'git://github.com/plicease/Test-Fixme.git',
        },
    },
);
