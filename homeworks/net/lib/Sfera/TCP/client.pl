use IO::Socket;
use Sfera::TCP::Calc::Client;
use Sfera::TCP::Calc qw(TYPE_CALC TYPE_NOTATION TYPE_BRACKETCHECK);

my $server = Sfera::TCP::Calc::Client->set_connect('localhost', 8081);
my $response = Sfera::TCP::Calc::Client->do_request($server, TYPE_BRACKETCHECK, "-1+-2+-3");
print "response: ", $response, "\n";
my $response = Sfera::TCP::Calc::Client->do_request($server, TYPE_CALC, "((1+2))");
print "response: ", $response, "\n";
$response = Sfera::TCP::Calc::Client->do_request($server, TYPE_NOTATION, "((1+2))");
print "response: ", $response, "\n";

