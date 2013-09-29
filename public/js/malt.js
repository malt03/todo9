function addEnter(e){
	if(e.keyCode == 13){
		addPost("create");
		return false;
	}
}

function addPost(uri){
	var val = $('#add [name=content]').val();
	$('#add [name=content]').val('');
	$.post(
		uri,
		{"content": val},
		getData
	);
}

function deletePost(uri, id){
	$.post(
		uri,
		{"id": id},
		getData
	);
}

function editEnter(e, id, column_name){
	if(e.keyCode == 13){
		editPost("edit", id, column_name);
		return false;
	}
}

function editPost(uri, id, column_name){
	var val = $('#edit_'+column_name+'_commit'+id+' [name=content]').val();
	$.post(
		uri,
		{"id": id, "content": val, "columnname": column_name},
		getData
	);
}

function getData(data, status){
	if(status == "success"){
		$('#task_list').html(data);
		$("#list").tablesorter({
			sortList: [[0,1]],
			headers: {
				3: {sorter:false}
			}
		});
	}else{
		alert("Error:" + status);
	}
}

function displayTips(id, column_name){
	$('.tips').hide();
	var off = $('#'+column_name+'_edit'+id).offset();
	$('#'+column_name+'_tips'+id).css({top:off.top,left:off.left});
	$('#'+column_name+'_tips'+id).show();
	$('#edit_'+column_name+'_commit'+id+' [name=content]').focus();
}

$(document).ready(function() {
	$.get(
		"table",
		getData
	);
});