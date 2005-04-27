use strict;
use warnings;

use Test::More tests => 10;

# Load the module.
use_ok 'Test::Fixme';

{    # Check that listing a directory that does not exist dies.
    local $SIG{__WARN__} = sub { 1 };
    eval { my @files = Test::Fixme::list_files('t/i/do/not/exist'); };
    ok $@, 'list_files died';
    ok $@ =~ m:^The directory 't/i/do/not/exist' does not exist:,
      "check that non-existent directory causes 'die'";
}

{    # Test that sub croaks unless a path is passed.
    local $SIG{__WARN__} = sub { 1 };
    eval { my @files = Test::Fixme::list_files(); };
    ok $@, 'list_files died';
    ok $@ =~ m:^You need to specify which directory to scan:,
      "check that no directory causes 'die'";
}

{    # Test the list_files function.
    my $dir    = 't/dirs/normal';
    my @files  = strip_cvs( sort( Test::Fixme::list_files($dir) ) );
    my @wanted = sort map { "$dir/$_" } qw( one.txt two.pl three.pm four.pod );
    ok eq_array( \@files, \@wanted ),
      "check correct files returned from '$dir'";
}

{    # Check that the search descends into sub folders.
    my $dir    = 't/dirs/deep';
    my @files  = strip_cvs( sort( Test::Fixme::list_files($dir) ) );
    my @wanted = sort map { "$dir/$_" }
      map { "$_.txt" }
      qw'deep_a deep_b
      one/deep_one_a one/deep_one_b
      two/deep_two_a two/deep_two_b';
    ok eq_array( \@files, \@wanted ),
      "check correct files returned from '$dir'";
}

SKIP: {    # Check that non files do not get returned.
    skip "cannot create symlink", 3 unless eval { symlink( "", "" ); 1 };

    my $dir = 't/dirs/types';

    # Make a symbolic link
    ok symlink( "normal.txt", "$dir/symlink" ), "create symlinked file";

    my @files  = strip_cvs( sort( Test::Fixme::list_files($dir) ) );
    my @wanted = ("$dir/normal.txt");

    ok eq_array( \@files, \@wanted ),
      "check that non files are not returned from '$dir'";
    ok unlink("$dir/symlink"), "delete symlinked file";
}

# Utility sub to strip out CVS related files.
# Strip out all files starting with 'E' or 'R' or ending with ',t'.
sub strip_cvs {
    my @in = @_;
    my @out = grep { !m/[ER]/ } grep { !m/,t$/ } @in;
    return @out;
}
