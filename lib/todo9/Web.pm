package todo9::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use DBI;
use Encode 'decode';
use Data::Dumper;

sub getTable{
	my $database = 'DBI:mysql:DeNA';
	my $username = 'dena';
	my $password = 'shibuyahikarie';
	my $dbh = DBI->connect($database, $username, $password);

	my $sth = $dbh->prepare("SELECT * FROM todo9");
	$sth->execute;
	my $rows = $sth->fetchall_arrayref(+{});

	$sth->finish;
	$dbh->disconnect;

	my $return_text = "<table border=\"1\">\n<tr><th>最終更新</th><th>内容</th><th></th><th></th></tr>";
	foreach my $data (@$rows){
		my $decode_content = decode('UTF-8', $data->{content});
		$return_text .= "<tr><td>".$data->{updated_at}."</td><td>".$decode_content."</td>\n  <td>\n  <input type=\"button\" value=\"編集\" onClick=\"\$('#edit".$data->{id}."').get(0).style.display='block'\">\n  <div id=\"edit".$data->{id}."\" style=\"display:none\">\n	<form id=\"edit_commit".$data->{id}."\">\n	  <input name=\"id\" type=\"hidden\" value=\"\" />\n	  <input name=\"content\" type=\"textarea\" value=\"".$decode_content."\"><br/>\n	  <input type=\"button\" value=\"決定\" onClick=\"editPost('edit', ".$data->{id}.")\">\n	  <input type=\"button\" value=\"閉じる\" onClick=\"\$('#edit".$data->{id}."').get(0).style.display='none'\">\n	</form>\n  </div>\n  </td><td>\n	<input type=\"button\" value=\"削除\" onClick=\"deletePost('delete', ".$data->{id}.")\">\n  </td>\n</form>\n</td></tr>";
	}
	$return_text .= "</table>";

	return $return_text;
}

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

	return getTable();
};


post '/delete' => sub {
	my ($self, $c) = @_;
	my $result = $c->req->validator([
		'id' => {
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

	my $id = $result->valid('id');
	my $sth = $dbh->prepare("DELETE FROM todo9 WHERE id = '$id'");

	$sth->execute;
	$sth->finish;
	$dbh->disconnect;

	return getTable;
};

post '/edit' => sub {
	my ($self, $c) = @_;
	my $result = $c->req->validator([
		'id' => {
			rule => [
			['NOT_NULL', 'empty body'],
			],
		},
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

	my $id = $result->valid('id');
	my $content = $result->valid('content');
	my $sth = $dbh->prepare("UPDATE todo9 SET content = '$content' WHERE id = '$id'");

	$sth->execute;
	$sth->finish;
	$dbh->disconnect;

	return getTable;
};

1;
