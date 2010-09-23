package PerlMon::HD;


#############################################################################
# Copyright© 2007, 2008 Michael John
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

use strict;


# Constructor
sub new {
	my $class = shift;
	my (@HDInfo, @usedHD, @usedpHD);
	my $self = {
		FS	=> [],     #partition of drive in *nix terms (/dev/*)
		TYPE	=> [],     #File system type (ext2, ext3, reiser, etc..)
		USED	=> [],     #Amount of partition/drive used
		TOTAL	=> [],     #Total partition/drive space
		USEDP	=> [],     #Percentage of partition/drive used
		MOUNT	=> [],     #mount point for partition/drive
		NUM_PARTS => undef #number of partitions/drives
	};
	bless ($self, $class);
	return $self;
}

# Finds as much information as program can
sub find_info {
	my $self = shift;
	@_ = `df -Th`;
	shift @_;
	my $skip_fs = &skip_fstype();
	my $index = 0;
	foreach my $m (@_) {
		my @b = split(/\s+/, $m);
		next if $skip_fs =~ /$b[1]/;
		$self->{USED}[$index] = $b[3];
		$self->{USEDP}[$index] = $b[5];
		$self->{FS}[$index] = $b[0];
		$self->{MOUNT}[$index] = $b[6];
		$self->{TYPE}[$index] = $b[1];
		$self->{TOTAL}[$index] = $b[2];
		$self->{NUM_PARTS} = $index + 1;
		$index++;
	};
}

# Returns a string of information on ONLY ONE partition/drive
sub toString_single {
	my $self = shift;
	my $i = shift;
	return ("$self->{FS}[$i] mounted at $self->{MOUNT}[$i]   ".
		"Type: $self->{TYPE}[$i]   Total size: $self->{TOTAL}[$i]\n"
	);
}


# Returns a string of all information
sub toString {
	my $self = shift;
	my $string;
	for (my $i = 0; $i < $self->{NUM_PARTS}; $i++) {
		$string .= ("$self->{FS}[$i] mounted at $self->{MOUNT}[$i]   ".
			"Type: $self->{TYPE}[$i]   Total size: $self->{TOTAL}[$i]\n"
		);
	}
	return $string;
			
}

# Reading the settings file that tells PerlMon what File system types to not 
# include in the Hard Drive tab.
sub skip_fstype {
	my $file = `echo \$HOME`;
	chomp($file);
	$file .= "/.perlmonrc";
	if ( not -e "$file") {
		`cp /etc/perlmonrc $file`;
	}
	open (FS, $file) || die ("Cannot open file for File System type settings. \n $file");

	foreach my $m (<FS>) {
		next if $m =~ /^\s*\#/;
		$_[1] .= $m. " ";
	}
	close(FS);
	$_[1] =~ s/\n//g;
	return $_[1];
}


1; #make compiler happy

