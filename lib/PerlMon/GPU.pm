package PerlMon::GPU;


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
		RAM			=> "Unknown", #Amount of RAM
		TWINVIEW		=> "Unknown", #Twin view (on/off)
		CORETEMP		=> "Unknown", #Core temp (Celsius)
		AMBTEMP		=> "Unknown", #Ambient temp (Celsius)
		CLOCK		=> "Unknown", #Clock speeds
		DRIVER_VER	=> "Unknown", #Driver version
		CONTROL_VER	=> "Unknown", #Control version
		OPENGL_VER	=> "Unknown", #Open GL version
		NUMBER		=> "Unknown", #number of gpus
		NAME		=> "Unknown", #Model name
		DIR_RENDER	=> undef,     #direct rendering (yes/no)
		VENDOR		=> "Unknown", #Vendor
		LOGO		=> undef      #Logo
	};
	bless ($self, $class);
	return $self;
}


## Finds as much information as possible
sub find_info {
	my $self = shift;
	my $graphical = shift;
	my $NVIDIA = `which nvidia-settings`; chomp $NVIDIA;
	my $glxinfo = `which glxinfo`; chomp $glxinfo;
	## Determining Vendor
	if ($NVIDIA ne "") { 
	   $self->{VENDOR} = "Nvidia"; 
	
	   $_ = `$NVIDIA -q all`;
	   $self->{RAM} = $1/1024 if (/Attribute\s+\'VideoRam\'.*\):\s+(\d+)/);
	   $self->{TWINVIEW} = $1 ? "On" : "Off" if /Attribute\s+\'TwinView\'.*\):\s+(\d+)/;
	   $self->{CORETEMP} = $1 if /Attribute\s+\'GPUCoreTemp\'.*\):\s+(\d+)/;
	   $self->{AMBTEMP} = $1 if /Attribute\s+\'GPUAmbientTemp\'.*\):\s+(\d+)/;
	   $self->{CLOCK}= $1 if /Attribute\s+\'GPUCurrentClockFreqs\'.*\):\s+(\d+\,\d+)/;
	   $self->{CLOCK} =~ s/\,/ , /;
	   $self->{DRIVER_VER} = $1 if /Attribute\s+\'NvidiaDriverVersion\'.*\):\s+(.*)\n/;
	   $self->{CONTROL_VER} = $1 if /Attribute\s+\'NvControlVersion\'.*\):\s+(.*)\n/;
	   $self->{OPENGL_VER} = $1 if /Attribute\s+\'OpenGLVersion\'.*\):\s+(\d+\.?\d+?\.?\d+?)/;
	   $_ = `$NVIDIA -q gpus`;
	   $self->{NUMBER} = $1 if /\s*(\d+)\s+GPU/;
	   $self->{NAME} = $1 if /\((.*)\)/;
	   $_= `$glxinfo`;
	   $self->{DIR_RENDER} = $& if /direct\s+rendering.*(?=\n)/;
	 } ## End of Nvidia Block
	 
	 ## Determins logo if $graphical is true
	 if ($graphical) {
		$self->{LOGO} = "gpu.png";
		if ($self->{VENDOR} eq "Nvidia") {
	 		$self->{LOGO} = "nvidia_logo.png";
		}
	   }
}


## Returns a string of all information found
sub toString {
	my $self = shift;
	return (" Number of GPUs: $self->{NUMBER} \n".
	        " Name: $self->{NAME} \n".
		" Video RAM: $self->{RAM} MB \n".
		" Core Temp: $self->{CORETEMP} C \n".
		" Ambient Temp: $self->{AMBTEMP} C \n".
		" Clocks: $self->{CLOCK} \n".
		" Twin view: $self->{TWINVIEW} \n".
		" $self->{VENDOR} Driver Version: $self->{DRIVER_VER} \n".
		" $self->{VENDOR} Control Version: $self->{CONTROL_VER} \n".
		" OpenGL Version: $self->{OPENGL_VER} \n".
		" $self->{DIR_RENDER} \n"
	);
}


1; #make compiler happy

