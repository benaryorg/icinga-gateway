package LittleFox::Alexa::Skills::Icinga::CloudService::OAuth2;

use Dancer2 appname => 'LittleFox::Alexa::Skills::Icinga::CloudService';
use Dancer2::Plugin::Auth::Tiny;
use Dancer2::Plugin::DBIC;
use DateTime;
use URI::Encode 'uri_encode';

prefix '/auth';

get '' => needs login => sub {
    my $client      = params->{client_id} ? rset('OAuth2Client')->find(params->{client_id}) : undef;
    my $description = $client->name . ' - ' . DateTime->now->strftime('%Y-%m-%d %H:%M');

    template 'auth/grant' => {
        state         => params->{state},
        client        => $client,
        client_id     => params->{client_id},
        response_type => params->{response_type},
        scope         => params->{scope},
        redirect_uri  => params->{redirect_uri},
        description   => $description,
    };
};

post '' => needs login => sub {
    my $client       = params->{client_id} ? rset('OAuth2Client')->find(params->{client_id}) : undef;
    my $redirect_url = params->{redirect_uri};

    my $token = rset('OAuth2Token')->new(
        {
            description => params->{description},
            user_id     => session('user'),
            client_id   => $client->id,
        },
    )->insert;

    $redirect_url .= '#access_token=' . uri_encode($token->id) .
                     '&state='        . uri_encode(params->{state}) .
                     '&token_type='   . uri_encode('Bearer');

    redirect $redirect_url;
};

1;
