#!/usr/bin/perl -w

my $pid=fork();
	die "fork() failed: $!" unless defined $pid;

if ($pid) {
	print  "je suis parent $pid\n";
	$pid=fork();
		die "fork() failed: $!" unless defined $pid;
	if ($pid) {
		print  "je meurs en paix $pid\n";
	}
	else {
		print "je vais executer serveur sip $pid\n";
		exec "perl serveurSip.pl";
		print "serveur sip ok\n";
	}
}
else {
	
	print "je vais executer serveur http $pid\n";
	exec "perl web/serveurHttp.pl";
	print "serveur http ok\n";
}