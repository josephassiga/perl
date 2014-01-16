 #!/usr/bin/perl -w
 use IO::Socket;
 use Connecteo::Config;
 sub recupFichier{
	my ($adresseIP,$nomPackage)=@_;
	$socket=IO::Socket::INET->new(
		PeerAddr=>$adresseIP,
		PeerPort=>3615,
		Proto=>'tcp');
	return 0 unless(defined($socket));
	print "socket ouverte\n";
	$socket->send("$nomPackage#\n");
	print "envoie\n";
	print "telechargement\n";
	open D,">".$Connecteo::Config::cheminRessources."/packages/$nomPackage.lock";
	close D;

	open FIC,'>:raw',$Connecteo::Config::cheminRessources."/packages/$nomPackage.meo";
	my $d=0;
	my $f;
	while($f=<$socket>){
		chop $f;
		print FIC pack("H*",$f);
		$d=1 if($d==0);
	}
	close FIC;
	close $socket;
	if($d==0){
		print "package non pret\n";
		unlink($Connecteo::Config::cheminRessources."/packages/$nomPackage.lock");
		return 0;
	}
	unlink($Connecteo::Config::cheminRessources."/packages/$nomPackage.lock");
	print "package ok\n";
	return 1;
}

recupFichier $ARGV[0],$ARGV[1];