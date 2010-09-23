package PerlMon::WMDE;

#############################################################################
# Copyright  2007, 2008 Michael John <perlmon.linux@gmail.com>
# All Rights Reserved
#
# This file is part of the PerlMon package.
#
#    PerlMon is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; under current version 3 of the License.
#
#    PerlMon is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
############################################################################

## This package has one main job, it tries to determin the Window Manager(if on)
## and Desktop Environment(if one) and the version for them.

use warnings;
use strict;

sub getWMDE {
my ($PS, $AWK) = @_;

my %WMlist = (
	"beryl-manager"  => "beryl-manager --version",  #Beryl

	"kwin"		 => "kwin -v", 			#KWin

	"compiz"	 => "compiz --version",		#Compiz

	"metacity"	 => "metacity --version",	#Metacity

        "xfwm4"		 => "xfwm4 -V",  		#Xfwm4

        "openbox"	 => "openbox --version",	#Openbox

        "blackbox"	 => "blackbox -version",	#Blackbox

        "fvwm"		 => "fvwm --version",		#FVWM

        "enlightenment"	 => "enlightenment --version",	#Enlightenment
	
	"icewm"		 => "icewm --version",		#IceWM 

        "wmaker"	 => "wmaker --version",  	#Window Maker

        "pekwm"		 => "pekwm --version",		#PekWM

	"fluxbox"	 => "fluxbox -version",  	#Fluxbox
	
	"evilwm"	 => "evilwm -V", 		#EvilWM

	"twm"		 => "TWM",			#TWM
	
	"Xmetisse"	 => "Metisse"			#Xmetisse -version
);

my %DElist = (
	"nautilus"	  => "Gnome",	#nautilus --version

        "xfce-mcs-manage" => "Xfce4",	#xfce4-session --version

        "startkde"	  => "KDE"	#kwin -v | $GREP KDE
);


my $processes = `$PS -A | $AWK {'print \$4'}`; # get a list of all running processes

my ($WM, $DE, $WM_ver, $DE_ver) = qw(Unknown Unknown Unknown Unknown);
#my @array; ## NOTE: removed effective version 0.1.4 
my $m; # used in the foreach-loops for finding WM and DE

foreach $m (keys %WMlist) {

	if ($processes =~ /$m/){
		$WM = `$WMlist{$m}`;
		$WM_ver = $WM;	# $wm_ver equals $wm if no string minipulation is needed
	
		# Kwin
		$WM =~ /KWin.*(?=\n)/ and $WM_ver = $& if $m eq "kwin";
		# Beryl
		$WM =~ s/beryl-manager/Beryl/ and $WM_ver = $WM if $m eq  "beryl-manager";
		# Compiz
		@_ = split(/\n/, $WM) and $_[1] =~ s/c/C/ and $WM_ver = $_[1] if $m eq "compiz";
		# Metacity
		@_ = split(/\n/, $WM) and $WM_ver = $_[0] if $m eq "metacity";
		# IceWM
		# @array = split(/\,/, $WM) and $WM_ver = $array[0] if $m eq "icewm"; ## NOTE: removed effective version 0.1.4 
		@_ = split(/\,/, $WM) and $WM_ver = $_[0] if $m eq "icewm";
		# Fluxbox
		@_ = split(/\:/, $WM) and $WM_ver = $_[0] if $m eq "fluxbox";
		# Blackbox
		@_ = split(/\n/, $WM) and $WM_ver = $_[0] if $m eq "blackbox";
		# Openbox
		@_ = split(/\n/, $WM) and $WM_ver = $_[0] if $m eq "openbox";
		# Enlightenment
		# @array = split(/\n/, $WM) and $WM_ver = $array[0] if $m eq "enlightenment"; ## NOTE: removed effective version 0.1.4 
		@_ = split(/\n/, $WM) and $WM_ver = $_[0] if $m eq "enlightenment";
		# Xfwm4
		$WM =~ /xfwm4 version .+(?= \(|\s+for)/ and $WM_ver = $& if $m eq "xfwm4";
		# FVWM
		@_ = split(/\n/, $WM) and $WM_ver = $_[0] if $m eq "fvwm";
		# TWM
		$WM_ver = "TWM" if $m eq "twm";
		# Metisse
		#$WM_ver =~ s/Xmetisse/Metisse/ if $m eq "Xmetisse";
		$WM_ver = "Metisse" if $m eq "Xmetisse";

			
		last unless $m eq "beryl-manager"; # For those running beryl-manager 
						   # but with a WM other than Beryl
	}
}

foreach $m (keys (%DElist)) {

	if ($processes =~ /$m/){
		$DE = $DElist{$m};
		$DE_ver = $DE;

		if ($m eq "startkde") {
			$DE_ver = `kwin -v`;
			$DE_ver =~ /KDE.*(?=\n)/ and $DE_ver = $&;
		} elsif ($m eq "nautilus") {
			$DE_ver = `nautilus --version`;
		} elsif ($m eq "xfce-mcs-manage") {
			$m = `xfce4-session --version`;
			$m =~ /\((Xfce.*)\)/;
			$DE_ver = $1;
		}
		last; # way waste time going through rest of keys
	}
}

chomp( $WM_ver);
chomp( $DE_ver);
return ($WM_ver,$DE_ver);

}

1;

