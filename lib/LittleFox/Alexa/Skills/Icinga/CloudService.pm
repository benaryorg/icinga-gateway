package LittleFox::Alexa::Skills::Icinga::CloudService;

use Crypt::JWT 'encode_jwt', 'decode_jwt';
use Dancer2;
use Dancer2::Plugin::Auth::Tiny;
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::Locale::Wolowitz;
use Text::Markdown 'markdown';
use Try::Tiny;
use URI;

use LittleFox::Alexa::Skills::Icinga::CloudService::API;
use LittleFox::Alexa::Skills::Icinga::CloudService::Instances;
use LittleFox::Alexa::Skills::Icinga::CloudService::OAuth2;
use LittleFox::Alexa::Skills::Icinga::CloudService::Security;

prefix undef;
our $VERSION = 0.001;

sub get_csrf_token {
    my $payload = {
        uri => request->path,
        sub => session('user'),
    };

    return encode_jwt(payload => $payload, alg => 'HS256', key => config->{csrf_key});
}

sub validate_csrf_token {
    my ($token) = @_;

    my $data;

    try {
        $data = decode_jwt(
            token      => $token,
            key        => config->{csrf_key},
        );

        if($data) {
            my $user_session = session('user');
            my $user_token   = $data->{sub};

            if(defined $user_session != defined $user_token) {
                $data = undef;
            }
            elsif($user_session != $user_token) {
                $data = undef;
            }
        }
    }
    catch {
    };

    return 0 unless $data;

    return $data->{uri} eq request->path;
}

hook before => sub {
    if(request->is_post()) {
        my $token = param('csrf_token');
        if(!$token || !validate_csrf_token($token)) {
            send_error 'CSRF protection failed - this looks like an attack!', 403;
        }
    }
};

hook before_template_render => sub {
    my ($tokens) = @_;

    $tokens->{csrf_token} = get_csrf_token;
};

get '/' => sub {
    redirect '/start';
};

get '/doc' => sub {
    template 'doc' => {
        title => loc('Dokumentation'),
    };
};

get '/logout' => sub {
    session user => undef;
    redirect '/';
};

get '/login' => sub {
    template 'login' => {
        title      => loc('Anmelden'),
        return_url => params->{return_url},
    };
};

post '/login' => sub {
    my $username = params->{username};
    my $password = params->{password};

    if(my $user = rset('User')->authenticate($username, $password)) {
        session user => $user->id;

        my $return_url = params->{return_url};

        my $params = params;
        delete $params->{username};
        delete $params->{password};
        delete $params->{return_url};
        delete $params->{csrf_token};

        my $uri = URI->new($return_url // '/');
        $uri->query_form($params);

        redirect $uri->as_string;
    }
    else {
        template 'login' => {
            title      => loc('Anmelden'),
            return_url => params->{return_url},
            error      => loc('Ungültige Zugangsdaten'),
        };
    }
};

get '/register' => sub {
    template 'register' => {
        title => loc('Registrieren'),
    };
};

post '/register' => sub {
    my $username  = params->{username};
    my $email     = params->{email};
    my $password1 = params->{password1};
    my $password2 = params->{password2};

    my @errors = ();

    if($password1 ne $password2) {
        push(@errors, loc('Die Passwörter stimmen nicht überein'));
    }

    if(length($password1) < 8) {
        push(@errors, loc('Das Passwort muss mindestens 8 Zeichen lang sein (das ist aber auch die einzige Regel)'));
    }

    if(length($username) < 4) {
        push(@errors, loc('Der Benutzername muss mindestens 4 Zeichen lang sein'));
    }

    if(rset('User')->search({username => $username})->count) {
        push(@errors, loc('Der Benutzername ist bereits vergeben'));
    }

    if(rset('User')->search({email => $email})->count) {
        push(@errors, loc('Die E-Mail Adresse wird bereits verwendet'));
    }

    if(@errors) {
        template register => {
            title    => loc('Registrieren'),
            errors   => \@errors,
            username => $username,
            email    => $email,
        };
    }
    else {
        rset('User')->register($username, $email, $password1);
        template register => {
            title   => loc('Registrieren'),
            success => 1,
        };
    }
};

get '/:doc_name' => sub {
    my $lang     = loc('langcode');
    my $doc_name = params->{doc_name};
    my $filename = "$FindBin::Bin/../i18n/docs/$lang/$doc_name.md";

    if($doc_name =~ /\.\./) {
        error '.. in $doc_name';
        send_error 'Not found', 404;
    }

    if ( -f $filename ) {
        open(my $fh, '<', $filename);
        local $/ = undef;

        my $markdown = <$fh>;
        close($fh);

        utf8::decode($markdown);
        my ($title) = $markdown =~ m/^# (.*)/;
        $markdown               =~ s/^# (.*)//;

        my $html    = markdown($markdown);

        return template empty => {
            title   => $title,
            content => $html,
        };
    }

    pass;
};

1;
