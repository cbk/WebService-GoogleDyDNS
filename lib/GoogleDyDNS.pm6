##########################################################

unit class WebService::GoogleDyDNS {
  use WebService::HazIP;
  use HTTP::UserAgent;
  has $.currentHostPublicIP is rw;
  has $.login is rw;
  has $.password is rw;
  has $.domainName is rw;
  my $lastIPFile = $*CWD ~ "/" ~ self.domainName.lc ~ ".lastIP";
  has Bool $.outdated is rw;
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
    my $webAgent = HTTP::UserAgent.new(useragent => "Chrome/41.0");
    $webAgent.auth(self.login, self.password);
    $webAgent.timeout = 10;
    my $response = $webAgent.get("https://domains.google.com/nic/update?hostname={self.domainName}&myip={self.ip}");
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
