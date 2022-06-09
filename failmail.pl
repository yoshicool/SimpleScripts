#!/bin/perl

use warnings;

use POSIX;
use IO::Socket::INET;
use IO::Select;
use Switch;
use Sys::Hostname;
use DateTime;


#Auto Flush
$|++;

my $select = IO::Select->new();

#Listen for 
my $hostname = hostname();
my $localport = 2525;
my $server = new IO::Socket::INET(
	LocalHost => '0.0.0.0',
	LocalPort => $localport,
	Proto => 'tcp',
	Listen => 5,
	Reuse => 1
);

if (!$server) {
	die "Cannot listen on server $!\n";
} else {
	$select->add($server);
}

print "Waiting for new connections on port ${localport}\n";

while (1) {
	my @ready = $select->can_read(1);

	for $socket (@ready) {
		my $hangup = 0;
		my $data = "";
		my $timestamp = strftime("%H:%M:%S", localtime());
		if ( $socket eq $server) {
			$client = $server->accept();
			print "[${timestamp}] [" . $client->peerhost() . ":" . $client->peerport() . "] Accepting Connection...\n";
			$select->add($client);
			$client->write("220 Welcome to failmail on ${hostname}\n");
			next;
		}
		my $prepend = "[${timestamp}][" . $socket->peerhost() . ":" . $socket->peerport() . "]";

		$socket->recv($data, 1024);
		chomp($data);

		print "${prepend} < ${data}\n";

		switch($data) {
			#
			# 250 router.asteriasgi.com Hello that.localdomain [x.x.x.x], pleased to meet you
			# 
			case /HELO/i { $response = "250 ${hostname} Hello [" . $socket->peerhost() . "]"; }

			#
			# EHLO that.localdomain
			# 250-router.localdomain Hello that.localdomain [x.x.x.x], pleased to meet you
			# 250-8BITMIME
			# 250-ENHANCEDSTATUSCODES
			# 250-SIZE 36700160
			# 250-DSN
			# 250 HELP
			#
			case /EHLO/i { 
				$response = "250-${hostname} Hello [" . $socket->peerhost() . "]\n"; 
				$response .= "250 HELP";
			}

			case /MAIL FROM/i{
				$response = "250 2.0.0 MAIL FROM OK";	}
			case /RCPT TO/i { $response = "250 2.0.0 RCPT TO OK"; }
			case /DATA/i { $response = "452 4.5.2 No storage for data command"; }
			case /RSET/i { $response = "250 2.5.0 OK"; }

			case /QUIT/i {
				$hangup = 1;
				$response = "250 2.5.0 See Ya";
			}
			else 	{ $response = "500 5.0.2 What?"; }
		}
		@outqueue = split(/\n/,$response);
		for my $o (@outqueue) {
			print "${prepend} > ${o}\n";
			$socket->write("${o}\n");
		}

		if($hangup) {
			print "${prepend} Closing Connection\n";
			$socket->shutdown(1);
			$select->remove($socket);
			$socket->close();
		}
	}
}

