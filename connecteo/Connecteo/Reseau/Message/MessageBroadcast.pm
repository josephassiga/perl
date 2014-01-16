#!/usr/bin/perl -w
package Connecteo::Reseau::Message::MessageBroadcast;
use strict;
use Connecteo::Reseau::SepMessage;
use Connecteo::Reseau::Fonction;

use Exporter;

our @ISA=qw(Exporter);
our @EXPORT=qw(&envoiePing);

sub envoiePing{
	my $message=Connecteo::Reseau::SepMessage->new($SERVEUR,$BROADCAST);
	$message->addParametre("str","ping");
	envoieBroadcast($message);
}

1;