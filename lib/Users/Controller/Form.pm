package Users::Controller::Form;

use strict;
use warnings;
use utf8;

use base 'Mojo::Upload';
use base 'Mojolicious::Controller';
use Digest::MD5 qw(md5_hex);
use Encode qw(encode_utf8);

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


    my ($bool, $validation) = $self->init_part_validation($password, $password2, $money, $email, $filename, $name);
    print $bool, "re\n";
    $bool &&= $validation->required('name') ->size(2, 30)                   ->is_valid;
    print $bool, "re\n";
    $bool &&= $validation->required('email')->like(qr/[^@]+@[^@\.]+\.[^@]+/)->is_valid;
    print $bool, "re\n";

    my $check_email = Users::Model::User->select( { email => $email } )->hash();

    if ( length($check_email->{ email }) > 0 ) {
         $self->flash(
            $self->form_not_valid('Такой email уже кем-то занят! Попробуйте ввести другой!', $name, $email)
        )->redirect_to('users_add');
        return;
    }

    unless ($bool) {
        $self->flash(
            $self->form_not_valid('Неверные значения!', $name, $email)
        )->redirect_to('users_add');
    }

    if ($bool) {
        my $time = $self->get_cur_date("YYYY-MM-DD hh:mm:ss");

        my %user = (
            password => $self->trim_spaces(md5_hex(encode_utf8($password))),
            email    => $self->trim_spaces($email),
            name     => $self->trim_spaces($name),
            sum      => $self->trim_spaces($money),
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

    my ($bool, $validation) = $self->init_part_validation($password, $password2, $money, $email, $filename, $name);
    $bool &&= $validation->required('name') ->size(2, 30)                   ->is_valid if length($name)  > 0;
    $bool &&= $validation->required('email')->like(qr/[^@]+@[^@\.]+\.[^@]+/)->is_valid if length($email) > 0;

    my $check_email = Users::Model::User->select( { email => $email } )->hash();

    if ( (length($check_email->{ email }) > 0) && ($check_email->{ user_id } ne $before) ) {
         $self->flash(
            $self->form_not_valid('Такой email уже кем-то занят! Попробуйте ввести другой!', $name, $email)
        )->redirect_to('users_edit');
        return;
    }

    unless ($bool) {
        $self->flash(
            $self->form_not_valid('Неверные значения!', $name, $email)
        )->redirect_to('users_edit');
    }

    if ($bool) {
        my $time = $self->get_cur_date("YYYY-MM-DD hh:mm:ss");

        my %user = ();

        $user{ password } = $self->trim_spaces(md5_hex(encode_utf8($password))) if length($password) > 0;
        $user{ email }    = $self->trim_spaces($email)                          if length($email)    > 0;
        $user{ name }     = $self->trim_spaces($name)                           if length($name)     > 0;
        $user{ sum }      = $self->trim_spaces($money)                          if length($money)    > 0;
        $user{ updated }  = $time                                               if length($time)     > 0;

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