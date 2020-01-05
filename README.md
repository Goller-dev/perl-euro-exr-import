# perl-ecb-currency-exchange-import

A perl script to save the currency exchange rates from the ECB in a MYSQL-Database.

## Function

   Import of the current exchange rates of the ECB into a MySQL database.
   Resource: https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml
   The Resource gets updated on working days around 16:00 Central European Time.
   On 03.01.2020 approximately at 16:01:32, (+/- 5 seconds).

   The script runs in a loop. If the exchange rates have not yet been updated or an error occurs, it pauses for 60 seconds.
   There are a maximum of 5 attempts, so that it does not continue running indefinitely on holidays.

## Implementation

   Example with cronjob to start the script from Mo-Fr at 16:00:

   cron expression for Mo-Fr at 16:00:01: 1 0 16 ? * MON,TUE,WED,THU,FRI *

   Open crontab via terminal: crontab -e
   Add a new line with the job and file path of the script:
   # execute every MO - FR at 1 second after 16:00
   1 0 16 ? * MON,TUE,WED,THU,FRI * perl /path/to/eurofx_import.pl
   Save and close file. Check with terminal command: crontab -l

## Database structure

   The exchange rates are stored in the database "eurofximport" (utf8mb4_unicode_ci) in the table "currency_exchange".
   A backup of the database is included in "/sql/eurofximport.sql", the DB with table is needed to run the script.

   There are three columns:
   - "exr_currency" (letter abbreviation of the currency), serves as primary key.
   - "exr_rate" (exchange rate to 1,-€)
   - "exr_date" (date of last update)

   For a better overview and traceability of successful updates, each currency data record contains a separate field with the date.
   In case of a scheduled update, this information is redundant, a partial update is excluded by using a transaction in the script.

## Used CPAN modules

   The following CPAN modules are required:
   XML::LibXML for processing the XML file
   LWP::UserAgent to download the XML file
   DBI for communication with the MySQL database
   POSIX for processing the current date

## folders
"_sql" contains: a backup of the MYSQL-Database "eurofximport.sql"

"src" contains: perl script "eurofxref_import.pl"
