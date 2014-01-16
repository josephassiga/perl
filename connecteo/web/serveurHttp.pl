 #!/usr/bin/perl
 
 package MyWebServer;
 use HTTP::Server::Simple::CGI;
 use base qw(HTTP::Server::Simple::CGI);
 use CGI;  # load standard CGI routines
 use Data::Dumper;
 
 #Controller
 my %dispatch = (
     '/hello' => \&resp_hello,
	 '/' => \&resp_index,
	 '/css'=>\&index_css, 	 
	 '/reseau'=>\&req_reseau, 
	 '/logiciel'=>\&req_logiciel, 
	 '/deploiement'=>\&req_deploiement, 
 );
 
 sub handle_request {
     my $self = shift;
     my $cgi  = shift;
   
     my $path = $cgi->path_info();
     my $handler = $dispatch{$path};
 
     if (ref($handler) eq "CODE")
	 {
         print "HTTP/1.0 200 OK\r\n";
         $handler->($cgi);
         
     }
	 else {
         print "HTTP/1.0 404 Not found\r\n";
         print $cgi->header,
               $cgi->start_html('Not found'),
               $cgi->h1('Not found'),
               $cgi->end_html;
     }
 }
 
 sub resp_hello {
     my $cgi  = shift;   # CGI.pm object
     return if !ref $cgi;     
     my $who = $cgi->param('name');
     
     print $cgi->header,
           $cgi->start_html("Hello"),
           $cgi->h1("Hello $who!"),
           $cgi->end_html;
 }
 
 
 sub resp_index{
 
    my $cgi  = shift;   # CGI.pm object
    return if !ref $cgi;  
 print   $cgi->header,
         $cgi->start_html(-title=>'Connecteo',-style=>{'src'=>'/css'}),
		 $cgi->div({id=>header},"<h1>Projet de Perl Connecteo</h1>","<h4>Johann Lecoq </h4>","<h4>Bertrand Mazure</h4>","<h4>Joseph Assiga</h4>"),
		 $cgi->div({id=>menu},"<h2><a href='reseau'>Reseau</a></h2>","<h2><a href='logiciel'>Logiciel</a></h2>","<h2><a href='deploiement'>Déploiement</a></h2>"),
		 $cgi->end_html;
 }
 
 sub req_reseau{
     my @machine = machineReseau();
	 my $i = 1;
     my $cgi  = shift;   # CGI.pm object
     return if !ref $cgi;     
     
     print $cgi->header,
	       $cgi->start_html(-title=>'Connecteo | Reseau',-style=>{'src'=>'/css'}),
		   $cgi->div({id=>header},"<h1>Projet de Perl Connecteo</h1>","<h4>Johann Lecoq </h4>","<h4>Bertrand Mazure</h4>","<h4>Joseph Assiga</h4>"),
		   $cgi->div({id=>menu},"<h2><a href='reseau'>Reseau</a></h2>","<h2><a href='logiciel'>Logiciel</a></h2>","<h2><a href='deploiement'>Déploiement</a></h2>"),
		   $cgi->div({id=>contenu},"<h1>Les Machines du réseau: </h1>");
		   foreach(@machine)
		   {
		     print $cgi->h1("Machine $i: $_");
			 $i++;
		   }
	print$cgi->end_html;
 }
 
 sub req_logiciel{
 
    my $k;
	my $v;
    my %logiciel = logicielInstallerParMachine();
    my $cgi  = shift;   # CGI.pm object
    return if !ref $cgi;     
     
     print $cgi->header,
	       $cgi->start_html(-title=>'Connecteo | Logiciel',-style=>{'src'=>'/css'}),
		   $cgi->div({id=>header},"<h1>Projet de Perl Connecteo</h1>","<h4>Johann Lecoq </h4>","<h4>Bertrand Mazure</h4>","<h4>Joseph Assiga</h4>"),
		   $cgi->div({id=>menu},"<h2><a href='reseau'>Reseau</a></h2>","<h2><a href='logiciel'>Logiciel</a></h2>","<h2><a href='deploiement'>Déploiement</a></h2>"),
		   $cgi->div({id=>contenu},"<h1>Les Logiciels installés sur les machines: </h1>");
		   foreach(($k,$v)= each(%logiciel))
		   {
		     print $cgi->h1("Machine $k : $v");			 
		   }       
		   
	print  $cgi->end_html;
 }
 
 sub req_deploiement{
 
      my $cgi  = shift;   # CGI.pm object
     return if !ref $cgi;     
     
     print $cgi->header,
	       $cgi->start_html(-title=>'Connecteo | Deploiement',-style=>{'src'=>'/css'}),
		   $cgi->div({id=>header},"<h1>Projet de Perl Connecteo</h1>","<h4>Johann Lecoq </h4>","<h4>Bertrand Mazure</h4>","<h4>Joseph Assiga</h4>"),
		   $cgi->div({id=>menu},"<h2><a href='reseau'>Reseau</a></h2>","<h2><a href='logiciel'>Logiciel</a></h2>","<h2><a href='deploiement'>Déploiement</a></h2>"),
		   $cgi->div({id=>contenu},"<h1>Déploiyer vos logiciels :</h1>"),
		   $cgi->start_form({-action=>"hello.pl",-method=>"post"}),
		   $cgi->filefield('uploaded_file','starting value',50,80),$cgi->p,
           $cgi->submit("Deployer"),$cgi->p,
           $cgi->end_form,
		   $cgi->hr,"\n";
		   $cgi->end_html;
 }
 
 sub index_css{
		open(FILE,"< ./Connecteo/web/style.css") or die "Impossible d'ouvrir les fichier style.css: $!";
		foreach(<FILE>)
		{
		  print "$_\n";
		}
		close(FILE);
 }
 
 sub machineReseau(){
	  my @nomRepertoire =();
	  opendir(DIR,"./Connecteo/ressources") or die "Impossible d'ouvrir le repertoire des machines $!";
	  foreach(readdir(DIR))
	  {
		 push(@nomRepertoire,$_) if(($_ ne ".") && ($_ ne ".."));
	  }
	  closedir(DIR);
	  return @nomRepertoire;
 }
 
 sub logicielInstallerParMachine(){
    my %logiciel;
	opendir(DIR,"./Connecteo/ressources") or die "Impossible d'ouvrir le repertoire des machines $!";
	foreach(readdir(DIR))
	{
	   if(($_ ne ".") && ($_ ne ".."))
	   {
	        my $ip = "$_";
			if(-d "./Connecteo/ressources/$_")
	        {
				opendir(DOC,"./Connecteo/ressources/$_") or die "Impossible d'ouvrir le dossier ./Connecteo/ressources/$_: $!";
				foreach(readdir(DOC))
				{
				    if(($_ ne ".") && ($_ ne ".."))
					{
						open(FILE,"< ./Connecteo/ressources/$ip/$_") or die "Impossible d'ouvrir le fichier ./Connecteo/ressources/$ip/$_: $!";
						my @files = ();
						foreach(<FILE>)
						{
						   push(@files,$_) if($_ ne "\n");
						}
						$logiciel{$ip}= join(":",@files);
						close(FILE);
					}
				}
				closedir(DOC);	
			}		
	   }		
	}
	closedir(DIR);
    return  %logiciel;
 }
 
 
 

 # start the server on port 8080
 my $pid = MyWebServer->new(8080)->background();
 print "Use 'kill $pid' to stop server.\n";
