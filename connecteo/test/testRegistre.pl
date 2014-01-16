#!/usr/bin/perl -w
use strict;
use Win32::TieRegistry;
use DateTime;
use Connecteo::FileTime;
use Connecteo::Registre;
my $date = DateTime->new( year=> 2013,month => 12,day => 10,hour => 14,minute =>2,
	second => 0,nanosecond => 0, time_zone => "Europe/Paris");
	
my $clePrincipale= $Registry->Open( "HKEY_CLASSES_ROOT/", {Delimiter=>"/"} )or  die " aie 1 $^E\n";
my $sousCle= $clePrincipale->Open( ".3gpp" )or  die "aie 2 $^E\n";
my %info=$sousCle->Information;
print filetime($info{LastWrite })."\n";
my $info=$info{"CntSubKeys"};
if($info>0){
	print "encore $info sous clés \n";
}
#ValueName=>valeur
# SubKeyNames=>sous cles
foreach my $cle ( $sousCle->ValueNames ) {
	my ($data,$type)=$sousCle->GetValue($cle);
	print ">$cle>";
	if($type == Win32::TieRegistry::REG_SZ()){
		print "\tREG_SZ";
	}
	print "\t$data\n";
}
foreach my $cle ( $sousCle->SubKeyNames ) {
		print "-$cle-";
	}
print "\n"x2;
if( Connecteo::Registre::estRecente($sousCle,$date)){
	print "recente\n";
}
else{
	print "pas recente\n";
}