#!/usr/bin/perl -w
package Connecteo::Reseau::FonctionClientSep;
use Exporter;
use Connecteo::Reseau::SepMessage;
use Connecteo::Reseau::Fonction;

our @ISA=qw(Exporter);

our %COMMANDE=("ping"=>\&ping,"identifie"=>\&identifie);

our @EXPORT=qw(%COMMANDE);



sub ping{
	my($messageSep,$adresseIP)=@_;
	$messageSep=Connecteo::Reseau::SepMessage->new($CLIENT,$NORMAL);
	$messageSep->addParametre("str","echo");
	$messageSep->addParametre("dico","identifie=".recupereAdresseMac());
	envoieMessage($messageSep,$adresseIP);
}
sub identifie{
	my($messageSep,$adresseIP)=@_;
	$messageSep=Connecteo::Reseau::SepMessage->new($CLIENT,$NORMAL);
	$messageSep->addParametre("str","OK");
	envoieMessage($messageSep,$adresseIP);
}

1;