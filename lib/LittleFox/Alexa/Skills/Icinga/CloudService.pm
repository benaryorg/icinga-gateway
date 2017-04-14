package LittleFox::Alexa::Skills::Icinga::CloudService;

use Dancer2;
use Dancer2::Plugin::Auth::Tiny;
use Dancer2::Plugin::DBIC;
use URI;

use LittleFox::Alexa::Skills::Icinga::CloudService::Security;
use LittleFox::Alexa::Skills::Icinga::CloudService::OAuth2;
use LittleFox::Alexa::Skills::Icinga::CloudService::Instances;

prefix undef;
our $VERSION = 0.001;

get '/' => sub {
    template 'index';
};

get '/logout' => sub {
    session user => undef;
    redirect '/';
};

get '/login' => sub {
    template 'login' => {
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

        my $uri = URI->new($return_url // '/');
        $uri->query_form($params);

        redirect $uri->as_string;
    }
    else {
        template 'login' => {
            return_url => params->{return_url},
        };
    }
};

get '/register' => sub {
    template 'register';
};

post '/register' => sub {
    my $username  = params->{username};
    my $email     = params->{email};
    my $password1 = params->{password1};
    my $password2 = params->{password2};

    my @errors = ();

    if($password1 ne $password2) {
        push(@errors, 'Die Passwörter stimmen nicht überein');
    }

    if(length($password1) < 8) {
        push(@errors, 'Das Passwort muss mindestens 8 Zeichen lang sein (das ist aber auch die einzige Regel)');
    }

    if(length($username) < 4) {
        push(@errors, 'Der Benutzername muss mindestens 4 Zeichen lang sein');
    }

    if(rset('User')->search({username => $username})->count) {
        push(@errors, 'Der Benutzername ist bereits vergeben');
    }

    if(rset('User')->search({email => $email})->count) {
        push(@errors, 'Die E-Mail Adresse wird bereits verwendet');
    }

    if(@errors) {
        template register => {
            errors   => \@errors,
            username => $username,
            email    => $email,
        };
    }
    else {
        rset('User')->register($username, $email, $password1);
        template register => {
            success => 1,
        };
    }
};

1;
