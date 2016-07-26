package Users;

use strict;
use warnings;

use Mojo::Base 'Mojolicious';
use Users::Model;

sub startup {
	my $self = shift;

	$self->secrets(['BigFlyingDog']);
	$self->mode('education');
	$self->sessions->default_expiration(3600 * 24);
	$self->plugin('Users::Helpers');

	my $config = $self->plugin( 'Config' => { file => 'conf/mysql.conf' } );

	my $r = $self->routes;
	$r ->route('/')         ->via('get') ->name('auths_create')->to('auths#create_form');
        $r ->route('/login')    ->via('post')->name('auths_form')  ->to('auths#auth');
        $r ->route('/logout')   ->via('get') ->name('auths_delete')->to('auths#delete');
        $r ->route('/signup')   ->via('get') ->name('reg_form')    ->to('auths#reg_form');
        $r ->route('/signup')	->via('post')->name('reg_create')  ->to('auths#reg');
	$r ->route('/api/users')->via('get') ->name('api_list')	   ->to('show#show_list',    namespace => 'Users::Api');

	$r ->route('/api/users/:user', user => qr/([\s\S]*)/)->via('get')->name('api_list')->to('show#show_element', namespace => 'Users::Api');

	my $rn = $r->under->to('auths#check');
	$rn->route('/users')	       ->via('get') ->name('list_show')      ->to('list#show'); 
	$rn->route('/users')	       ->via('post')->name('list_search')    ->to('list#search'); 
	$rn->route('/users/add')       ->via('get') ->name('users_add')      ->to('form#add');  
	$rn->route('/users/add')       ->via('post')->name('users_add_form') ->to('form#add_user');
	$rn->route('/users/:ID/edit')  ->via('get') ->name('users_edit')     ->to('form#edit'); 
	$rn->route('/users/:ID/edit')  ->via('post')->name('users_edit_form')->to('form#edit_user');
	$rn->route('/users/:ID/remove')->via('get') ->name('users_delete')   ->to('form#delete_user');

    Users::Model->init( $config->{db}, $config->{queries} );
}

1;
