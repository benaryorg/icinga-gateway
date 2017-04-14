package LittleFox::Alexa::Skills::Icinga::CloudService::Schema::Result::OAuth2Token;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components('RandomStringColumns');
__PACKAGE__->table('oauth2tokens');

__PACKAGE__->add_columns(
    id => {
        data_type   => 'char',
        size        => 64,
        is_nullable => 0,
    },
    description => {
        data_type   => 'varchar',
        size        => 256,
        is_nullable => 1,
    },
    client_id => {
        data_type   => 'integer',
        extra       => { unsigned => 1 },
        is_nullable => 0,
    },
    user_id => {
        data_type   => 'integer',
        extra       => { unsigned => 1 },
        is_nullable => 0,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->random_string_columns('id');
__PACKAGE__->belongs_to(user   => 'LittleFox::Alexa::Skills::Icinga::CloudService::Schema::Result::User', 'user_id');
__PACKAGE__->belongs_to(client => 'LittleFox::Alexa::Skills::Icinga::CloudService::Schema::Result::OAuth2Client', 'client_id');

1;
