#!/usr/bin/perl -w
use Connecteo::Registre;
use Connecteo::Archive;

my $date = DateTime->new( year=> 2013,month => 12,day => 13,hour => 9,minute =>0,
	second => 0,nanosecond => 0, time_zone => "Europe/Paris");

print "***************************\n";
print "Saubegarde base de registre\n";
print "***************************\n";

Connecteo::Registre::serializeCleRecente $date;
Connecteo::Archive::compresseBaseDeRegistre();
#unlink map({"$_.savereg"}  @Connecteo::Registre::RACINE);
print "[SUPPRESION FICHIER TEMP]\n";

print "******************\n";
print "Sauvegarde fichier\n";
print "******************\n";
