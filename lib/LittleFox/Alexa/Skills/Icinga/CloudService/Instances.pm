package LittleFox::Alexa::Skills::Icinga::CloudService::Instances;

use Dancer2 appname => 'LittleFox::Alexa::Skills::Icinga::CloudService';
use Dancer2::Plugin::Auth::Tiny;
use Dancer2::Plugin::DBIC;

prefix '/instances';

get '' => needs login => sub {
    my $user      = rset('User')->find(session('user'));
    my @instances = $user->administrated_instances->all;

    template 'instances/index' => {
        instances => \@instances,
    };
};

get '/edit' => needs login => sub {
    my $id       = params->{id};
    my $readonly = 0;
    my $entry;

    if(defined $id && $id ne 'new') {
        $entry = rset('Instance')->find($id);

        if(defined $entry && $entry->admin_user_id != session('user')) {
            $readonly = 1;
        }
    }

    template 'instances/edit' => {
        entry    => $entry,
        readonly => $readonly,
    };
};

post '/edit' => needs login => sub {
    my $id       = params->{id};
    my $readonly = 0;
    my $entry;

    if(defined $id && $id ne 'new') {
        $entry = rset('Instance')->find($id);

        if(defined $entry && $entry->admin_user_id != session('user')) {
            $readonly = 1;
        }
    }
    else {
        $entry = rset('Instance')->new(
            {
                admin_user_id => session('user'),
            }
        );
    }

    if($readonly) {
        return redirect '/instances/edit?id=' . $id;
    }

    $entry->description(params->{description});
    $entry->api_url(params->{api_url});
    $entry->api_user(params->{api_user});
    $entry->api_password(params->{api_password}) if params->{api_password};
    $entry->api_certificate(params->{api_cert} ? params->{api_cert} : undef);

    if($entry->in_storage) {
        $entry->update;
    }
    else {
        $entry->insert;
    }

    template 'instances/edit' => {
        readonly => $readonly,
        entry    => $entry,
        success  => 1,
    };
};

1;
