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

function editImportance(uri, id){
	var val = $('#edit_importance_commit'+id+' [name=content]').val();
	$.post(
		uri,
		{"id": id, "content": val},
		getData
	);
}

function getData(data, status){
	if(status == "success"){
		$('#task_list').html(data);
		$('.cluetip').cluetip({
			splitTitle: '|',
			showTitle: false,
			activation: 'click',
		});
	}else{
		alert("Error:" + status);
	}
}

function displayTips(id){
	var off = $('#edit_button'+id).offset();
	$('#tips'+id).css({top:off.top,left:off.left});
	$('#tips'+id).show();
	$('#edit_content_commit'+id+' [name=content]').focus();
}

function displayEditImportance(id){
	var off = $('#edit_importance'+id).offset();
	$('#edit_importance_window'+id).css({top:off.top,left:off.left});
	$('#edit_importance_window'+id).show();
	$('#edit_importance_commit'+id+' [name=content]').focus();
z}

$(document).ready(function() {
	$.get(
		"table",
		getData
	);
});