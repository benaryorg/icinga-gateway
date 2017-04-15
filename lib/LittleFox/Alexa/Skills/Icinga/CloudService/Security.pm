package LittleFox::Alexa::Skills::Icinga::CloudService::Security;

use Dancer2 appname => 'LittleFox::Alexa::Skills::Icinga::CloudService';
use Dancer2::Plugin::Auth::Tiny;
use Dancer2::Plugin::DBIC;

prefix '/security';

our $SECURITY_SUBMENU = [
    {
        name => 'Aktive Sitzungen',
        url  => '/security',
    },
    {
        name => 'Passwort',
        url  => '/security/password',
    },
];

get '' => needs login => sub {
    template 'security/index' => {
        submenu  => $SECURITY_SUBMENU,
        sessions => [rset('User')->find(session('user'))->tokens->all],
    };
};

get '/password' => needs login => sub {
    template 'security/password' => {
        submenu  => $SECURITY_SUBMENU,
    };
};

post '/password' => needs login => sub {
};

1;
