package Users::Api::Show;

use strict;
use warnings;
use utf8;

use base 'Mojolicious::Controller';

sub show_list {
	my $self = shift;

	$self->render(
		status => 'ok', 
		json => scalar Users::Model::User->select()->hashes
	);
}

sub show_element {
	my $self    = shift;
	my $element = $self->param('user');

	my $email = Users::Model::User->select( { email => $element} )->hash;
	my $name  = Users::Model::User->select( { name  => $element} )->hash;
	my $json;

	if ($email) {
		$json = scalar $email;
	} elsif($name) {
		$json = scalar $name;
	} else {
		$json = 'нет данных';
	}

	
	$self->render(
		status => 'ok', 
		json => $json
	);
}

1;