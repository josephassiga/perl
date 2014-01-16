#!/usr/bin/perl -w
use Connecteo::Fichier;
use Connecteo::Archive;
use Connecteo::Config;

my $date = DateTime->new( year=> 2013,month => 12,day => 16,hour => 9,minute =>0,second => 0,nanosecond => 0, time_zone => "floating");
 my $tableau=[];
 Connecteo::Fichier::detection("/",$date,$tableau);

 print "****\n";
 foreach(@$tableau){
	 print "$_\n";
 }

print "[ARCHIVAGE COMPRESSION]\n";#verbose
Connecteo::Archive::create $tableau,Connecteo::Config::getNumeroPackage();
Connecteo::Config::augmenteNumeroPackage();
print "[ARCHIVAGE COMPRESSION FIN]\n";#verbose

