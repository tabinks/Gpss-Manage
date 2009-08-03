#!/usr/bin/perl
################################################################################
# makeSurfaceScreenLibrary.pl
#
# Author: T.A. Binkowski
# Date:   January 20, 2009
#
# Descrption: Outputs all the absolute paths in a directory
#
###############################################################
use File::Basename;
use File::Spec::Functions qw(rel2abs);
use Getopt::Long;
use List::Util 'shuffle';
use FindBin;

use lib '/home/abinkows/';
use PetaPerl::Environment;
use PetaPerl::Log;
#$|=1;

#############################################################
# Scene
#############################################################
my $SYSTEM  = System();
my $DATE    = PetaPerl::Environment::DateSimple();
PetaPerl::Log::About(NULL,@ARGV);

#############################################################
# Command line arguments
#############################################################
my $USAGE="perl makeSurfaceScreenLibrary.pl my_dir_path/ [-u uniquify] [-s shuffle] [-h help]\n";
GetOptions("m!" => \$INCLUDE_METALS,
	   "u!" => \$UNIQUE,
	   "h!" => \$HELP,
	   "library=s" => \$LIBRARY,
	   "prefix=s" => \$PREFIX
	   );

#############################################################
# Set GPSS-Library
#############################################################
if($ENV{'HOST'} eq 'tbinkowski4') {
    $LIBRARY = ($LIBRARY) ? $LIBRARY : "/Volumes/bioxshared.bio.anl.gov/sling/Gpss/";
} else {
    $LIBRARY = ($LIBRARY) ? $LIBRARY : "/home/abinkows/Gpss/Gpss-Library/";
}
die("Library $LIBRARY does not exist.\n$USAGE\n") if (!-e $LIBRARY);
die("\nUsage:\t$USAGE\n") if ($HELP);

#############################################################
# Set Paths
#############################################################
my $LIBRARY_PATH="$FindBin::Bin/Library/";
my $OUTFILE="$LIBRARY_PATH/gpss.$DATE.$SYSTEM";
$OUTFILE.=".unique" if $UNIQUE;
open(ATOMLESS,"> $OUTFILE.bad") or die("Couldn't open $OUTFILE.bad");
$OUTFILE.=".db";
open(DB,">$OUTFILE") or die("Couldn't open $OUTFILE");

#############################################################
#
#############################################################
my %seen={};
foreach(glob("$LIBRARY/*")) {
    foreach $file (glob("$_/*gpss")) {
	($pdb,$het,$hetNumber,$chain)=split(/\./,basename($file));
	next if $het=~/MSE/;
	if(!$INCLUDE_METALS) {next if isMetal($het);}
	$key = $pdb."_".$het; 

	if(!`grep ATOM $file`) {
	    print ATOMLESS "$file\n";
	} else {
	    if($UNIQUE) {
		if ($seen{$key}!=1) {
		    push @list, rel2abs($file);
		    $seen{$key}=1;
		}    
	    } else {
		push @list, rel2abs($file);
	    }
	}
	print STDERR $count."\n" if ++$count%1000==0;
    }
    #last if $_ =~ '20';
}

@reorder=shuffle(@list);
foreach(@reorder) {
    print DB $_."\n";
}

close DB;


###############################################################
# Subroutines
###############################################################
sub isMetal {
    my %Metals   = ( 
	#######################################################
	# Sodium
	#######################################################
	'NA' => 'SODIUM',
	'NA2'   =>  'SODIUM ION, 2 WATER COORDINATED',
	'NA5'   =>  'SODIUM ION, 5 WATERS COORDINATED',
	'NA6'   =>  'SODIUM ION, 6 WATERS COORDINATED',
	'NAO'   =>  'SODIUM ION, 1 WATER COORDINATED',
	'NAW'   =>  'SODIUM ION, 3 WATERS COORDINATED',
	
	#######################################################
	# Magnesium
	#######################################################
	'MG' => 'MAGNESIUM',
	'MO1'   =>  'MAGNESIUM ION, 1 WATER COORDINATED',
	'MO2'   =>  'MAGNESIUM ION, 2 WATERS COORDINATED',
	'MO3'   =>  'MAGNESIUM ION, 3 WATERS COORDINATED',
	'MO4'   =>  'MAGNESIUM ION, 4 WATERS COORDINATED',
	'MO5'   => 'MAGNESIUM ION, 5 WATERS COORDINATED',
	'MO6'   =>  'MAGNESIUM ION, 6 WATERS COORDINATED',
	
	#######################################################
	# Postassium
	#######################################################
	'K' => 'POTASSIUM',
	'K04' => 'POTASSIUM ION, 4 WATERS COORDINATED',
	
	#######################################################
	# Calcium
	#######################################################
	'CA' => 'CALCIUM',
	'OC1'   =>  'CALCIUM ION, 1 WATER COORDINATED',
	'OC2'   =>  'CALCIUM ION, 2 WATERS COORDINATED',
	'OC3'   =>  'CALCIUM ION, 3 WATERS COORDINATED',
	'OC4'   =>  'CALCIUM ION, 4 WATERS COORDINATED',
	'OC5'   =>  'CALCIUM ION, 5 WATERS COORDINATED',
	'OC6'   =>  'CALCIUM ION, 6 WATERS COORDINATED',
	'OC7'   =>  'CALCIUM ION, 7 WATERS COORDINATED',
	
	#######################################################
	# Iron
	#######################################################
	'FE' => 'IRON',
	
	#######################################################
	# Cobalt
	#######################################################
	'CO' => 'COBALT',
	'CO5'   =>  'COBALT ION, 5 WATERS COORDINATED',
	'OCL'   =>  'COBALT ION, 1 WATER COORDINATED',
	'OCM'   =>  'COBALT ION, 3 WATERS COORDINATED',
	'OCN'   =>  'COBALT ION, 2 WATERS COORDINATED',
	'OCO'   =>  'COBALT ION, 6 WATERS COORDINATED',
	
	# Zinc
	'ZN' => 'ZINC',
	'ZN2' => 'ZINC',
	'ZN3' => 'ZINC ION, 1 WATER COORDINATED',
	'ZNO' => 'ZINC ION, 2 WATERS COORDINATED',
	'ZO3' => 'ZINC ION, 3 WATERS COORDINATED',
	
	#######################################################
	# Gold
	#######################################################
	'AU' => 'GOLD',
	'AU3'    =>  'GOLD 3+ ION',
	
	#######################################################
	# Nickel
	#######################################################
	'NI' => 'NICKEL',
	'NI1'    =>  'NICKEL ION, 1 WATER COORDINATED',
	'NI2'   =>  'NICKEL (II) ION, 2 WATERS COORDINATED',
	'NI3'   =>  'NICKEL (II) ION, 3 WATERS COORDINATED',
	
	#######################################################
	# Copper
	#######################################################
	'CU' => 'COPPER',
	'1CU'   =>  'COPPER ION, 1 WATER COORDINATED',
	
	#######################################################
	# Chloride
	#######################################################
	'CL' => 'CLORIDE ION',
	
	'TE' => 'TELLURIUM',
	'MO' => 'MOLYBDENUM',
	'TL' => 'THALIUM',
	'V' => 'VANADIUM',
	'MO' => 'MOLYBDENUM',
	'W' => 'TUNGSTEN',
	'CR' => 'CHROMIUM',
	'MN' => 'MANGANESE',
	);
    
   if (defined($Metals{$_[0]})) {
       return 1;
   } else {
       return 0;
   }
}
