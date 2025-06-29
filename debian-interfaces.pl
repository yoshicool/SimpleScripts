#!/usr/bin/perl -w

package asteria::debian;

use XML::Debian::ENetInterfaces;
use IO::File;
use XML::Simple;
use Data::Dumper;

@EXPORT_OK=qw(addinterface delinterface);

my $interface = XML::Debian::ENetInterfaces::read();

my $outfile = "newinterfaces";
# addinterface(XML::Debian::ENetInterfaces:: file, string interface, string mode, string address, string netmask, string gateway, string dns servers);
#$interface = addinterface($interface, "dhcp0", "DHCP");
#$interface = addinterface($interface, "static1", "static", "10.8.0.125", "255.255.192.0", "10.8.0.100", "8.8.8.8 8.8.4.4");

$interface = delinterface($interface, "plip0");


#Write interfaces to $outfile
$ENV{INTERFACES} = $outfile;
XML::Debian::ENetInterfaces::write($interface);

sub addinterface {
	my ( $interfacefile, $interface, $mode, $address, $netmask, $gateway, $dnssrv ) = @_;

	my $xmlinterface = XML::Simple::XMLin($interfacefile, ForceArray => 1, ForceContent => 1, NoAttr => 0);

	if ($xmlinterface->{iface}->{$interface}) {
		delete $xmlinterface->{iface}->{$interface} ;
	} else {
		push $xmlinterface->{auto} , { _indent => '', content => $interface };
	}

	$xmlinterface->{iface}->{$interface}->{_childindent} = '     ';
	$xmlinterface->{iface}->{$interface}->{_indent} = '';

	if ($mode)	{ $xmlinterface->{iface}->{$interface}->{opts} = "inet $mode" } 
		else { $xmlinterface->{iface}->{$interface}->{opts} = "inet manual"; }
	if ($address)	{ $xmlinterface->{iface}->{$interface}->{address} = $address; }
	if ($netmask)	{ $xmlinterface->{iface}->{$interface}->{netmask} = $netmask; }
	if ($gateway)	{ $xmlinterface->{iface}->{$interface}->{gateway} = $gateway; }
	if ($dnssrv)	{ $xmlinterface->{iface}->{$interface}->{'dns-nameservers'} = $dnssrv; }

	$xmlinterface->{iface}->{$interface}->{br} = {};

	#print Dumper($xmlinterface);

	$interface = XMLout($xmlinterface, RootName => 'etc_network_interfaces');

	return $interface;
}

sub delinterface {
	my ( $interfacefile, $interface ) = @_;

	my $counter=0;

	my $xmlinterface = XML::Simple::XMLin($interfacefile, ForceArray => 1, ForceContent => 1, NoAttr => 0);

	for ($counter=0; $counter < scalar(@{$xmlinterface->{auto}}) ; $counter++) {
		if ($xmlinterface->{auto}->[$counter]->{'content'} eq $interface) {
			delete $xmlinterface->{auto}->[$counter]
		}
	}

	#delete $xmlinterface->{auto}->[$interface];

	delete $xmlinterface->{iface}->{$interface};

	print Dumper($xmlinterface);

	$interface = XMLout($xmlinterface, RootName => 'etc_network_interfaces');

	return $interface;
}	
