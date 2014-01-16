#!/usr/bin/perl -w
use strict;
use Win32::TieRegistry; 
use FileTime;
use DateTime;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use Archive::Tar;
close $dossier;
print "**************\n";

#my $zip = Archive::Zip->new();
#my $dir_memeber=$zip->addDirectory("toto");
#$zip->addFile("tmb.reg","toto.reg");
#$zip->addFile("tmb.reg","toto/titi.reg");
#unless ( $zip->writeToFileNamed('someZip.zip') == AZ_OK ) {
#       die 'write error';
#}
#my $tar=new Archive::Tar->new;
#$tar->add_files("tmb.reg");
#$tar->write('files.tgz', COMPRESS_GZIP);

# $tar = Archive::Tar->new;
# $tar->read('files.tgz');
# $tar->extract();