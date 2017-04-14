package LittleFox::Alexa::Skills::Icinga::CloudService::Security;

use Dancer2 appname => 'LittleFox::Alexa::Skills::Icinga::CloudService';
use Dancer2::Plugin::Auth::Tiny;

prefix '/security';

get '' => needs login => sub {
    template 'security/index';
};

get '/password' => needs login => sub {
    template 'security/password';
};

post '/password' => needs login => sub {
};

get '/apps' => needs login => sub {
    template 'security/apps';
};

1;
