#!perl.exe -w

use strict;
use warnings;

use XML::Simple qw(:strict);

use utf8;

use lib "./lib";

use XML_explore;

main();

sub main
{
	my $simple = XML::Simple->new(KeyAttr => 1, ForceArray => 1, KeepRoot => 1);
	my $data   = $simple->XMLin($ARGV[0]);
	
	my $xml_explore = XML_explore->new();
	
	$xml_explore->explore_structure($data);
	$xml_explore->count();
	
	print "<pre> \n";
	$xml_explore->output();
	print "</pre> \n";
}
