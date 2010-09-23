package PerlMon::Distro;

use 5.008008;
use warnings;
use strict;

our $VERSION = '0.2';

# Tries figuring out which distro the user is running and assigns the 
# distros logo.
#
# NOTE: If you are not getting the correct logo displayed when running
# 	PerlMon, then look in the directory /etc and see how many files
# 	there are that say something like <DISTRO>-release or 
# 	<DISTRO>-version. Most likely there are more than one such file
# 	and PerlMon is checking the the wrong one first.
#
# 	An example of this is the distro Fedora. /etc contains a file
# 	called redhat-release and a file called fedora-release. If 
# 	Perlmon is checked for the redhat file first then the logo would
# 	be wrong.
# 	You can see where there can become some issues with distros that 
# 	are based off other ones. This problem is avoided for the 
# 	following distros:
# 		Fedora
# 		Sabayon
# 		Mandriva
# 		Ubuntu
# 	If you notice some issues like this with the distro that you are
# 	using then please feel free to contact me at the email address
# 	in the README file.
#
#
my $distro = "Unknown Distro";


sub openFile {
	my $file = shift;
	open (FILE, $file) || die "Cannot open file";
	$distro = <FILE>;
	close (FILE);
} ## end openFile


sub getDistro {
	my $graphical = shift;
	##$graphical = 0 if length($graphical);
	my $file; ## full path to file
   	
   	my $index = 0;
	my $logo = "tux.png" if $graphical;

   	if (-f "/etc/coas") {
      		openFile("/etc/coas");
   	} elsif (-f "/etc/environment.corel") {
      		openFile("/etc/environment.corel");
	} elsif (-f "/etc/fedora-release") { 
		## Fedora	
		openFile("/etc/fedora-release");
		$logo = "fedora_logo.png" if $graphical;
	} elsif (-f "/etc/mandrake-release") {
		## Mandrake
		openFile("/etc/mandrake-release");
		$logo = "mandriva_logo.png" if $graphical;
	} elsif (-f "/etc/mandriva-release") {
		## Mandriva
		openFile("/etc/mandriva-release");
		$logo = "mandriva_logo.png" if $graphical;
	} elsif (-f "/etc/SuSE-release") {
		## SUSE
		openFile("/etc/SuSE-release");
		$logo = "suse_logo.png" if $graphical;
	} elsif (-f "/etc/turbolinux-release") {
		## Turbo Linux
		openFile("/etc/turbolinux-release");
		$logo = "turbolinux_logo.png" if $graphical;
	} elsif (-f "/etc/slackware-version") {
		## Slackware
		openFile("/etc/slackware-version");
		$logo = "slackware_logo.png" if $graphical;
	} elsif (-f "/etc/enlisy-release") {
		## Enlisy
		openFile("/etc/enlisy-release");
		$logo = "enlisy_logo.png" if $graphical;
	} elsif (-f "/etc/arch-release") {
		## Arch Linux
		## $distro = `$CAT /etc/arch-release`;
		$distro = "Arch";
		$logo = "arch_logo.png" if $graphical;
	} elsif (-f "/etc/sabayon-release") {
		## Sabayon
		openFile("/etc/sabayon-release");
		$logo = "sabayon_logo.png" if $graphical;
	} elsif (-f "/etc/gentoo-release") {
		## Gentoo
		openFile("/etc/gentoo-release");
		$logo = "gentoo_logo.png" if $graphical;
	}elsif (-f "/etc/redhat-release") {
		## Red Hat
 		openFile("/etc/redhat-release");
		$logo = "redhat_logo.png" if $graphical;
	} elsif (-f "/etc/zenwalk-version") {
		## Zenwalk
		openFile("/etc/zenwalk-version");
		$logo = "zenwalk_logo.png" if $graphical;
	} elsif (-f "/etc/lsb-release"){

	   ## Ubuntu
	   my @data;
	   open (UBUNTU, "/etc/lsb-release") || die ("Cannot open file");
	  
	   foreach my $m (<UBUNTU>){
		   chomp ($m);
		   $m =~ /[(\w).\1]*$/;
		   $data[$index] = $&;
		   $index++;
	   }
	   close (UBUNTU);
	   $data[2] = "(".$data[2].")";
	   $distro = join (" ", $data[0], $data[1], $data[2]);

	   $logo = "ubuntu_logo.png" if $graphical;

   	} elsif (-f "/etc/debian_version" && $distro eq "Unknown Distro") {
		##Debian
		$distro = "Debian ".readpipe("/etc/debian_version");
		$logo = "debian_logo.png" if $graphical;
	} else {

		## This is a last resort to try and identify the distro

		chomp( $distro = `ls \/etc \| grep \"version\\|release\"`);
		$distro = "/etc/$distro";
		open(D, "$distro");
		for my $m (<D>) { ($distro = $m) && last;	}
		close (D);
	}
	
	chomp $distro;
   	return ($distro, $logo);
}  ## end getDistro



1; #make compiler happy
