package PerlMon::Sensors;


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

## Constructor
sub new {
	my $class = shift;
	my $self = {
		CPU_VOLTAGE	=> "Unknown",
		P3V		=> "Unknown",
		P5V		=> "Unknown",
		P12V		=> "Unknown",
		N12V		=> "Unknown",
		N5V 		=> "Unknown",
		FAN1		=> "Unknown",
		FAN2		=> "Unknown",
		FAN3 		=> "Unknown",
		MB_TEMP		=> "Unknown",
		CPU_TEMP	=> "Unknown",
		OTHER_TEMP	=> "Unknown"
	};
	bless ($self, $class);
	return $self;
}


## Finds as much information as possible
sub find_info {
	my $self = shift;
	$_ = `sensors`;
	
	
	$self->{CPU_VOLTAGE} = $1 if /VCore 1:\s+(\+\d\.\d+ V)/;
	$self->{P3V} = $1 if /\+3.3V:\s+(.\d\.\d+\s*V)\s+/;
	$self->{P5V} = $1 if /\+5V:\s+(.\d\.\d+\sV)\s+/;
	$self->{P12V} = $1 if /\+12V:\s+(.\d\d\.\d+\sV)\s+/;
	$self->{N12V} = $1 if /\-12V:\s+(.\d\d\.\d+\sV)\s+/;
	$self->{N5V} = $1 if /\-5V:\s+(.\d\.\d+\sV)\s+/;

	$self->{FAN1} = $1 if /fan1:\s+(\d+\s+RPM)/;
	$self->{FAN2} = $1 if /fan2:\s+(\d+\s+RPM)/;
	$self->{FAN3} = $1 if /fan3:\s+(\d+\s+RPM)/;

	$self->{MB_TEMP} = $1 if /M\/B\sTemp:\s+(.\d+..)/;
	if ($self->{MB_TEMP} == "Unknown") {
		open (FILE, "/proc/acpi/thermal_zone/THRM/temperature") || warn @_;
		$self->{MB_TEMP} = "+".$1 if <FILE> =~ /\w*:\s*(.*)(?=\n)/;
		close (FILE);
	}
	$self->{CPU_TEMP} = $1 if /CPU\sTemp:\s+(.\d+..)/;
	$self->{OTHER_TEMP} = $1 if /Temp\d:\s+(.\d+..)/;
}


## Returns a String of the information
sub toString {
	my $self = shift;
	return (" CPU voltage: $self->{CPU_VOLTAGE}\n".
		" +3.3V: $self->{P3V}\n".
		" +5V: $self->{P5V}\n".
		" +12V: $self->{P12V}\n".
		" -12V: $self->{N12V}\n".
		" -5V: $self->{N5V}\n".
		" Fan1: $self->{FAN1}\n".
		" Fan2: $self->{FAN2}\n".
		" Fan3: $self->{FAN3}\n".
		" Mainboard temp: $self->{MB_TEMP}\n".
		" CPU temp: $self->{CPU_TEMP} C\n".
		" Other temp: $self->{OTHER_TEMP} C\n"
	);
}
		
1; ##Make compiler happy
