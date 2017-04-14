package LittleFox::Alexa::Skills::Icinga::CloudService::Schema::Result::Instance;

use strict;
use warnings;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components('RandomColumns');
__PACKAGE__->table('instances');

__PACKAGE__->add_columns(
    id => {
        data_type   => 'integer',
        extra       => { unsigned => 1 },
        is_random   => { max => 2**24 - 1, min => 0 },
        is_nullable => 0,
    },
    description => {
        data_type   => 'text',
        is_nullable => 1,
    },
    api_url => {
        data_type   => 'varchar',
        size        => 384,
        is_nullable => 0,
    },
    api_user => {
        data_type   => 'varchar',
        size        => 64,
        is_nullable => 0,
    },
    api_password => {
        data_type   => 'varchar',
        size        => 64,
        is_nullable => 0,
    },
    api_certificate => {
        data_type   => 'text',
        is_nullable => 1,
    },
    admin_user_id => {
        data_type   => 'integer',
        extra       => { unsigned => 1 },
        is_nullable => 0,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(admin_user => 'LittleFox::Alexa::Skills::Icinga::CloudService::Schema::Result::User', 'admin_user_id');

#TODO: Beziehungen:
# - mehrere Instanzen gehören zu mehreren Nutzern

1;
