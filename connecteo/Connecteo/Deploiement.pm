#!/usr/bin/perl -w
package Connecteo::Deploiement;
use Connecteo::Fichier;
use Connecteo::Archive;
use Connecteo::Config;
use Connecteo::Registre;
use File::Copy;


sub deploieBaseDeRegistre{
	my ($nomPackage)=@_;
	print "****************************\n";
	print "deploiement base de registre\n";
	print "****************************\n";
	Connecteo::Archive::deCompresseBaseDeRegistre $nomPackage;
	unlink "$nomPackage.reo";
	Connecteo::Registre::deserializeCleRecente();
	unlink map({"$_.savereg"} @Connecteo::Registre::d);
}
sub deploieFichier{
	my ($nomPackage)=@_;
	print "*******************\n";
	print "deploiement fichier\n";
	print "*******************\n";
	$tar = Archive::Tar->new;
	$tar->read("$nomPackage.ieo");
	$tar->setcwd("/");
	$tar->extract();
	unlink "$nomPackage.ieo";
}

sub lockPackage{
	my ($nomPackage)=@_;
	open my $flock,">".$Connecteo::Config::cheminRessources."/packages/$nomPackage.lock";
	close $flock;
}

sub unlockPackage{
	my ($nomPackage)=@_;
	unlink $Connecteo::Config::cheminRessources."/packages/$nomPackage.lock";
}


sub deploie{
	my ($nomPackage)=@_;
	$tar = Archive::Tar->new;
	$tar->read($Connecteo::Config::cheminRessources."/packages/$nomPackage.meo");
	$tar->extract();
	move($Connecteo::Config::cheminRessources."/packages/$nomPackage.reo","$nomPackage.reo");
	deploieBaseDeRegistre($nomPackage);
	move($Connecteo::Config::cheminRessources."/packages/$nomPackage.ieo","$nomPackage.ieo");
	deploieFichier($nomPackage);
}



1;