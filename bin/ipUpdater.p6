#########################################
## Michael D. Hensley
## December 5, 2015
##
## Client program to check if domain IP address is out of date
## and update if it is.
##
##########################################################
use v6;
use WebService::GoogleDyDNS;

##########################################################
multi sub MAIN( :$domain, :$login, :$password ) {

  my $updater = WebService::GoogleDyDNS.new(domainName => $domain, login => $login , password => $password );
  $updater.checkPreviousIP();
  if $updater.outdated { say $updater.updateIP(); } else { say "No change. No action taken."; }
}
