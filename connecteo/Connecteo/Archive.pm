#!/usr/bin/perl -w
package Connecteo::Archive;
use Archive::Tar;
use Connecteo::Registre;
use Connecteo::Archive;
use Connecteo::Config;
=head1 NAME

	Connecteo::Archive

=cut

=head1 SYNOPSIS

	Ce module s'occupera de la gestion des archives(tar.gz) :
	decompression compression,...
	
=cut

=head1 FUNCTION compresseBaseDeRegistre

	Cette fonction recupere tous les fichiers {racine de base de registre}.savereg dans le dossier courant.
	Puis creer une archive avec ceux si.
	
	ex: compresseBaseDeRegistre();
=cut
sub compresseBaseDeRegistre{
	my($nomPackage)=@_;
	my $tar=new Archive::Tar->new;
	print "[ARCHIVAGE COMPRESSION]\n";#verbose
	my @d=();
	foreach(@Connecteo::Registre::RACINE){
		push @d,$_;
	}
	$tar->add_files(map({"$_.savereg"}  @d));
	$tar->write($Connecteo::Config::cheminRessources."/packages/$nomPackage.reo", COMPRESS_GZIP);
	print "[ARCHIVAGE COMPRESSION FIN]\n";#verbose
}
sub deCompresseBaseDeRegistre{
	my($nomPackage)=@_;
	my $tar=new Archive::Tar->new;
	print "[DESARCHIVAGE DECOMPRESSION]\n";#verbose
	$tar->read("$nomPackage.reo");
	$tar->extract();
	print "[DESARCHIVAGE DECOMPRESSION FIN]\n";#verbose
}

sub create{
	my($dossier,$nomPackage)=@_;
	my $archive=new Archive::Tar->new;
	print "[AJOUT TAR]\n";
	foreach(@$dossier){
		#next if(Connecteo::Fichier::ignoreRegex($_));
		ajoute($archive,$_);
	}
	print "[ECRITURE TAR]\n";
	$archive->write($Connecteo::Config::cheminRessources."/packages/$nomPackage.ieo", COMPRESS_GZIP);
	print "[FIN TAR]\n";
}
sub ajoute{
	my ($archive,$chemin)=@_;
	if(-d $chemin){
		if(!opendir($d,$chemin)){
			return;
		}
		my @t=();
		@t=readdir($d);
		close $d;
		foreach(@t){
			if($_ ne "." && $_ ne ".."){
				ajoute($archive,"$chemin/$_");
			}
		}
	}
	else{
		$archive->add_files($chemin);
		print "$chemin\n";
	}
}
1;
