#!/usr/bin/env perl

use utf8;
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use LittleFox::Alexa::Skills::Icinga::CloudService;

use Dancer2 appname => 'LittleFox::Alexa::Skills::Icinga::CloudService';
use Dancer2::Plugin::DBIC;

my $schema = schema;

if($schema->get_db_version < $schema->schema_first_version) {
    $schema->deploy;

    rset('User')->create(
        {
            username => 'admin',
            email    => 'admin@example.org',
        }
    )->insert->change_password('admin');
}
elsif($schema->get_db_version < $schema->schema_version) {
    $schema->upgrade;
}

LittleFox::Alexa::Skills::Icinga::CloudService->to_app;
