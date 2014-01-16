#!/usr/bin/perl -w
package Connecteo::Reseau::SepMessage;
use strict;
use Exporter;

our @ISA=qw(Exporter);
our %TYPE=("fin"=>0,"dico"=>1,"str"=>2,"nbre"=>3);
our %TYPEINV=(0=>"fin",1=>"dico",2=>"str",3=>"nbre");
our $SERVEUR=1;
our $CLIENT=0;
our $BROADCAST=1;
our $NORMAL=0;
our @EXPORT=qw($SERVEUR $CLIENT $BROADCAST $NORMAL);

sub new{
	my($class,$serveur,$broadcast)=@_;
	my $self={};
	bless($self,$class);
	$self->{TYPE}=$serveur || 0;
	$self->{BROADCAST}=$broadcast || 0;
	$self->{PARAMETRE}=[];
	$self->{IDMESSAGE}=0;
	$self->{IDDISCUSSION}=0;
	$self->{BODY}="";
	return $self;
}
sub addParametre{
	my($self,$type,$value)=@_;
	my $t=[$type,$value];
	my $o=$self->{PARAMETRE};
	push @$o,$t;
}
sub setBody{
	my($self,$body)=@_;
	$self->{BODY}=$body;
}
sub affiche{
	my ($self)=@_;
	if($self->{TYPE}){ print "*** serveur ";}
	else { print "*** client ";}
	if($self->{BROADCAST}){ print " bc(1) ";}
	else { print " bc(0) ";}
	print "*** ".$self->{IDMESSAGE}." *** ".$self->{IDDISCUSSION}."\n";
	
	my $o=$self->{PARAMETRE};
	foreach(@$o){
		print $_->[0]."=>".$_->[1]."\n";
	}
	print "~~\n".$self->{BODY}."\n";
	print "******\n";
}
sub compile{
	my ($self)=@_;
	my $messCompile="";
	my $temp=pack "C*",(128*$self->{TYPE} |  64*$self->{BROADCAST});
	$messCompile=$temp;
	$messCompile.=pack "C*",($self->{IDDISCUSSION} & 0xFF00)>>7;
	$messCompile.=pack "C*",($self->{IDDISCUSSION} & 0x00FF);
	$messCompile.=pack "C*",($self->{IDMESSAGE} & 0xFF00)>>7;
	$messCompile.=pack "C*",($self->{IDMESSAGE} & 0x00FF);
	$messCompile.=$self->compileParametre();
	$messCompile.=pack "C*",(length($self->{BODY}) & 0xFF00)>>7;
	$messCompile.=pack "C*",(length($self->{BODY}) & 0x00FF);
	$messCompile.=$self->{BODY};
	return $messCompile;
}
sub populate{
	my($self,$messageCompile)=@_;
	my $i=0;
	my $carac=unpack("C*",substr($messageCompile,$i++,1));
	my $carac2;
	my $type=($carac & 128)>>7;
	$self->{TYPE}=$type;
	$self->{BROADCAST}=($carac & 64)>>6;
	($carac,$carac2)=(unpack("C*",substr($messageCompile,$i++,1)),unpack("C*",substr($messageCompile,$i++,1)));
	$self->{IDDISCUSSION}=($carac<<7) & 0xFF00 | $carac2 & 0x00FF;
	($carac,$carac2)=(unpack("C*",substr($messageCompile,$i++,1)),unpack("C*",substr($messageCompile,$i++,1)));
	$self->{IDMESSAGE}=($carac<<7) & 0xFF00 | $carac2 & 0x00FF;
	$i=$self->populateParametre($messageCompile,$i);
	($carac,$carac2)=(unpack("C*",substr($messageCompile,$i++,1)),unpack("C*",substr($messageCompile,$i++,1)));
	my $temp=($carac<<7) & 0xFF00 | $carac2 & 0x00FF;
	$self->{BODY}=substr $messageCompile,$i++,$temp;
}
sub compileParametre{
	my($self)=@_;
	my ($mess,$temp)=("",0);
	foreach(@{$self->{PARAMETRE}}){
		$temp=($TYPE{$_->[0]}<<6) | (length("".$_->[1]) & 63);
		#print "$temp ".$_->[1]."\n";
		$mess.=pack "C*",$temp;
		$mess.=$_->[1];
	}
	$mess.=pack "C*",0;
	return $mess;
}
sub populateParametre{
	my($self,$messageCompile,$i)=@_;
	my $carac=unpack "C*",substr($messageCompile,$i++,1);
	my ($type,$valeur,$taille)=("","","");
	while($carac!=0){
		$type=$TYPEINV{($carac>>6) & 3};
		$taille=$carac & 63;
		$valeur=substr($messageCompile,$i,$taille);
		$i+=$taille;
		my $o=$self->{PARAMETRE};
		push @$o,[$type,$valeur];
		$carac=unpack "C*",substr($messageCompile,$i++,1);
	}
	return $i;
}
sub getBroadcast{
	my($self)=@_;
	return $self->{BROADCAST};
}
sub getParametre{
	my($self)=@_;
	return @{$self->{PARAMETRE}};
}
sub getTypeExpediteur{
	my($self)=@_;
	return $self->{TYPE};
}
1;