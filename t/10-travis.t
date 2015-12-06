use Test;
use WebService::GoogleDyDNS;

ok(1);

if (%*ENV<TRAVIS>) {
    diag "running on travis";
    my $ipObj = WebService::GoogleDyDNS.new;
}

done-testing();
