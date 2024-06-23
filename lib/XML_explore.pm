package XML_explore;

use strict;
use warnings;

use utf8;

sub new
{
	my $class = shift;
	my $self  = {};
	
	bless($self, $class);
	
	$self->_init;
	
	return $self;
}

sub _init
{
	my $self = shift;
	
	$self->{total_characters} = 0;
	$self->{without_spaces}   = 0;
	
	$self->{hash_id}   = {};
	$self->{hash_link} = {};
	
	$self->{total_links}  = 0;
	$self->{normal_links} = 0;
	$self->{broken_links} = 0;
}

sub explore_structure
{
	my $self = shift;
	my $data = shift;
	
	my $reference_name = ref($data);
	if($reference_name eq 'HASH')
	{
		$self->explore_hash($data);
	}
	elsif($reference_name eq 'ARRAY')
	{
		$self->explore_array($data);
	}
	else
	{
		$self->explore_scalar($data);
	}
}

sub explore_hash
{
	my $self = shift;
	my $data = shift;
	
	for my $item (keys %{$data})
	{
		if(ref(\$data->{$item}) eq 'SCALAR')
		{
			$self->search_identifiers($item, $data->{$item});
			$self->search_content($item, $data->{$item});	
		}
		else
		{
			$self->explore_structure($data->{$item});
		}
	}
}

sub search_identifiers
{
	my $self = shift;
	my $item = shift;	
	my $data = shift;
	
	if($item eq 'id')
	{
		$self->{hash_id}->{$data} = $data;
	}
	if($item eq 'l:href')
	{
		$data =~ s/#//;
		$self->{hash_link}->{$data} = $data;
	}
}

sub search_content
{
	my $self = shift;
	my $item = shift;	
	my $data = shift;
	
	if($item eq 'content')
	{
		$self->explore_scalar($data);
	}
}

sub explore_array
{
	my $self = shift;
	my $data = shift;
	
	for(my $i = 0; $i <= $#{$data}; $i++)
	{
		$self->explore_structure($data->[$i]);
	}
}

sub explore_scalar
{
	my $self = shift;
	my $data = shift;
	
	my $text = $data;
	$text =~ s/\s//g;
	
	$self->{total_characters} += length($data);
	$self->{without_spaces}   += length($text);
}

sub count
{
	my $self = shift;
	
	for my $item (keys %{$self->{hash_link}})
	{
		$self->{total_links}++;
		if(defined($self->{hash_id}->{$item}))
		{
			$self->{normal_links}++;
		}
		
		$self->{broken_links} = $self->{total_links} - $self->{normal_links};
	}

}

sub output
{
	my $self = shift;
	
	print "всего символов, включая содержимое тега <binary>: ", $self->{total_characters}, "\n";
	print "всего символов без пробелов: ", $self->{without_spaces}, "\n\n";
	
	print "всего внутренних ссылок: ", $self->{total_links}, "\n";
	print "из них поврежденных: ", $self->{broken_links}, "\n";
}

1;
