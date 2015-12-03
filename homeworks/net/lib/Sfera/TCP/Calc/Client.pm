package Sfera::TCP::Calc::Client;

use strict;
use IO::Socket;
use Sfera::TCP::Calc;



sub set_connect {
	my $pkg = shift;
	my $ip = shift;
	my $port = shift;
	my $server;
	$server = IO::Socket::INET->new(
                Proto   => 'tcp',       # protocol
                PeerAddr=> "$ip", 		# Address of server
                PeerPort=> "$port",     # port of server
                Reuse   => 1,
             	) or die "$!";	
	$server->autoflush(1);
	print "Connected to ", $server->peerhost, # Info message
      " on port: ", $server->peerport, "\n";
    return $server;
}

sub do_request {
	my $pkg = shift;
	my $server = shift;
	my $type = shift;
	my $expr = shift;

	my $header = Sfera::TCP::Calc->pack_header(length $type.$expr);
	my $body = Sfera::TCP::Calc->pack_body($type, $expr);
	#Sfera::TCP::Calc->pack_header
	$server->autoflush(1);
	print $server $header;
	print $server $body;

	my $raw_message;
	my $bytes_read = sysread $server, $raw_message, 4, 0;

	if ($bytes_read == 0) {
		die 'shutdown';
	}

	my $header = Sfera::TCP::Calc->unpack_header($raw_message);
	sysread $server, $raw_message, $header, 0;
	my ($type, $response) = Sfera::TCP::Calc->unpack_body($raw_message);
	return $response;
}

1;

