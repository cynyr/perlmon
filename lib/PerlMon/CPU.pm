package PerlMon::CPU;


##############################################################
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
##############################################################

## this to add
## 
## Code name
## Socket
## technology (65nm, 90nm, ...)
## number of cores

use strict;
use constant IMAGE_PATH => './images';

#Constructor
sub new {
	my $class = shift;
	my $self = {
		"VENDOR"		=> "Unknown",
		"MODEL"		=> "Unknown",
		"SPEED"		=> "Unknown",
		"STEPPING"	=> "Unknown",
		"FAMILY"		=> "Unknown",
		"MODEL_NUM"	=> "Unknown",
		"L1CACHE"	=> "Unknown",
		"L2CACHE"	=> "Unknown",
		"ARCH"		=> "Unknown",
		"FLAGS"		=> "Unknown", #EM64T, x86-64
		#"CORES"		=> "1",
		"LOGO"		=> undef
	};
	bless ($self, $class);
	return $self;
}

#finds as much info as possible
sub find_info {
	my $self = shift;
	my $graphical = shift;
	my $UNAME = `which uname`; chomp $UNAME;
	my $DMESG = `which dmesg`; chomp $DMESG;
	$_ = `cat /proc/cpuinfo`;
	$self->{ARCH} = `$UNAME -m`; 
	chomp $self->{ARCH};
	$self->{VENDOR} = $1 if $_ =~ /vendor_id\s*:\s+(\w+)/;
	$self->{FAMILY} = $1 if /cpu family\s*:\s+(\d+)/;
	$self->{MODEL_NUM} = $1 if /model\s*:\s+(\d+)/;
	$self->{MODEL} = $1 if /model name\s*:\s+(.*)\n/;
	$self->{STEPPING} = $1 if /stepping\s*:\s+(\d+)/;
	$self->{SPEED} = $1 if /cpu MHz\s*:\s+(\d+\.\d+)/;
	$self->{L2CACHE} = $1 if /cache size\s*:\s+(\d+\s*\w+)/;

	$self->{FLAGS} = $1 if /flags\s*:\s*.*(mmx)/;
	$self->{FLAGS} .= ", ".$1.", ".$2 if /flags\s*:\s*.*(sse).*(sse2)/;
	$self->{FLAGS} .= ", ".$1 if /flags\s*:\s*.*(sse3)/;
	$self->{FLAGS} .= ", ".$1 if /flags\s*:\s*.*(3dnow)/;
	
	$self->{L1CACHE} = &cacheL1(`$DMESG | grep "L1"`);

	
	if ($graphical) {
		if ($self->{VENDOR} =~ /AMD/) {
			$self->{LOGO} = "/amd_logo.png";
		} elsif ($self->{VENDOR} =~ /Intel/) {
			$self->{LOGO} = "/intel_logo.png";
		} else {
			$self->{LOGO} = "/cpu.png";
		}
	}
}


# Gets GTK::Image for vendor logo
sub getLogo {
	my $self = shift;
	return $self->{LOGO};
}

# Returns a string of available information
#
# This method is currently available to make setting up the Gtk2 GUI easier.
sub toString_top_left {
	my $self = shift;
	return (" CPU Vendor: $self->{VENDOR} \n".
		" CPU Model: $self->{MODEL} \n".
		" CPU Arch: $self->{ARCH} \n".
		" CPU Family: $self->{FAMILY} \n".
		" CPU Model : $self->{MODEL_NUM} \n".
		" CPU Stepping: $self->{STEPPING} \n".
		" Instructions : $self->{FLAGS} \n"
	);
}

#
# This method is currently available to make setting up the Gtk2 GUI easier.
sub toString_bottom {
	my $self = shift;
	return ("\n".
		" CPU speed: $self->{SPEED} \n".
		" CPU L1: $self->{L1CACHE} \n".
		" CPU L2: $self->{L2CACHE} \n"
	);
}

# Returns a string of all information found
sub toString {
	my $self = shift;
	my $string = $self->toString_top_left().$self->toString_bottom();
	return $string;
}

# Gets CPUs L1 cache
sub cacheL1 {
	my $c;
	$_[0] =~ /(\d+K)/;
	$c = "$1";
	$_[0] =~ /D cache\.*(\d+K)/;
	return "$c + $1";
}


1; #make compiler happy
		
