package PerlMon::Memory;


####################################################################
# Copyright 2007, 2008 Michael John
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
####################################################################

use strict;


# Constructor
sub new {
	my $class = shift;
	my $self = {
		"TOTAL_M"		=> "Unknown", #Memory Total
		"FREE_M"		=> "Unknown", #Memory Free
		"USED_M"		=> "Unknown", #Memory used
		"TOTAL_S"	=> "Unknown", #Swap Total
		"FREE_S"	=> "Unknown", #Swap Free
		"USED_S"	=> "Unknown", #Swap used
		"SWAPPINESS"	=> "Unknown" #swappiness number
	};
	bless ($self, $class);
	return $self;
}


# Finds as much information as the program can
sub find_info {
	my $self = shift;
	$_ = `cat /proc/meminfo`;
	$self->{TOTAL_M} = int $1/1024 if /MemTotal\s*:\s+(\d+)/;
	$self->{FREE_M} = int $1/1024 if /MemFree\s*:\s+(\d+)/;
	$self->{USED_M} = $self->{TOTAL_M} - $self->{FREE_M};
	$self->{TOTAL_S} = int $1/1024 if /SwapTotal\s*:\s+(\d+)/;
	$self->{FREE_S} = int $1/1024 if /SwapFree\s*:\s+(\d+)/;
	$self->{USED_S} = $self->{TOTAL_S} - $self->{FREE_S};
	$self->{SWAPPINESS} = `cat /proc/sys/vm/swappiness`;
	chomp( $self->{SWAPPINESS} );
}


# Gets fraction of Memory/Swap used (For Gtk2::ProgressBar)
sub getFraction {
	my $self = shift;
	my $choice = shift;
	if ($choice =~ /^memory$/i) {
		return ($self->{USED_M} / $self->{TOTAL_M});
	} elsif ($choice =~ /^swap$/i) {
		return ($self->{USED_S} / $self->{TOTAL_S});
	}
}


# Gets the percentage of Memory/Swap used (For text in Gtk2::ProgressBar)
sub getPercentage {
	my $self = shift;
	my $choice = shift;
	if ($choice =~ /^memory$/i and $self->{TOTAL_M} != 0) {
		return ( int(( $self->{USED_M} / $self->{TOTAL_M} ) * 100) );
	} elsif ($choice =~ /^swap$/i and $self->{TOTAL_S} != 0) {
		return ( int(( $self->{USED_S} / $self->{TOTAL_S} ) * 100) );
	} else {
		return 0;
	}
}
	
# Returns String on Memory information
sub toString_memory {
	my $self = shift;
	return (" Total Memory: $self->{TOTAL_M} MB \n".
		" Used Memory: $self->{USED_M} MB \n Free Memory: $self->{FREE_M} MB"
	);
}

# Retuns String on Swap information
sub toString_swap {
	my $self = shift;
	return (" Total Swap: $self->{TOTAL_S} MB \n".
		" Used Swap: $self->{USED_S} MB \n Free Swap: $self->{FREE_S} MB\n".
		" Swappiness: $self->{SWAPPINESS}"
	);
}

# Returns a String of all information
sub toString {
	my $self = shift;
	return $self->toString_memory."\n".$self->toString_swap."\n";
}
		
	
1;  #makes compiler happy
