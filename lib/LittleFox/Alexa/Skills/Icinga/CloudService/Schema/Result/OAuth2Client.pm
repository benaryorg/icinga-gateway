package LittleFox::Alexa::Skills::Icinga::CloudService::Schema::Result::OAuth2Client;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components('RandomColumns');
__PACKAGE__->table('oauth2clients');

__PACKAGE__->add_columns(
    id => {
        data_type   => 'integer',
        extra       => { unsigned => 1 },
        is_random   => { max => 2**24 -1, min => 0 },
        is_nullable => 0,
    },
    name => {
        data_type   => 'varchar',
        size        => 128,
        is_nullable => 0,
    },
    description => {
        data_type   => 'text',
        is_nullable => 1,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraints(['name']);
__PACKAGE__->has_many(redirect_urls => 'LittleFox::Alexa::Skills::Icinga::CloudService::Schema::Result::OAuth2RedirectURL', 'client_id');
__PACKAGE__->has_many(tokens => 'LittleFox::Alexa::Skills::Icinga::CloudService::Schema::Result::OAuth2Token', 'client_id');

1;
