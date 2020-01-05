#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use XML::LibXML;
use LWP::UserAgent;
use DBI;
use POSIX;

# INITIALIZE DEBUG CONSTANT
use constant("DEBUG",		1); # 1: DEBUG OUTPUT ENABLED, 0: DISABLE DEBUG OUTPUT

# INITIALIZE SCALARS
my $importAttempts = 0;
my $maxImportAttempts = 5;
my $importSuccessFlag;
my $dbh;
my $currency;
my $rate;
my $datasetCounter;

# web-source for import
my $importUrl = 'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'; 

# MySQL database configuration
my $dsn = "DBI:mysql:database=eurofximport;host=localhost"; # this database must exist
my $dbUser = "root"; # database username
my $dbPassword = ''; # database password
my %attr = (RaiseError=>1,  # raise error enabled
			AutoCommit=>0); # transaction enabled
 
# configure UserAgent to get XML from web
my $userAgent  = LWP::UserAgent->new(
						protocols_allowed => ['https'], # allow only https
						timeout           => 10); # connection timeout




# execute the import_currencies subroutine until maximum import attempts are reached or the import was successful
while( $importAttempts < $maxImportAttempts and (!$importSuccessFlag) ){
	
	# count executions of the loop:
	$importAttempts ++;
	
	# execute subroutine
	$importSuccessFlag = import_currencies();
	if( !$importSuccessFlag ){
		say "Attempt $importAttempts to import new currencies failed.";
		if( $importAttempts != $maxImportAttempts) {
			sleep_for(60);	
		}
	};
	
};

# subroutine to pause the code and show the time
sub sleep_for{
	
	# passing argument  
	my $timer = $_[0];

	print scalar localtime(); # print current time
	say ": Retry in $timer seconds...\r"; # announce retry
	sleep($timer); # wait 'argument' seconds
};

#*****************************#
#*** SUB import_currencies ***#
#*****************************#
# subroutine to import new currencies from the Web-XML
sub import_currencies{
	
	#*************************#
	#*** GET XML FROM URL  ***#
	#*************************#
	my $response = $userAgent->get($importUrl);
	
	#*****************************#
	#*** VALIDATE XML RESPONSE ***#
	#*****************************#
	# check if xml was delivered or try again
	if ( ! $response->is_success ) {
		# error case:
		if(DEBUG()) {print "ERROR receiving Data from $importUrl (".__FILE__." Line ".__LINE__.".)\r"};
		print $response->status_line."\r"; # print response error message
		return 0;
		
	} else {
		# success case:
		if(DEBUG()) {print "Successfully received Data from $importUrl (".__FILE__." Line ".__LINE__.".)\r"};
		
		# create a new DOM with the decoded response
		my $dom = XML::LibXML->load_xml(
			string => $response->decoded_content,
			no_blanks => 1); #remove blank nodes
	 
		# save the date from the response in $importDate
		my $importDate = $dom->findnodes('//@time');
		
		#***************************#
		#*** DATABASE OPERATIONS ***#
		#***************************#
		
		# try to connect to MySQL database
		eval{		
			$dbh = DBI->connect($dsn,$dbUser,$dbPassword, \%attr);		
		};		
		
		if($@){
			# error case: NO Connection with DB
			if(DEBUG()) {print "ERROR while connecting to DB! Errormessage: \r\n$@\n"};
			return 0;
		} else {
			# success case: connected to DB
			if(DEBUG()) {print "Successfully connected with database. (".__FILE__." Line ".__LINE__.".)\r"};
			
			my $sql = "SELECT exr_date FROM currency_exchange WHERE 1 LIMIT 1"; # SELECT One Date from DB
			my $sth = $dbh->prepare($sql); # prepare statement handle object
			$sth->execute(); # execute statement
			my $dbDate = $sth->fetchrow(); #save date from db in $dbDate
			if(DEBUG()) {print "Date in database: ($dbDate). (".__FILE__." Line ".__LINE__.".)\r"};			
			# Finish statement handle
			$sth->finish();	 
			
			#****************************#
			#*** COMPARE IMPORT DATES ***#
			#****************************#
			# save todays Date in $currentDate
			my $currentDate = strftime("%Y-%m-%d", localtime);
			
			# check if Date in DB is the Date of today
			if($dbDate eq $currentDate){
				if(DEBUG()) {print "Data in database are up to date ($currentDate). (".__FILE__." Line ".__LINE__.".)\r"};
				# Disconnect from the database.
				$dbh->disconnect();
				return 1;
			
			# check if the Date in the XML-File is the same as in the DB
			}elsif( $importDate eq $dbDate ){
				# (error) case:
				if(DEBUG()) {print "No new data to import. Same Date in XML-File ($importDate) and the DB: ($dbDate). (".__FILE__." Line ".__LINE__.".)\r"};
				# Disconnect from the database.
				$dbh->disconnect();
				return 0;
			} else {
				# success case:
				if(DEBUG()) {print "Found new data, preparing import... (".__FILE__." Line ".__LINE__.".)\r"};
			    
				#*************************#
				#*** START TRANSACTION ***#
				#*************************#
				eval{				

					# delete old datasets
					$sql = "DELETE FROM currency_exchange WHERE exr_date != ?";
				
					$sth = $dbh->prepare($sql);
					$sth->execute($importDate);
													
					# foreach element with the attribute @currency from the XML-DOM
					foreach my $el ($dom->findnodes('//*[@currency]')) {
						# select the attribute @currency in the selected element
						$currency = $el->find('./@currency');
						# select the attribute @rate in the selected element
						$rate = $el->find('./@rate');
					
						# prepare SQL-Statement
						$sql = "INSERT INTO currency_exchange VALUES (?, ?, ?)";
						$sth = $dbh->prepare($sql);
						# execute SQL-Statement
						$sth->execute($currency, $rate, $importDate);
						
						# count imported currencies
						$datasetCounter++;					
					}										

					# if everything is OK, commit to the database
					$dbh->commit();
				
				}; # TRANSACTION END
				
				#****************************#
				#*** VALIDATE TRANSACTION ***#
				#****************************#
				if($@){
					#error case
					if(DEBUG()) {print "ERROR while writing to database, performing Rollback... (".__FILE__." Line ".__LINE__.".)\r"};
					$dbh->rollback();
					return 0;
					
				} else {
					#success case
					if(DEBUG()) {print "Successfully saved new currency exchange rates to database. (".__FILE__." Line ".__LINE__.".)\r"};
					# verify, that the import was successful
					$sql = "SELECT COUNT(*) FROM currency_exchange WHERE exr_date = ?";				
					$sth = $dbh->prepare($sql);
					$sth->execute($importDate);
					
					# saves number of counted datasets in $fetchedDatasets	
					my $fetchedDatasets = $sth->fetchrow();				
					# Finish statement handle
					$sth->finish();	 
					
					# verify updated Datasets
					if($datasetCounter != $fetchedDatasets){
						# error case						
						if(DEBUG()) {print "Error: Updated $fetchedDatasets datasets instead of $datasetCounter. (".__FILE__." Line ".__LINE__.".)\r"};
						return 0;
						
					} else {
						# success case	
						if(DEBUG()) {print "Updated $fetchedDatasets datasets successful. (".__FILE__." Line ".__LINE__.".)\r"};									
						# set import success flag to true
						return 1;
						
						
					} # verify updated Datasets END					

				} #*** VALIDATE TRANSACTION END ***#		 			

				
			}; #*** COMPARE IMPORT DATES END ***#				
				
			# disconnect from the MySQL database
			$dbh->disconnect();
				
		}; #*** DATABASE OPERATIONS END	

	} #*** VALIDATE XML RESPONSE END ***#
	
}; #*** SUB import_currencies END ***#


