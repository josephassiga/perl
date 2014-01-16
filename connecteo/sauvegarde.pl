#!/usr/bin/perl -w
use Connecteo::Sauvegarde;
use DateTime;
#my $date = DateTime->new( year=> 2013,month => 12,day => 19,hour => 20,minute =>0,second => 0,nanosecond => 0, time_zone => "floating");
my $date = DateTime->new( year=> $ARGV[0],month =>$ARGV[1],day =>$ARGV[2],
	hour => $ARGV[3],minute =>$ARGV[4],second => $ARGV[5],nanosecond => 0, time_zone => "floating");
Connecteo::Sauvegarde::sauvegarde($date);