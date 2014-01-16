#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;

if($ARGV[0] eq "c"){#client
	my $sock = IO::Socket::INET->new(
		PeerPort  => 9999, 
		PeerAddr  => inet_ntoa(INADDR_BROADCAST), 
		Proto     => 'udp', 
		LocalAddr => '0.0.0.0', 
		Broadcast => 1 ) or die "Can't bind: $@\n";
	$sock->send("toto");
	$sock->close();
}
else{#serveur
	my $socket = new IO::Socket::INET (LocalPort => 4444,
		Proto => 'udp') or die "ERROR in Socket Creation : $!\n";
	my $recieved_data;
	$socket->recv($recieved_data,10);
	my $peer_address = $socket->peerhost();
	my $peer_port = $socket->peerport();
	print "\n($peer_address , $peer_port) said : $recieved_data\n";
	$socket->close();
	my $sock = IO::Socket::INET->new(
		PeerPort  => 4444, 
		PeerAddr  => inet_ntoa(INADDR_BROADCAST), 
		Proto     => 'udp', 
		PeerAddr => $peer_address ) or die "Can't bind: $@\n";
	$sock->send("toto");
	$sock->close();
}