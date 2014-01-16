#!/usr/bin/perl -w
use JSON;
open (FICHIER,"<donnee.json") or die "erreur fichier ouverture";
my $texte="";
$texte.=$_ while(<FICHIER>);
close FICHIER;
my $donnee=JSON->new->utf8->decode($texte);
foreach my $t (keys(%$donnee)){
	print "$t\n";
}
$h=[{"toto"=>["toto1","toto2","toto3"],
"titi"=>["titi1","titi2","titi3"]
},23];
$json_text =  JSON->new->utf8->indent->space_after->encode($h);
print $json_text;
