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
	}else{
		alert("Error:" + status);
	}
}