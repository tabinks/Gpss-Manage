#!/usr/bin/perl
##############################################################
#
#
##############################################################
use File::Path;
use File::Basename;
use Getopt::Long;
use File::Spec;
use File::Compare;
use POSIX;

##############################################################
#
##############################################################
GetOptions(
    "library=s" => \$ALT_LIBRARY,
    "verbose!"  => \$VERBOSE,
    "force!"    => \$FORCE,
    "h!"        => \$HELP,
    "rsync!"    => \$RSYNC
    );

my $USAGE="perl $0 -library /home/abinkows/Zinc/Zinc-Library [-verbose]\n";
die($USAGE) if $HELP;
$ZINC_LIBRARY=($ALT_LIBRARY) ? $ALT_LIBRARY : "/Volumes/bioxshared.bio.anl.gov/sling/Gpss";

##############################################################
# Rsync Zinc-Library
##############################################################
my $destinationPath="/home/abinkows/";
my $sourcePath="/Volumes/bioxshared.bio.anl.gov/sling/Gpss";
my $arguments="-avz --delete";
print STDERR "rsync $arguments $sourcePath abinkows\@login6.surveyor.alcf.anl.gov:$destinationPath\n";
print STDERR "rsync $arguments $sourcePath abinkows\@login6.intrepid.alcf.anl.gov:$destinationPath\n";
exit(1) if $RSYNC;
