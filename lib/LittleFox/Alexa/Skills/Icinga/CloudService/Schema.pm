package LittleFox::Alexa::Skills::Icinga::CloudService::Schema;

use strict;
use warnings;
use parent 'DBIx::Class::Schema';

__PACKAGE__->load_components('Schema::Versioned::Inline');

our $FIRST_VERSION = 1;
our $VERSION       = 1;

__PACKAGE__->load_namespaces;

1;
