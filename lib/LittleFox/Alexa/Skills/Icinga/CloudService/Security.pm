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
    my $old_password  = params->{old_password};
    my $new_password1 = params->{new_password1};
    my $new_password2 = params->{new_password2};

    my $user = rset('User')->find(session('user'));

    my @errors = ();

    if(!$user->verify_password($old_password)) {
        push(@errors, 'Bestehendes Passwort ist nicht korrekt');
    }

    if($new_password1 ne $new_password2) {
        push(@errors, 'Neue Passwörter sind nicht identisch');
    }

    if(length($new_password1) < 8) {
        push(@errors, 'Das neue Passwort muss mindestens 8 Zeichen lang sein (das ist aber auch die einzige Regel)');
    }

    if(@errors) {
        template 'security/password' => {
            submenu => $SECURITY_SUBMENU,
            errors  => \@errors,
        };
    }
    else {
        $user->change_password($new_password1);
        template 'security/password' => {
            submenu => $SECURITY_SUBMENU,
            success => 1,
        };
    }
};

get '/end_session' => sub {
    template 'security/end_sessions' => {
        submenu => $SECURITY_SUBMENU,
    };
};

post '/end_session' => sub {
    my $user = rset('User')->find(session('user'));
    $user->tokens->delete;
    redirect '/security';
};

1;
