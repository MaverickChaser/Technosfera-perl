use Sfera::TCP::Calc::Server;

Sfera::TCP::Calc::Server->start_server(8081);

=pod
print "At your service. Waiting...\n";
my $addr;       # Client handle
while ($addr = $local->accept() ) {     # receive a request
        print   "Connected from: ", $addr->peerhost();  
    # Display messages
        print   " Port: ", $addr->peerport(), "\n";
        my $result;             # variable for Result
        while (<$addr>) {       # Read all messages from client 
                                # (Assume all valid numbers)
                last if m/^end/gi;      # if message is 'end' 
                                        # then exit loop
                print "Received: $_";   # Print received message
                print $addr $_;         # Send received message back 
                                        # to verify
                $result += $_;          # Add value to result
        }

        chomp;                  # Remove the 
        if (m/^end/gi) {        # You need this. Otherwise if 
                                # the client terminates abruptly
                                # The server will encounter an 
                                # error when it sends the result back
                                # and terminate
                my $send = "result=$result";    # Format result message
                print $addr "$send\n";          # send the result message
                print "Result: $send\n";        # Display sent message
        }

        print "Closed connection\n";    # Inform that connection 
                                        # to client is closed
        close $addr;    # close client
        print "At your service. Waiting...\n";  
# Wait again for next request
}
=cut