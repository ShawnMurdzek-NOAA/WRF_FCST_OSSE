#!/usr/bin/perl

$numargs = @ARGV;

if ( $numargs != 2 ) {
   print "Incorrect number of arguments.\n";
   print " Usage: search_and_replace pattern1 pattern2\n";
   print "   (where pattern1 is to be replaced by pattern2)\n";
   exit;
}

my $filesdir = './';

opendir FILESDIR, $filesdir or
    die "Content-type: text/plain\n\nCan't open directory: $!\n";
@files = grep /\.ncl/, readdir FILESDIR;
#@difffiles = grep /diff/, @files;
closedir FILESDIR;


foreach $file (@files) {
  system("sed 's/$ARGV[0]/$ARGV[1]/g' $file > tmpfile");
  system("mv -f tmpfile $file");
}

