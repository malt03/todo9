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
	my $return_text = "<table class=\"tablesorter\" id=\"list\" border=\"1\">\n<thead><tr><th style=\"border:solid #000000 1px;width:100px\">重要性</th><th style=\"border:solid #000000 1px\">内容</th><th style=\"border:solid #000000 1px\">状態</th><th style=\"border:solid #000000 1px\">最終更新</th><th style=\"border:solid #000000 1px\"></th></tr></thead>";
	foreach my $data (@$rows){
		my $decode_content = decode('UTF-8', $data->{content});
		my $id = $data->{id};
############################################################################################
        $return_text .=<<EOF;
<tr>
	<td id="importance_edit$id" style="text-align:center;font-size:15px;vertical-align:middle"><input type="range" value="$data->{importance}" style="width:100px" onMouseUp="editPostSlider('edit', $id, 'importance', this.value)"><div id="importance_num$id" style="display:none">$data->{importance}</div></td>
	<td id="content_edit$id" onClick="displayTips($id, 'content')" style="font-size:15px;vertical-align:middle">$decode_content</td>
	<td>
	    <select id="edit_status_commit$id" style="height:20px" onChange="editPostSelect('edit', $id, 'status')">
EOF
        my $status = $data->{status};
		my $status_number;
        if($status eq 'untouched'){$status_number=0;
								   $return_text.='<option value="untouched" selected>untouched</option>';}
		else                      {$return_text.='<option value="untouched">untouched</option>';}
		if($status eq 'working')  {$status_number=1;
								   $return_text.='<option value="working" selected>working</option>';}
		else                      {$return_text.='<option value="working">working</option>';}
		if($status eq 'done')     {$status_number=2;
								   $return_text.='<option value="done" selected>done</option>';}
		else                      {$return_text.='<option value="done">done</option>';}
        $return_text .=<<EOF;
		</select>
		<div id="status_num$id" style="display:none">$status_number</div>
	</td>
	<td style="font-size:15px;vertical-align:middle">$data->{updated_at}</td>
	<td><input type="button" value="削除" onClick="deletePost('delete', $id)" style="height:30px"></td>
</td></tr>
EOF
############################################################################################
        $tool_tips .=<<EOF;
<div class="tips" id="content_tips$id" style="display:none;width:215px;height:55px;position:absolute;background-color:white;border:solid black;padding:5px">
  <form id='edit_content_commit$id'>
	<table><tr><td>
	<input name='content' type='textarea' value='$decode_content' onKeyPress='return editEnter(event, $id, "content")'>
	</td></tr><tr><td>
	<input type="button" value="決定" onClick="editPost('edit', $id, 'content')">
	<input type="button" value="閉じる" onClick="\$('#content_tips$id').hide()">
	</td></tr></table>
  </form>
</div>
<div class="tips" id="importance_tips$id" style="display:none;width:215px;height:55px;position:absolute;background-color:white;border:solid black;padding:5px">
  <form id='edit_importance_commit$id'>
	<table><tr><td>
	<input name='content' type='textarea' value='$data->{importance}' onKeyPress='return editEnter(event, $id, "importance")' style="width:30px">
	</td></tr><tr><td>
	<input type="button" value="決定" onClick="editPost('edit', $id, 'importance')">
	<input type="button" value="閉じる" onClick="\$('#importance_tips$id').hide()">
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
		},
		'importance' => {
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

	my $importance = $result->valid('importance');
	my $content = $result->valid('content');
	my $sth = $dbh->prepare("INSERT INTO todo9 (importance, content) VALUES($importance, '$content')");
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
