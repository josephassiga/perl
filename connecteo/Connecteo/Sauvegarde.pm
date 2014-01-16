#!/usr/bin/perl -w
package Connecteo::Sauvegarde;
use Connecteo::Fichier;
use Connecteo::Archive;
use Connecteo::Config;
use Connecteo::Registre;



sub sauvegardeBaseDeRegistre{
	my ($date,$numero)=@_;
	print "***************************\n";
	print "Saubegarde base de registre\n";
	print "***************************\n";
	Connecteo::Registre::serializeCleRecente $date;
	Connecteo::Archive::compresseBaseDeRegistre($numero);
	unlink map({"$_.savereg"}  @Connecteo::Registre::RACINE);
	print "[SUPPRESION FICHIER TEMP]\n";

}
sub sauvegardeFichier{
	my ($date,$numero)=@_;
	print "******************\n";
	print "Sauvegarde fichier\n";
	print "******************\n";
	my $tableau=[];
	Connecteo::Fichier::detection("/",$date,$tableau);
	print "[ARCHIVAGE COMPRESSION]\n";#verbose
	Connecteo::Archive::create $tableau,$numero;
	print "[ARCHIVAGE COMPRESSION FIN]\n";#verbose
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


sub sauvegarde{
	my ($date)=@_;
	my $num=Connecteo::Config::getNumeroPackage();
	lockPackage($num);
	sauvegardeBaseDeRegistre($date,$num);
	sauvegardeFichier($date,$num);
	my $tar=new Archive::Tar->new;
	$tar->add_files($Connecteo::Config::cheminRessources."/packages/$num.ieo",
		$Connecteo::Config::cheminRessources."/packages/$num.reo");
	$tar->write($Connecteo::Config::cheminRessources."/packages/$num.meo");
	unlink $Connecteo::Config::cheminRessources."/packages/$num.ieo";
	unlink $Connecteo::Config::cheminRessources."/packages/$num.reo";
	unlockPackage($num);
	Connecteo::Config::augmenteNumeroPackage();
}



1;