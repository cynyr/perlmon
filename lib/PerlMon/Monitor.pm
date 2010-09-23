package PerlMon::Monitor;

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
	my $self = {
		"RESOLUTION"	=> "Unknown",
		"DEPTH"		=> "Unknown",
		"REFRESH"		=> "Unknown",
		"COLOR"		=> "Unknown"
	};
	bless ($self, $class);
	return $self;
}


# Finds as much information as possible
sub find_info {
	my $self = shift;
	my $NVIDIA = `which nvidia-settings`;
	chomp $NVIDIA;
	
	$_ = `$NVIDIA -q RefreshRate`;
	$self->{REFRESH} = $1 + 1 if /Attribute\s+\'RefreshRate\'.*\):\s+(\d+)/;

	my $XWININFO = `which xwininfo`;
	chomp $XWININFO;
	$_ = `$XWININFO -root`;
	$self->{DEPTH} = $1 if /Depth: (\d+)/;
	$self->{RESOLUTION} = &MonitorRes($XWININFO, "grep");
	$self->{COLOR} = $1 if /Visual\s+Class:\s+(\S+)/;
}
	

# Returns a String of the information
sub toString {
	my $self = shift;
	return (" Resolution: $self->{RESOLUTION} \n".
		" Refresh Rate: $self->{REFRESH} Hz\n".
		" Depth: $self->{DEPTH} \n".
		" Color: $self->{COLOR} \n"
	);
}
	
1; #Make compiler happy


# Used to get monitor resolution
sub MonitorRes {
	chomp (my ($w, $h) = `$_[0] -root | $_[1] \"Width\\\|Height\"`);
	$w =~ s/\s*Width:\s+//;
	$h =~ s/\s*Height:\s+//;
	return "$w x $h";
}
