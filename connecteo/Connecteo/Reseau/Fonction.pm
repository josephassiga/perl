#!/usr/bin/perl -w
package Connecteo::Reseau::Fonction;

use IO::Socket::INET;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(&recupereAdresseMac &envoieMessage &envoieBroadcast &envoieNormal);

sub recupereAdresseMac{
	my $commande="ipconfig /all";
	my $t=`$commande`;
	$t=~m/Ethernet(.*?)Adresse physique . . . . . . . . . . . : (\w{2})-(\w{2})-(\w{2})-(\w{2})-(\w{2})-(\w{2})/s;
	return "$2-$3-$4-$5-$6-$7\n";
}
sub envoieMessage{
	my ($sepMessage,$adresseIP)=@_;
	if($sepMessage->getBroadcast()){
		envoieBroadcast($sepMessage);
	}
	else{
		envoieNormal($sepMessage,$adresseIP);
	}
}
sub envoieBroadcast{
	my ($sepMessage)=@_;
	my $sock = IO::Socket::INET->new(
		PeerPort  => 2013, 
		PeerAddr  => inet_ntoa(INADDR_BROADCAST), 
		Proto     => 'udp', 
		
		Broadcast => 1 );# or die "Can't bind: $@\n";LocalAddr => '0.0.0.0', 
	$sock->send($sepMessage->compile()); 
	$sock->close();
}
sub envoieNormal{
	my ($sepMessage,$adresseIP)=@_;
	my $sock = IO::Socket::INET->new(
		PeerPort  => 2013, 
		PeerAddr  => $adresseIP, 
		Proto     => 'udp');# or die "Can't bind: $@\n";
	$sock->send($sepMessage->compile());
	$sock->close();
}
1;