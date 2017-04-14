package LittleFox::Alexa::Skills::Icinga::CloudService::Schema::Result::OAuth2RedirectURL;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components('RandomColumns');
__PACKAGE__->table('oauth2redirecturls');

__PACKAGE__->add_columns(
    id => {
        data_type   => 'integer',
        extra       => { unsigned => 1 },
        is_random   => { max => 2**24 - 1, min => 0 },
        is_nullable => 0,
    },
    url => {
        data_type   => 'varchar',
        size        => 512,
        is_nullable => 0,
    },
    client_id => {
        data_type   => 'integer',
        extra       => { unsigned => 0 },
        is_nullable => 0,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(client => 'LittleFox::Alexa::Skills::Icinga::CloudService::Schema::Result::OAuth2Client', 'client_id');

1;
