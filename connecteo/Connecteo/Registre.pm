
#!/usr/bin/perl -w
package Connecteo::Registre;
use strict;
use Win32::TieRegistry qw(:KEY_); 
#use Win32::UrlCache::FileTime;
use Connecteo::FileTime;
use DateTime;
use JSON;

=head1 NAME
	Connecteo::Registre
=cut

=head1 SYNOPSIS
	Ce module s'occupe de l'acces et de l'ecriture de la base de registre
=cut
=head1 EXPORTS 
	RACINE Tableau qui contient les racines principales de l'arbre de registre
=cut
our @d=qw(HKEY_CLASSES_ROOT HKEY_CURRENT_USER HKEY_LOCAL_MACHINE HKEY_USERS HKEY_CURRENT_CONFIG);
our @RACINE=qw(HKEY_CLASSES_ROOT HKEY_CURRENT_USER HKEY_LOCAL_MACHINE HKEY_USERS HKEY_CURRENT_CONFIG);
our %TYPE=(BI=>"REG_BINARY",SZ=>"REG_SZ",DW=>"REG_DWORD",MU=>"REG_MULTI_SZ",NO=>"REG_NONE");
=head1 FUNCTION estRecente
	Renvoie vrai si l'element est contenu dans le tableau @RACINE
	Cela permet d'eviter de sauvegarder une branche principal comme un bourrin
=cut

=head1 FUNCTION estRecente

	Renvoie vrai si l'element est contenu dans le tableau @RACINE
	Cela permet d'eviter de sauvegarder une branche principal comme un bourrin
	
=cut

sub estRacine{
	my($element)=@_;
	foreach (@RACINE){
		if($_ eq $element){
			return 1;
		}
	}
	return 0;
}


=head1 FUNCTION estRecente

	Compare la date de derniere modification et celle passé en parametre
	return 1 si la date de la cle est plus recente que la date
	return 0 si la date de la cle est pareille que la date
	return 0 si la date de la cle est moins recente que la date
	
=cut

sub estRecente{
	my ($cle,$date)=@_;
	my %info=$cle->Information;
	my $infoLastModified=filetime($info{"LastWrite"});
	$infoLastModified=~m/(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d+)/;#2013-11-09 22:19:41
	#date =>http://datetime.mongueurs.net/Perl/faq.html#1_Generalites_sur_la_FAQ
	my $dt1 = DateTime->new( year=> $1,month => $2,day => $3,hour => $4,minute => $5,
	second => $6,nanosecond => 0, time_zone => "Europe/Paris");
	return $dt1>$date;
}

=head1 FUNCTION ajoute

	ajoute le nom et le contenu et le type de la valeur dans le dictionnaire qui represente une cle
	
=cut
sub ajoute{
	my($dico,$type,$name,$value)=@_;
	if($type==Win32::TieRegistry::REG_BINARY()){
		$type="BI";
	}
	elsif($type==Win32::TieRegistry::REG_SZ()){
		$type="SZ";
	}
	elsif($type==Win32::TieRegistry::REG_DWORD()){
		$type="DW";
	}
	elsif($type==Win32::TieRegistry::REG_MULTI_SZ()){
		$type="MU";
	}
	elsif($type==Win32::TieRegistry::REG_NONE()){
		$type="NO";
	}
	if(exists($dico->{$type})){
		$dico->{$type}->{$name}=$value;
	}else{
		$dico->{$type}={};
		$dico->{$type}->{$name}=$value;
	}
}

=head1 FUNCTION ajoute

	prend une cle(+ sons chemin absolue),parcourt ses valeurs et les sauvegardes dans un dictionnaire.
	Puis parcourt ses filles et leurs valeurs ....
	Ce dictionnaire sera une sauvegarde de cette cle,il servira a sa serialisation dans une fichier
	
=cut

sub enregistreCle{
	my($nomCle,$chemin,$dico)=@_;
	my $cle= $Registry->Open( $chemin, {Delimiter=>"/"});

	if(!defined($cle)){return 0;}
	$cle->DWordsToHex(1);
	$dico->{"nom"}=$nomCle;
	$dico->{"value"}={};
	$dico->{"cle"}=[];
	foreach my $nomValeur ( $cle->ValueNames ) {
		my ($data,$type)=$cle->GetValue($nomValeur);#ici prob sur mon ordi j'ai des caracteres chinois et ca merde
		if(!defined($type)){
			#print "undef{$chemin}=> $nomValeur\n";
			next;
		}
		if($type== Win32::TieRegistry::REG_BINARY()){
			$data=unpack("H*",$data);
		}
		ajoute $dico->{"value"},$type,$nomValeur,$data;
	}
	# foreach my $nomSousCle ( $cle->SubKeyNames ) {
		# my $new={};
		# push $dico->{"cle"},$new;
		# enregistreCle($nomSousCle,"$chemin/$nomSousCle",$new);
	# }
	$cle=undef;
	return 1;
}
=head1 FUNCTION serializeCleRecente

	Parcourt la base de registre et enregistre dans $tab les cles qui ont ete modifie apres la date passe en parametre
	Des qu'une cle est plus recente que la date alors celle ci ansi que ses descendant seront suvegardée 
	
=cut
sub cleRecenteChaineRecurssif{
	my($nomCle,$date,$tab)=@_;
	my $cle=$Registry->Open( $nomCle, {Delimiter=>"/"});
	if(!defined($cle)){return;}
	if(!estRacine($nomCle) && estRecente($cle,$date)){
		print "\t$nomCle\n";#verbose
		push @$tab,$nomCle;
	}
	foreach my $nomSousCle ( $cle->SubKeyNames ) {
		cleRecenteChaineRecurssif($nomCle."/".$nomSousCle,$date,$tab);
	}
}
=head1 FUNCTION cleRecenteChaine

	Initialise le parcourt de la base de registre 
	
=cut
sub cleRecenteChaine{
	my($date)=@_;
	my $dico={};
	foreach(@RACINE){
		print "[EXPLORE] $_\n";#verbose
		$dico->{$_}=[];
		cleRecenteChaineRecurssif $_,$date,$dico->{$_};
	}
	return $dico;
}

=head1 FUNCTION serializeCleRecente

	serialise les cles de la base de registre modifie apres la date passé en parametre
	Si une deuxieme valeur est ajouté alors le mode debug est activé(indente le fichier json(prend plus de place))
	les fichiers *.savereg peuvent peser tres lourd >45 Mo
	Cette fonction va creer les fichiers:
	HKEY_CLASSES_ROOT.savereg
	HKEY_CURRENT_USER.savereg
	HKEY_LOCAL_MACHINE.savereg
	HKEY_USERS.savereg
	HKEY_CURRENT_CONFIG.savereg
	clé code en utf8
	
=cut
sub serializeCleRecente{
	my($date,$debug)=@_;
	my ($cheminCle,$dico)=({},undef);

	print "[SCAN] des chemins de cles a sauvegarder\n";#verbose
	$cheminCle=cleRecenteChaine $date;
	foreach my $key (keys(%$cheminCle)){
		print "$key\n";
		foreach(@{$cheminCle->{$key}}){
			print "\t$_\n";
		}
	}
	my ($json_text,$FICHIER)=("","");
	print "[SCAN FIN] des chemins de cles a sauvegarder\n";#verbose
	foreach(keys(%$cheminCle)){
		my $tab=[];
		print "[SAUVEGARDE] $_\n";#verbose
		foreach my $cle(@{$cheminCle->{$_}}){
			my $d={};
			enregistreCle(enleveRacinePrincipale($cle),$cle,$d);
			push @$tab,$d;
		}
		print "[SAUVEGARDE FIN] $_\n";#verbose
		
		open my $FICHIER,">$_.savereg";
		if(!$FICHIER){
			return 0;
		}
		if(defined($debug)){
			$json_text=  JSON->new->utf8->indent->space_after->encode($tab);
		}
		else{
			$json_text=  JSON->new->utf8->encode($tab);
		}
		print "[ECRITURE]$_.savereg\n";#verbose
		print $FICHIER $json_text;
		close $FICHIER;
		print "[ECRITURE FIN]\n";#verbose
	}
	return 1;
}
sub enleveRacinePrincipale{
	my ($cle)=@_;
	foreach(@RACINE){
		$cle=~s=^$_/==;
	}
	return $cle;
}
sub ajouteCle{
	my($cle,$dico)=@_;
	my $cleFille=[];
	my $cleTemp;
	print "cle ".$dico->{"nom"}. "\n";
	my @path=split "/",$dico->{"nom"};
	print "***".join(" ",@path)."\n";
	my $value=$dico->{"value"};
	$cleFille=$dico->{"cle"};
	foreach(my $i=0;$i<@path;$i++){
		print "***".$path[$i]."\n";
		$cleTemp= $cle->Open( $path[$i], {Access=>KEY_READ(),Delimiter=>"/"});
		if(!defined($cleTemp)){
			print "creation ".$path[$i]."\n";
			print "ouverture ".$path[$i]."\n";
			$cle->CreateKey($path[$i]);
			$cleTemp=$cle->Open($path[$i],{Access=>KEY_READ(),Delimiter=>"/"});
			if(!defined($cleTemp)){
				return;
			}
			else{
				$cle=$cleTemp;
			}
		}else{
			print "ouverture ".$path[$i]."\n";
			$cle=$cleTemp;
		}
	}
	foreach my $t (keys(%$value)){
		while(my($nom,$val)=each($value->{$t})){
			print "valeur $nom=>$val\n";
			if($_ eq "BI"){
				$val=pack("H*",$val);
			}
			$cle->SetValue($nom,$val,$TYPE{$t});
		}
	}
	foreach(@$cleFille){
		ajouteCle($cle,$_);
	}
	$cle=undef;
}

sub deserializeCleRecente{
	#open FICHIER,"<test/doc.savereg" or die "erreur ouverture";
	foreach(@RACINE){
		my $rac=$_;
		open FICHIER,"<$rac.savereg" or die "erreur ouverture";
		my $texte="";
		$texte.=$_ while(<FICHIER>);
		close FICHIER;
		my $donnee=JSON->new->utf8->decode($texte);
		my $cle=$Registry->Open("$rac",{Delimiter=>"/"});
		foreach(@$donnee){
			ajouteCle $cle,$_;
		}
	}
}
1;
