#########################################
## Michael D. Hensley
## December 3, 2015
##
## Simple web service used to update an IP address on domains.google.com
## if the current one has changed. Obtains current IP address using the
## WebService::HazIP module, then compares the results with the IP address
## that was set the last time the service was ran. It there was a change,
## the updateIP() method is then called to update the IP address
## using the HTTP::UserAgent module.
##
##########################################################
unit class WebService::GoogleDyDNS {
  use WebService::HazIP;
  use HTTP::UserAgent;

  has $.currentHostPublicIP is rw;
  has $.login is rw;
  has $.password is rw;
  has $.domainName is rw;
  has Bool $.outdated is rw;
  
  my $lastIPFile = $*CWD ~ "/" ~ self.domainName.lc ~ ".lastIP";

##########################################################
  method checkPreviousIP() {
    my $currentIPObj = WebService::HazIP.new;
    my $fh;
    my $previousIP;

    self.currentHostPublicIP = $currentIPObj.returnIP();

    if $lastIPFile.IO ~~ :e {
      $fh = open($lastIPFile, :r);
      $previousIP = slurp($fh);
      $fh.close;
      if $previousIP == self.currentHostPublicIP { self.outdated = False; } else { self.outdated = True; }
    } else {
      ## File does not exist, make new one
      open( $lastIPFile, :w).close
      self.outdated = True;
    }
    #if $data ~~ / ^^([\d ** 1..3] ** 4 % '.')$$ / { return $data; }
  }
##########################################################
  method updateIP() {
    # Make HTTP::UserAgent Object and set the useragent to Chrome/41.0 then set the time out
    # and then set the authorization's login and pasword.
    my $webAgent = HTTP::UserAgent.new(useragent => "Chrome/41.0");
    $webAgent.auth(self.login, self.password);
    $webAgent.timeout = 10;

    # Craft URL and make a GET response.  The get method will reachout to the URL provided on internet.
    my $response = $webAgent.get("https://domains.google.com/nic/update?hostname={self.domainName}&myip={self.ip}");
    # Handle the results of the get method.
    if $response.is-success {
      return $response.content;
      if $response.content ~~ / good / {
        my $fh = open(self.lastIPFile, :w);
        $fh.say( self.currentHostPublicIP );
        $fh.close;
      }
    } else {
      return $response.status-line;
    }
  }

}
##########################################################
