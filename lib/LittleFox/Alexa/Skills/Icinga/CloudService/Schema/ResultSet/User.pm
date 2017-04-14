package LittleFox::Alexa::Skills::Icinga::CloudService::Schema::ResultSet::User;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub authenticate {
    my ($self, $username, $password) = @_;

    my ($user_object) = $self->search({ username => $username });
    return unless defined $user_object;

    if(crypt($password, $user_object->password) eq $user_object->password) {
        return $user_object;
    }

    return;
}

sub register {
    my ($self, $username, $email, $password) = @_;

    my $user_object = $self->create(
        {
            username => $username,
            email    => $email,
        },
    );

    $user_object->insert;
    $user_object->change_password($password);

    return $user_object;
}

1;
