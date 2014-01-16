#!/usr/bin/perl -w

use Connecteo::Registre;
use Connecteo::Archive;

print "****************************\n";
print "Deploiement base de registre\n";
print "****************************\n";

Connecteo::Archive::deCompresseBaseDeRegistre();
Connecteo::Registre::deserializeCleRecente();