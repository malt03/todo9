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

	my $tool_tips = "";
	my $return_text = "<table border=\"1\">\n<tr><th>重要性</th><th>内容</th><th>最終更新</th><th></th></tr>";
	foreach my $data (@$rows){
		my $decode_content = decode('UTF-8', $data->{content});
############################################################################################
        $return_text .=<<EOF;
<tr>
	<td id="edit_importance$data->{id}" onClick="displayEditImportance($data->{id})">$data->{importance}</td>
	<td id="edit_button$data->{id}" onClick="displayTips($data->{id})">$decode_content</td>
	<td>$data->{updated_at}</td>
	<td><input type="button" value="削除" onClick="deletePost('delete', $data->{id})"></td>
</form>
</td></tr>
EOF
############################################################################################
        $tool_tips .=<<EOF;
<div id="tips$data->{id}" style="display:none;width:215px;height:55px;position:absolute;background-color:white;border:solid black;padding:5px">
  <form id='edit_content_commit$data->{id}'>
	<table><tr><td>
	<input name='content' type='textarea' value='$decode_content' onKeyPress='return editEnter(event, $data->{id}, "content")'>
	</td></tr><tr><td>
	<input type="button" value="決定" onClick="editPost('edit', $data->{id}, 'content')">
	<input type="button" value="閉じる" onClick="\$('#tips$data->{id}').hide()">
	</td></tr></table>
  </form>
</div>
<div id="edit_importance_window$data->{id}" style="display:none;width:215px;height:55px;position:absolute;background-color:white;border:solid black;padding:5px">
  <form id='edit_importance_commit$data->{id}'>
	<table><tr><td>
	<input name='content' type='textarea' value='$data->{importance}' onKeyPress='return editEnter(event, $data->{id}, "importance")'>
	</td></tr><tr><td>
	<input type="button" value="決定" onClick="editPost('edit', $data->{id}, 'importance')">
	<input type="button" value="閉じる" onClick="\$('#edit_importance_window$data->{id}').hide()">
	</td></tr></table>
  </form>
</div>
EOF
############################################################################################
	}
	$return_text .= "</table>";

	$return_text .= $tool_tips;
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

get '/table' => sub {
	return getTable();
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
		},
		'columnname' => {
			rule => [
			['NOT_NULL', 'empty body'],
			],
		},
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
	my $column_name = $result->valid('columnname');
	my $sth = $dbh->prepare("UPDATE todo9 SET $column_name = '$content' WHERE id = '$id'");

	$sth->execute;
	$sth->finish;
	$dbh->disconnect;

	return getTable;
};

1;
