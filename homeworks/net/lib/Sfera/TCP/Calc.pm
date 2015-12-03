package Sfera::TCP::Calc;

use strict;

use Exporter 'import';
our @ISA = qw(Exporter);
our $VERSION = '1.00';
our @EXPORT_OK = qw(TYPE_CALC TYPE_NOTATION TYPE_BRACKETCHECK);

sub TYPE_CALC         {1}
sub TYPE_NOTATION     {3}
sub TYPE_BRACKETCHECK {2}

sub pack_header {
	my $pkg = shift;
	my $size = shift;
	return pack("L", $size);
}

sub pack_body {
	my $pkg = shift;
	my ($type, $body) = @_;
	return pack("c a*", $type, $body);
}

sub unpack_header {
	my $pkg = shift;
	my $message = shift;
	return unpack("L", $message);
}

sub unpack_body {
	my $pkg = shift;
	my $message = shift;
	return unpack("c a*", $message);
}

1;
