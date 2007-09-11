use strict;
use warnings;

use Test::More tests => 11;

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
    my @files  = Test::Fixme::list_files($dir);
    my @wanted = sort map { "$dir/$_" } qw( one.txt two.pl three.pm four.pod );
    is_deeply( \@files, \@wanted, "check correct files returned from '$dir'" );
}

{    # Check that the search descends into sub folders.
    my $dir    = 't/dirs/deep';
    my @files  = Test::Fixme::list_files($dir);
    my @wanted = sort map { "$dir/$_" }
      map { "$_.txt" }
      qw'deep_a deep_b
      one/deep_one_a one/deep_one_b
      two/deep_two_a two/deep_two_b';
    is_deeply( \@files, \@wanted, "check correct files returned from '$dir'" );
}

SKIP: {    # Check that non files do not get returned.
    skip "cannot create symlink", 4 unless eval { symlink( "", "" ); 1 };

    my $dir         = "t/dirs/types";
    my $target      = "normal.txt";
    my $target_file = "$dir/$target";
    my $symlink     = "$dir/symlink";

    # Make a symbolic link
    ok symlink( $target, $symlink ), "create symlinked file";
    ok -e $symlink, "symlink now exists";

    my @files  = Test::Fixme::list_files($dir);
    my @wanted = ($target_file);

    is_deeply( \@files, \@wanted,
        "check that non files are not returned from '$dir'" );

    ok unlink($symlink), "delete symlinked file";
}
