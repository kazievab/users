package Users::Controller::Auths;

use strict;
use warnings;
use utf8;

use base 'Mojolicious::Controller';
use Digest::MD5 qw(md5_hex);


sub auth {
    my ($self) = @_;

    my $login    = $self->param('login');
    my $password = $self->param('password');

    $password = md5_hex($password);

    my $auth = Users::Model::Auth->select({login => $login, password=>$password})->hash();

    if ( $login && $auth->{auth_id} ) {
        $self->session(
            auth_id => $auth->{auth_id},
            login   => $auth->{login}
        )->redirect_to('list_show');
    }
    else {
        $self->flash( error => 'Неправильное имя пользователя или пароль!' )->redirect_to('auths_create');
    }
}

sub reg {
    my ($self) = @_;

    my $login        = $self->param('login');
    my $password     = $self->param('password');
    my $password2    = $self->param('password2');
    my $password_md5 = md5_hex($password2);
    my $auth         = Users::Model::Auth->select( { login => $login } )->hash();

    my $validator = Mojolicious::Validator->new;
    my $validation= Mojolicious::Validator::Validation->new(validator => $validator);
    $validation->input({
        login         => $login,
        password      => $password,
        password2     => $password2,
    });
    $validation->required('login');
    $validation->required('password')  ->size(6, 50);
    $validation->required('password2') ->equal_to('password');

    if ( length($auth->{ login }) > 0 ) {
         $self->flash(
            error => 'Такой пользователь уже зарегистрирован!'
        )->redirect_to('reg_form');
         return;
    }

    unless ($validation->is_valid) {
        $self->flash(
            error => 'Неверно заполнены имя пользователя или пароль'
        )->redirect_to('reg_form');
    }

    if ($validation->is_valid) {
        Users::Model::Auth->insert({login => $login, password => $password_md5 });
        $self->flash( success => 'Регистрация прошла успешно' )->redirect_to('auths_create');
    }
}

sub delete {
    my $self = shift;
    $self->logout;
    $self->redirect_to('auths_create');
}

sub check {
    my $self = shift;
    unless ($self->logged) {
        $self->redirect_to('auths_create') and return 0;
    }
    return 1;
}

1;

