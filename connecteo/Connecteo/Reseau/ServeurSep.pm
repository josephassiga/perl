#!/usr/bin/perl -w
package Connecteo::Reseau::ServeurSep;

use IO::Socket::INET;
use Connecteo::Reseau::Message::MessageBroadcast;
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
	my($serveur)=@_;
	my $received_data="";
	envoiePing();
	while(1){
		$serveur->recv($received_data,512);
		my $mess=Connecteo::Reseau::SepMessage->new();
		$mess->populate($received_data);
		if($mess->getTypeExpediteur()!=$SERVEUR){
			$mess->affiche();
			traiteMessage($mess,$serveur->peerhost());
		}
	}
}
sub traiteMessage{
	my($messageSep,$adresseIP)=@_;
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