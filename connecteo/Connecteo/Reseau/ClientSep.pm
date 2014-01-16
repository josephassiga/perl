#!/usr/bin/perl -w
package Connecteo::Reseau::ClientSep;
use IO::Socket::INET;
use Connecteo::Reseau::Fonction;
use Connecteo::Reseau::SepMessage;
use Connecteo::Reseau::FonctionClientSep;
use Exporter;

our @ISA=qw(Exporter);

our @EXPORT=qw(&init &start);

sub init{
	return new IO::Socket::INET (LocalPort => 2013,
		Proto => 'udp') or die "ERROR in Socket Creation : $!\n";
}
sub start{
	my($client)=@_;
	my $dernierMessageSep='';
	my $received_data="";
	while(1){
		$client->recv($received_data,512);
		my $mess=Connecteo::Reseau::SepMessage->new();
		$mess->populate($received_data);
		$mess->affiche();
		traiteMessage($mess,$client->peerhost());
	}
}
sub traiteMessage{
	my($self,$messageSep,$adresseIP)=@_;
	my @param=$messageSep->getParametre();
	my $commande=$param[0]->[1];
	foreach(keys(%COMMANDE)){
		if($commande eq "$_"){
			my $fonction=$COMMANDE{"$_"};
			&$fonction($messageSep,$adresseIP);
		}
	}
	print "erreur\n";
}
1;