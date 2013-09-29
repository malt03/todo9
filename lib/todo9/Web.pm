package todo9::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use DBI;
use Data::Dumper;

filter 'set_title' => sub {
    my $app = shift;
    sub {
        my ( $self, $c )  = @_;
        $c->stash->{site_name} = __PACKAGE__;
        $app->($self,$c);
    }
};

get '/' => sub {
    my ( $self, $c )  = @_;

	my $database = 'DBI:mysql:DeNA';
	my $username = 'dena';
	my $password = 'shibuyahikarie';
	my $dbh = DBI->connect($database, $username, $password);
	my $sth = $dbh->prepare("SELECT * FROM todo9");

	$sth->execute;
	my $rows = $sth->fetchall_arrayref(+{});
	print Dumper $rows->[0]->{content};
	
	$sth->finish;
	$dbh->disconnect;

	$c->render('index.tx', {
		rows => $rows,
		greeting => "Todo9!",
    });
};

get '/json' => sub {
    my ( $self, $c )  = @_;
    my $result = $c->req->validator([
        'q' => {
            default => 'Hello',
            rule => [
                [['CHOICE',qw/Hello Bye/],'Hello or Bye']
            ],
        }
    ]);
    $c->render_json({ greeting => $result->valid->get('q') });
};

1;

post '/create' => sub {
	my ($self, $c) = @_;
	my $result = $c->req->validator([
		'content' => {
			rule => [
				['NOT_NULL', 'empty body'],
			],
		}
	]);

	if($result->has_error){
		return $c->render_json({error=>1, messages=>$result->errors});
	}
	
	my $database = 'DBI:mysql:DeNA';
	my $username = 'dena';
	my $password = 'shibuyahikarie';
	my $dbh = DBI->connect($database, $username, $password);

	my $content = $result->valid('content');
	my $sth = $dbh->prepare("INSERT INTO todo9 (content) VALUES('$content')");

	$sth->execute;
	$sth->finish;
	$dbh->disconnect;

	return "OK!";
}
