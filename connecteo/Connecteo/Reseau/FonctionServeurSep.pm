#!/usr/bin/perl -w
package Connecteo::Reseau::FonctionServeurSep;
use Exporter;
use Connecteo::Reseau::SepMessage;
use Connecteo::Reseau::Fonction;
use Digest::MD5 qw(md5);
our @ISA=qw(Exporter);

our %COMMANDE=("echo"=>\&echo,"OK"=>\&ok);

our @EXPORT=qw(%COMMANDE);



sub echo{
	my($messageSep,$adresseIP)=@_;
	$messageSep=Connecteo::Reseau::SepMessage->new($SERVEUR,$NORMAL);
	$messageSep->addParametre("str","identifie");
	my $param=$message->getParametre();
	print "adresse mac:".$param[1]->[1]." + ".md5($param[1]->[1])."\n";
	$messageSep->addParametre("str",md5($param[1]->[1]));
	envoieMessage($messageSep,$adresseIP);
}

sub ok{
	my($messageSep,$adresseIP)=@_;
	return;
}

1;