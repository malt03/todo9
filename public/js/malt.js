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

function editPost(uri, id){
	var val = $('#edit_commit'+id+' [name=content]').val();
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
	$('#edit_commit'+id+' [name=content]').focus();
}

$(document).ready(function() {
	$.get(
		"table",
		getData
	);
});