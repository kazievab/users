package Users::Helpers;

use strict;
use warnings;
use utf8;
use base 'Mojolicious::Plugin';


sub register {
	my ($self, $app) = @_;

	$app->helper(
			logged => sub {
				return shift->session('auth_id') ? 1 : 0;
			});

	$app->helper(
			user => sub {
				return shift->session->{login};
			});

	$app->helper(
			logout => sub {
        		my $c = shift;
        		delete $c->session->{'auth_id'};
        		delete $c->session->{'login'};
    		});

	$app->helper(
			home_dir => sub {
				my $c = shift;
        		my $home = Mojo::Home->new;
        		
    			$home->detect;
    			$home =~ s/script//;
    			return $home;
    		});

	$app->helper(
			search_user => sub {
				my ($c, $hash, $arr) = @_;
        		foreach my $key (@$arr) {
					push @$hash, $key if $key->{user_id};
				}
    		});

	$app->helper(
			list_render => sub {
				my $c = shift;
        		my %list_renderer = (
			        template    => 'users/list',
					format 	    => 'html',
					list_header => 'Список пользователей',
					title 	    => 'Список пользователей',
			     );
        		return %list_renderer;
    		});

	$app->helper(
			add_render => sub {
				my $c = shift;
        		my %add_renderer = (
			        template    => 'users/form',
					format 	    => 'html',
					form_header => 'Добавить пользователя',
					title 	    => 'Добавление пользователя',
					link_form	=> 'users_add_form',
			        button      => 'Добавить',
			     );
        		return %add_renderer;
    		});

	$app->helper(
			edit_render => sub {
				my $c = shift;
        		my %edit_renderer = (
			        template    => 'users/form',
					format 	    => 'html',
					form_header => 'Редактирование пользователя',
					title 	    => 'Редактировать пользователя',
			        button      => 'Сохранить',
			     );
        		return %edit_renderer;
    		});

	$app->helper(
			get_cur_date => sub {
			    my ($c, $format) = @_;
			    my ($sec, $min, $hour, $day, $month, $year) = localtime();
			    my %hash = ("Y" => $year + 1900, "M" => $month + 1, "D" => $day, 
			                "h" => $hour, "m" => $min, "s" => $sec);

			    foreach my $key (keys %hash) {
			        my $count =()= $format =~ /[$key.]/g;
			        $format =~ s/($key*$key)/${\(sprintf("%0${count}d", $hash{$key}))}/g;
			    }
			    return $format;
			});

	$app->helper(
			delete_img => sub {
			    my ($c, $format) = @_;
			    if( -e $format ) {
			        unlink $format;
			    }
			});

	$app->helper(
			init_part_validation => sub {
			    my ($c, $password, $password2, $money, $email, $filename) = @_;

			    my $validator = Mojolicious::Validator->new;
			    my $validation= Mojolicious::Validator::Validation->new(validator => $validator);
			    $validation->input({
			            password  => $password,
			            password2 => $password2,
			            money     => $money,
			            email     => $email,
			            filename  => $filename,
			    });
			    $validation->required('money')    ->like(qr/^\d+$/)        if length($money)     > 0;
			    $validation->required('filename') ->like(qr/.[png|jpg]$/i) if length($filename)  > 0;
    			$validation->required('password') ->size(6, 50)            if length($password)  > 0;
    			$validation->required('password2')->equal_to('password')   if length($password2) > 0;
			    return $validation;
			});

	$app->helper(
			form_not_valid => sub {
			    my ($c, $name, $email) = @_;
        		my %not_valid_renderer = (
			        error      =>'Неверные значения!',
            		firstName  => $name,
            		inputEmail => $email,
			     );
        		return %not_valid_renderer;
			});
}

1;