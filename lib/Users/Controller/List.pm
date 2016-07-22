package Users::Controller::List;

use strict;
use warnings;
use utf8;

use base 'Mojolicious::Controller';

sub show {
	my $self = shift;

	my @hashes = Users::Model::User->select()->hashes();
    my $home = $self->home_dir;

	$self->render(
		$self->list_render,
		dir	 => $home,
		hashes => \@hashes,
	);
}

sub search {
	my $self = shift;

	my $search = $self->param('search');

	my @hashes;
	my $home = $self->home_dir;

	my @names  = eval { Users::Model::User->select({name =>  $search})->hashes() };
	my @emails = eval { Users::Model::User->select({email => $search})->hashes() };

	$self->search_user(\@hashes, \@names);
	$self->search_user(\@hashes, \@emails);

	my %bag = (
		$self->list_render,
		search 	=> $search,
		dir	   	=> $home,
	);

	if ( @hashes ) {
		$bag{ hashes } = \@hashes;
		$self->render(%bag);
	} else {
		$self->stash(
	    	info => 'Данных нет'
	    );
	    $bag{ hashes } = undef;
	    $self->render(%bag);
	}
}

1;