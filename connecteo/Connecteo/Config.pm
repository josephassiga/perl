#!/usr/bin/perl -w
package Connecteo::Config;

our $cheminRessources="ressources";

my $fichierNumeroPackage="package.num";
my $fichierConfig="connecteo.config";

sub createFilePackage{
	if(! -e "$cheminRessources/connecteo.config"){
		my $file;
		if(!open($file,"$cheminRessources/connecteo.config")){
			return 0;
		}
		my $json_text=  JSON->new->utf8->indent->space_after->encode({});
		print $file $json_text;
		close $file;
	}
	return 1;
}
sub createNumeroPackage{
	if(! -e $cheminNumeroPackage){
		my $file;
		if(!open($file,"$cheminRessources/$fichierNumeroPackage")){
			return 0;
		}
		print $file "0";
		close $file;
		return 1;
	}
	return 1;
}

sub getNumeroPackage{
	my $file;
	if(!open($file,"$cheminRessources/$fichierNumeroPackage")){
		return -1;
	}
	my $d=<$file>;
	close $file;
	return $d;
}
sub augmenteNumeroPackage{
	$getNumeroPackage= getNumeroPackage();
	if($getNumeroPackage==-1){
		return 0;
	}
	if(!open($file,">$cheminRessources/$fichierNumeroPackage")){
		return 0;
	}
	print $file "".$getNumeroPackage+1;
	close $file;
	return 1;
}