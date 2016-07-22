package Users::Controller::Form;

use strict;
use warnings;
use utf8;

use base 'Mojo::Upload';
use base 'Mojolicious::Controller';
use Digest::MD5 qw(md5_hex);

sub add {
	my $self = shift;
	$self->render($self->add_render);
}

sub add_user{
    my $self = shift;

    my $name      = $self->param('firstName');
    my $password  = $self->param('inputPassword');
    my $password2 = $self->param('confirmPassword');
    my $email     = $self->param('inputEmail');
    my $money     = $self->param('money');

    my $file      = $self->req->upload('image');
    my $filename  = $file->filename;

    my $validation = $self->init_part_validation($password, $password2, $money, $email, $filename);
    $validation->required('name') ->size(2, 30);
    $validation->required('email')->like(qr/^[a-z0-9.-_]+\@[a-z0-9.-]+$/i);

    unless ($validation->is_valid) {
        $self->flash($self->form_not_valid)->redirect_to('users_add');
    }

    if ($validation->is_valid) {
        my $time = $self->get_cur_date("YYYY-MM-DD hh:mm:ss");

        my %user = (
            password => md5_hex($password),
            email    => $email,
            name     => $name,
            sum      => $money,
            updated  => $time,
            created  => $time
         );

        Users::Model::User->insert(\%user);

        if (length($filename) > 0) {
            my ($ext) = $filename =~ /\.([a-z0-9]+)$/;
            my $home = $self->home_dir;

            my $last = Users::Model::User->select( { email => $email } )->hash();

            $file->move_to("$home/public/img/$last->{user_id}.$ext");
        }

        $self->flash(
            success => 'Пользователь успешно добавлен',
        )->redirect_to('list_show');
    }
}

sub edit {
	my $self = shift;
	$self->render($self->edit_render);
}

sub edit_user{
    my $self = shift;

    my $before    = $self->param('ID');
    my $name      = $self->param('firstName');
    my $password  = $self->param('inputPassword');
    my $password2 = $self->param('confirmPassword');
    my $email     = $self->param('inputEmail');
    my $money     = $self->param('money');

    my $file      = $self->req->upload('image');
    my $filename  = $file->filename;

    my $validation = $self->init_part_validation($password, $password2, $money, $email, $filename);
    $validation->required('name') ->size(2, 30)                            if length($name)  > 0;
    $validation->required('email')->like(qr/^[a-z0-9.-_]+\@[a-z0-9.-]+$/i) if length($email) > 0;
    
    unless ($validation->is_valid) {
        $self->flash($self->form_not_valid)->redirect_to('users_edit');
    }

    if ($validation->is_valid) {
        my $time = $self->get_cur_date("YYYY-MM-DD hh:mm:ss");

        my %user = ();

        $user{ password } = md5_hex($password) if length($password) > 0;
        $user{ email }    = $email             if length($email)    > 0;
        $user{ name }     = $name              if length($name)     > 0;
        $user{ sum }      = $money             if length($money)    > 0;
        $user{ updated }  = $time              if length($time)     > 0;

        my %where = (
            user_id  => $before,
        );

        Users::Model::User->update(\%user, \%where);

        if ( length($filename) > 0 ) {
            my ($ext) = $filename =~ /\.([a-z0-9]+)$/;
            my $home = $self->home_dir;

            $self->delete_img("$home/public/img/$before.$ext");

            my $after = Users::Model::User->select({user_id => $before})->hash();
            $file->move_to("$home/public/img/$after->{user_id}.$ext");
        }

        $self->flash(
            success => 'Пользователь успешно сохранен',
        )->redirect_to('list_show');
    }
}

sub delete_user {
    my $self = shift;

    my $id   = $self->param('ID');
    my $home = $self->home_dir;

    Users::Model::User->delete({
        user_id => $id
    });
    $self->delete_img("$home/public/img/$id.jpg");
    $self->delete_img("$home/public/img/$id.png");

    $self->flash(
        success  => 'Пользователь успешно удален',
    )->redirect_to('list_show');
}

1;