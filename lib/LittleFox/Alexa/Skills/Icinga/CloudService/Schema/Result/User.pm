package LittleFox::Alexa::Skills::Icinga::CloudService::Schema::Result::User;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components('RandomColumns');
__PACKAGE__->table('users');

__PACKAGE__->add_columns(
    id => {
        data_type   => 'integer',
        extra       => { unsigned => 1 },
        is_random   => { max => 2**24 - 1, min => 0 },
        is_nullable => 0,
    },
    username => {
        data_type   => 'varchar',
        size        => 64,
        is_nullable => 0,
    },
    password => {
        data_type   => 'text',
        is_nullable => 1,
    },
    email => {
        data_type   => 'varchar',
        size        => 256,
        is_nullable => 0,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraints(['username']);
__PACKAGE__->has_many(administrated_instances => 'LittleFox::Alexa::Skills::Icinga::CloudService::Schema::Result::Instance', 'admin_user_id');
__PACKAGE__->has_many(tokens => 'LittleFox::Alexa::Skills::Icinga::CloudService::Schema::Result::OAuth2Token', 'user_id');

sub verify_password {
    my ($self, $password) = @_;

    if(crypt($password, $self->password) eq $self->password) {
        return 1;
    }

    return 0;
}

sub change_password {
    my ($self, $password) = @_;

    my @saltchars  = ('a'..'z', 'A'..'Z', 0..9);
    my $saltstring = '';
    $saltstring   .= $saltchars[rand @saltchars] for (1..16);

    my $hashed_password = crypt($password, '$6$' . $saltstring . '$');
    $self->password($hashed_password);
    $self->update;
}

1;
