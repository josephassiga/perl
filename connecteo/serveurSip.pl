 #!/usr/bin/perl -w
 
use IO::Socket;
my $DOSSIER_PACKAGES="ressources/packages";


sub recupFichier{
	my ($nomPackage)=@_;
	return (-e "$DOSSIER_PACKAGES/$nomPackage.meo") && !(-e "$DOSSIER_PACKAGES/$nomPackage.lock");
}


my $serveur=IO::Socket::INET->new(
	Proto=>'tcp',
	LocalPort=>3615,
	Proto=>'tcp',
	Reuse=>1,
	Listen=>1) or die "erreur creation serveur";

print "socket ok\n";
my ($client,$adresseIP,$nomPackage);

while(1){
	print "en attente client\n";
	$client=$serveur->accept();
	$adresseIP=$client->peerhost();
	print "nouveau client $adresseIP\n";
	$nomPackage=<$client>;
	print "recu\n";
	$nomPackage=~/(\w+#)/;
	$nomPackage=$1;
	chop $nomPackage;
	print "package => $nomPackage\n";
	if(recupFichier $nomPackage){
		print "envoie package\n";
		open FIC,"<$DOSSIER_PACKAGES/$nomPackage.meo";binmode(FIC);
		my $f;
		while(read(FIC,$f,100)>0){
			$client->send(unpack("H*",$f)."\n");
		}
		close FIC;
	}else{
		print "package non pret\n";
	}
	close($client);
}

close($serveur);