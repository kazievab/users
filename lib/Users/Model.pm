package Users::Model;

use strict;
use warnings;

use DBIx::Simple;
use SQL::Abstract;
use Carp qw/croak/;

use Users::Model::User;
use Users::Model::Auth;

my $DB;

sub init {
    my ($class, $config, $queries) = @_;
    croak "No dsn was passed!" unless $config && $config->{dsn};

    unless ( $DB ) {
        $DB = DBIx::Simple->connect(@$config{qw/dsn user password/},
        {
            RaiseError     => 1,
            sqlite_unicode => 1,
        } )  or die DBIx::Simple->error;

        $DB->abstract = SQL::Abstract->new(
            case          => 'lower',
            logic         => 'and',
            convert       => 'upper'
        );

        unless ( eval {$DB->select('users')} ) { 
            $class->create_db_structure($queries);
        }
    }

    return $DB;
}

sub db {
    return $DB if $DB;
    croak "You should init model first!";
}

sub create_db_structure {
    my ($class, $queries) = @_;

    $class->db->query($queries->{create_users_table});
    $class->db->query($queries->{create_auths_table});
    $class->db->query($queries->{insert_admin });
}

1;
