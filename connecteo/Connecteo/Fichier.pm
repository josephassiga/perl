#!/usr/bin/perl -w
package Connecteo::Fichier;
use DateTime;
use Archive::Tar;
use Cwd;
=head1 NAME
	Connecteo::Fichier
=cut

=head1 SYNOPSIS
	Ce module s'occupe de la gestion des fichiers
=cut

=head1 EXPORTS 
	IGNORE Dossier a ignorer
=cut
our $cheminConnecteo=cwd();
$cheminConnecteo=~s=^.+?:==i;

our @IGNORE=("/Windows",'/$Recycle.Bin','/$RECYCLE.BIN',
"/Users/ordi/Downloads",$cheminConnecteo);
our @IGNORE_REGEX=("/windows",'/\$recycle.bin',
	"/Users/(\\w+?)/AppData/Local/Microsoft/Windows/Temporary Internet Files",
	"/Users/(\\w+?)/AppData/Local/Temp"
);
our @FORCE=("/Program Files (x86)","/Program Files");
our @FORCE_REGEX=("/Users/(\\w+?)\$");
my @RACINE=();

=head1 ignoreRegex [PAS STABLE]
	retourne true si le fichier doit etre ignoré 
	
=cut
sub ignoreRegex{
	my ($fichier)=@_;
	foreach(@IGNORE_REGEX){
		if($fichier=~m=^$_=i){
			return 1;
		}
	}
	return 0;
}


=head1 dateFichier
	recupere la date d'un fichier ou dossier	
=cut


sub dateFichier{   
	my ($chemin)=@_;
	my @statDossier=stat($chemin) or die "Erreur Fichier: $chemin";		
	my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($statDossier[9]);
	$mon++;
	$year+=1900;
	return DateTime->new( year=> $year,month => $mon,day => $mday,hour => $hour,minute => $min,
	second => $sec,nanosecond => 0, time_zone => "floating");
}

=head1 detecteRacine
	detecte les dossiers de niveau 1 du systeme de fichier
=cut
sub detecteRacine{
	my $dossier;
	opendir $dossier,"/";
	my @sousDossier=();
	while(readdir($dossier)){
		if($_ ne "." && $_ ne ".." && -d "/$_"){
			push @sousDossier,$_;
		}
	}
	return @sousDossier;
}

=head1 estRecente
	Compare la date de derniere modification du fichier et celle passé en parametre
	return 1 si la date du fichier est plus recente que la date
	return 0 si la date du fichier est pareille que la date
	return 0 si la date du fichier est moins recente que la date
=cut
sub estRecente{
	my ($fichier,$date)=@_;
	my $dateFichier=dateFichier $fichier;
	return $dateFichier>$date;
}

sub rejete{
	my($dossier)=@_;
	foreach(@IGNORE){
		return 1 if($_ eq $dossier);
	}
	foreach(@IGNORE_REGEX){
		if($dossier=~m=^$_=i){
			print "\t rejet $dossier <--->$_\n";
			return 1;
		}
	}
	return 0;
}

sub force{
	my($dossier)=@_;
	foreach(@FORCE){
		return 1 if($_ eq $dossier);
	}
	foreach(@FORCE_REGEX){
		if($dossier=~m=^$_=i){
		 return 1;
		}
	}
	return 0;
}
=head1 recurssif [PAS STABLE]
	detecte les fichiers recement modifié en fonction de la date
=cut
sub detection{
	my($dossier,$date,$tableau)=@_;
	if(-d $dossier && !rejete($dossier)){
		if(dateFichier($dossier)>=$date && !force($dossier)){
			print "$dossier\n";
			push @$tableau,$dossier;
			return;
		}
		my @tab=();
		if(!opendir($d,$dossier)){
			return;
		}
		my @t=();
		@t=readdir($d) or die "erreur";
		foreach(@t){
			if($_ ne "." && $_ ne ".."){
				push @tab,$_;
			}	
		}
		close $d;
		foreach(@tab){
			my $newFile="$dossier/$_";
			$newFile="/$_" if($dossier eq "/");
			detection($newFile,$date,$tableau);
		}		
	}
}

1;
