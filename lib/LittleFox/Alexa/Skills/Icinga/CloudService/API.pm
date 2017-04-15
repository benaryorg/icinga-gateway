package LittleFox::Alexa::Skills::Icinga::CloudService::API;

use AnyEvent;
use AnyEvent::HTTP;
use Dancer2 appname => 'LittleFox::Alexa::Skills::Icinga::CloudService';
use Dancer2::Plugin::DBIC;
use MIME::Base64;
use URI::Encode 'uri_decode';

prefix '/api';

sub get_user {
    my ($instance_id) = @_;

    my $user;

    if(session('user')) {
        $user = rset('User')->find(session('user'));
    }
    elsif(my $authorization = request_header 'Authorization') {
        my ($method, $token) = split(/ /, $authorization, 2);

        if($method eq 'Bearer') {
            my $token_object = rset('OAuth2Token')->find($token);

            if($token_object) {
                $user = $token_object->user;
            }
        }
        elsif($method eq 'Basic') {
            my ($username, $password) = split(/:/, decode_base64($token), 2);

            $user = rset('User')->authenticate($username, $password);
        }
    }

    if(!defined($user)) {
        response_header 'WWW-Authenticate' => 'Basic realm="Icinga2 Gateway API access"';
        status 401;
    }

    return $user;
}

get '' => sub {
    my $user = get_user;

    if(!defined($user)) {
        return;
    }

    my @instances = map {
        {
            id          => $_->id,
            base_href   => request->uri_for('/api/' . $_->id),
            status_href => request->uri_for('/api/' . $_->id . '/v1/status'),
        }
    } $user->administrated_instances;

    response_header 'Content-Type' => 'application/json';

    return encode_json(
        {
            instances => \@instances,
        }
    );
};

get '/:instance_id/**' => sub {
    my ($parts) = splat;

    my $user = get_user;

    if(!defined($user)) {
        return;
    }

    my $instance = rset('Instance')->find(params->{instance_id});
    my $path     = join('/', @$parts) . '?' . uri_decode(request->query_string);
    debug $path;

    if($instance->admin_user_id != $user->id) {
        send_error 'Access denied', 403;
    }

    my $url     = $instance->api_url . $path;
    my $auth    = encode_base64($instance->api_user . ':' . $instance->api_password);
    chomp $auth;

    my $headers = {
        Authorization => 'Basic ' . $auth,
        Accept        => 'application/json',
    };

    delayed {
        flush;

        my $cv = AnyEvent->condvar;
        $cv->cb(delayed { done; });

        $cv->begin;
        http_get $url, headers => $headers, delayed {
            my ($data, $headers) = @_;
            content $data;
            $cv->end;
        };
    };
};

1;
