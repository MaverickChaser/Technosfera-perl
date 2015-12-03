package Sfera::TCP::Calc::Server;

use strict;
use IO::Socket;
use Socket qw(getnameinfo);
use Sfera::TCP::Calc qw(TYPE_CALC TYPE_NOTATION TYPE_BRACKETCHECK);
use Sfera::TCP::MagicCalc qw(convert_to_polish evaluate_expr check_brackets get_lexems);
use DDP;

use POSIX qw( WNOHANG );
use IPC::SharedMem;
use IPC::Shareable;

my @children;
my $proccessed_queries = 0;

sub USR1_HANDLER {
	printf "Active clients: %d; Processed queries: %d\n", @children, $proccessed_queries;
}

sub wait_children {
	my @n_children = ();
	foreach (@children) {
		my $status = waitpid($_, WNOHANG);
		if ($status <= 0) {
			push @n_children, $_;
		}
	};
	@children = @n_children;
}

sub CHILD_HANDLER {
	wait_children();
}

sub INT_HANDLER {
	wait_children();
	exit; 
}	

sub start_server {
	my $pkg = shift;
	my $port = shift;
	my $server = 	IO::Socket::INET->new(
					Proto     => 'tcp',             # protocol
					LocalAddr => "localhost:$port",  
					Reuse     => 1,
					Listen 	  => 1,
    ) or die "$!";
	$server->autoflush(1);

	$SIG{USR1} = \&USR1_HANDLER;
	$SIG{INT}  = \&INT_HANDLER;
	$SIG{CHLD} = \&CHILD_HANDLER;

	my $glue = 'data';
    my %options = (
        'create' => 'yes',
        'exclusive' => 'no',
        'mode' => 0644,
        'destroy' => 'yes',
    );

  	{
    	no strict;
		tie($proccessed_queries, IPC::Shareable, $glue, { %options }) or die "tie failed\n";
	}

	while () {
		my $client = $server->accept();

		if (defined $client) {
			if (@children == 5) {
				shutdown $client, 2;
				close $client;	
				next;
			}	

		 	my $child = fork();
			if ($child) {
				close ($client);
				push @children, $child;
				print "PID $child\n";
				next;
			}
			if (defined $child){
				close($server);
				$SIG{USR1} = 'IGNORE';
				my $other = getpeername($client);
				my ($err, $host, $service) = getnameinfo($other);
				print "Client $host:$service $/";
				$client->autoflush(1);

				my $raw_message;

				while (1) {
					$client->recv($raw_message, 4);
					last if $raw_message eq "";
					my $header = Sfera::TCP::Calc->unpack_header($raw_message);
					$client->recv($raw_message, $header);
					my ($type, $expr) = Sfera::TCP::Calc->unpack_body($raw_message);
					my $response;

					print 'received: ', $header, ' ', $expr, "\n";
					if ($type == TYPE_CALC) {
						$response = evaluate_expr($expr);
					} elsif ($type == TYPE_NOTATION) {
						$response = join ' ', convert_to_polish(get_lexems($expr));
					} elsif ($type == TYPE_BRACKETCHECK) {
						$response = check_brackets($expr);
					} else {
						$response = "Unknown type";
					}

					$raw_message = Sfera::TCP::Calc->pack_header(length $type.$response);
					print $client $raw_message;
					$raw_message = Sfera::TCP::Calc->pack_body($type, $response);
					print $client $raw_message;

					$proccessed_queries++;
				}
				close $client;
				exit 0;
			} else { die "Can't fork: $!"; }
		} 
	}
	wait_children(); 
	return 0;
}

1;

