package Test::Fixme;

use strict;
use warnings;

use Carp;
use File::Find;
use ExtUtils::Manifest qw( maniread );

use Test::Builder;
require Exporter;
use vars qw( @ISA @EXPORT );
@ISA    = qw(Exporter);
@EXPORT = qw( run_tests );

our $VERSION;
$VERSION = '0.07';

my $Test = Test::Builder->new;

sub run_tests {

    # Get the values and setup defaults if needed.
    my %args = @_;
    $args{match} = 'FIXME' unless defined $args{match} && length $args{match};
    $args{where} = '.'     unless defined $args{where} && length $args{where};
    $args{filename_match} = qr/./
      unless defined $args{filename_match} && length $args{filename_match};

    # Skip all tests if instructed to.
    $Test->skip_all("All tests skipped.") if $args{skip_all};

    # Get files to work with and set the plan.
    my @files;
    if(defined $args{manifest}) {
        @files = keys %{ maniread( $args{manifest} ) };
    } else {
        @files = list_files( $args{where}, $args{filename_match} );
    }
    $Test->plan( tests => scalar @files );

    # Check ech file in turn.
    foreach my $file (@files) {
        my $results = scan_file( file => $file, match => $args{match} );

        if ( scalar @$results == 0 ) {
            $Test->ok( 1, "'$file'" );
            next;
        }
        else {
            $Test->ok( 0, "'$file'" );
            $Test->diag( format_file_results($results) );
        }
    }
}

sub scan_file {
    my %args = @_;
    return undef unless $args{file} && $args{match};

    # Get the contents of the files and split content into lines.
    my $content     = load_file( $args{file} );
    my @lines       = split $/, $content;
    my $line_number = 0;

    # Set up return array.
    my @results = ();

    foreach my $line (@lines) {
        $line_number++;
        next unless $line =~ m/$args{match}/;

        # We have a match - add it to array.
        push @results,
          {
            file  => $args{file},
            match => $args{match},
            line  => $line_number,
            text  => $line,
          };
    }

    return \@results;
}

sub format_file_results {
    my $results = shift;
    return undef unless defined $results;

    my $out = '';

    # format the file name.
    $out .= "File: '" . ${$results}[0]->{file} . "'\n";

    # format the results.
    foreach my $result (@$results) {
        my $line = $$result{line};
        my $txt  = "    $line";
        $txt .= ' ' x ( 8 - length $line );
        $txt .= $$result{text} . "\n";
        $out .= $txt;
    }

    return $out;
}

sub list_files {
    my $path_arg = shift;
    croak
'You must specify a single directory, or reference to a list of directories'
      unless defined $path_arg;

    my $filename_match = shift;
    if ( !defined $filename_match ) {

        # Filename match defaults to matching any single character, for
        # backwards compatibility with one-arg list_files() invocation
        $filename_match = qr/./;
    }

    my @paths;
    if ( ref $path_arg eq 'ARRAY' ) {

        # Ref to array
        @paths = @{$path_arg};
    }
    elsif ( ref $path_arg eq '' ) {

        # one path
        @paths = ($path_arg);
    }
    else {

        # something else
        croak
'Argument to list_files must be a single path, or a reference to an array of paths';
    }

    foreach my $path (@paths) {

        # Die if we got a bad dir.
        croak "'$path' does not exist" unless -e $path;
    }

    my @files;
    find(
        {
            preprocess => sub {
                # no GIT, Subversion or CVS directory contents
                grep !/^(.git|.svn|CVS)$/, @_,
            },
            wanted => sub {
                push @files, $File::Find::name
                    if -f $File::Find::name;
            },
            no_chdir => 1,
        },
        @paths
    );

    @files =
      sort    # sort the files
      grep { m/$filename_match/ }
      grep { !-l $_ }               # no symbolic links
      @files;

    return @files;
}

sub load_file {
    my $filename = shift;

    # If the file is not regular then return undef.
    return undef unless -f $filename;

    # Slurp the file.
    open(my $fh, '<', $filename) || croak "error reading $filename $!";
    my $content = do { local $/; <$fh> };
    close $fh;
    return $content;
}

1;

__END__

=head1 NAME
 
Test::Fixme - check code for FIXMEs.
 
=head1 SYNOPSIS
 
    # In a test script like 't/test-fixme.t'
    use Test::Fixme;
    run_tests();

    # You can also tailor the behaviour.
    use Test::Fixme;
    run_tests( where    => 'lib',      # where to find files to check
               match    => 'TODO',     # what to check for
               skip_all => $ENV{SKIP}  # should all tests be skipped
    );

=head1 DESCRIPTION
 
When coding it is common to come up against problems that need to be
addressed but that are not a big deal at the moment. What generally
happens is that the coder adds comments like:

 # FIXME - what about windows that are bigger than the screen?

 # FIXME - add checking of user priviledges here.

L<Test::Fixme> allows you to add a test file that ensures that none of
these get forgotten in the module.

=head2 Arguments

By default run_tests will search for 'FIXME' in all the files it can
find in the project. You can change these defaults by using 'where' or
'match' as follows:

    run_tests( where => 'lib', # just check the modules.
               match => 'TODO' # look for things that are not done yet.
    );

=over 4

=item where

Specifies where to search for files.  This can be a scalar containing a
single directory name, or it can be a listref containing multiple
directory names.

=item match

Expression to search for within the files.  This may be a simple
string, or a qr//-quoted regular expression.  For example:

    match => qr/[T]ODO|[F]IXME|[B]UG/,

=item filename_match

Expression to filter file names.  This should be a qr//-quoted regular
expression.  For example:

    match => qr/\.(:pm|pl)$/,

would only match .pm and .pl files under your specified directory.

=item manifest

Specifies the name of your MANIFEST file which will be used as the list
of files to test instead of I<where> or I<filename_match>.

    manifest => 'MANIFEST',

=back

=head1 HINTS

If you want to match something other than 'FIXME' then you may find
that the test file itself is being caught. Try doing this:

    run_tests( match => 'TO'.'DO' );

You may also wish to suppress the tests - try this:

    use Test::Fixme;
    run_tests( skip_all => $ENV{SKIP_TEST_FIXME} );

You can only run run_tests once per file. Please use several test
files if you want to run several different tests.

=head1 SEE ALSO

L<Devel::FIXME>

=head1 AUTHOR

Current maintainer: Graham Ollis E<lt>plicease@cpan.orgE<gt>

Please let me know if you have any comments or suggestions.

Original author: Edmund von der Burg E<lt>evdb@ecclestoad.co.ukE<gt>

=head1 ACKNOWLEDGMENTS

Dave O'Neill added support for 'filename_match' and also being able to pass a
list of several directories in the 'where' argument. Many thanks.

=head1 LICENSE

Copryight (C) 2008 Edmund von der Burg

Copyright (C) 2012 Graham Ollis

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
