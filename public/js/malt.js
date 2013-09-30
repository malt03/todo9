function numOnly(){
	m = String.fromCharCode(event.keyCode);
	if("0123456789\b\r".indexOf(m, 0) < 0) return false;
	return true;
}

function addEnter(e){
	if(e.keyCode == 13){
		addPost("create");
		return false;
	}
}

function addPost(uri){
	var importance = $('#add [name=importance]').val();
	var content = $('#add [name=content]').val();
	$('#add [name=importance]').val('');
	$('#add [name=content]').val('');
	$.post(
		uri,
		{"content": content, "importance": importance},
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

function editPostSelect(uri, id, column_name){
	var obj = $('#edit_'+column_name+'_commit'+id);
	$('#status_num'+id).html(obj.prop("selectedIndex"));
	$('#list th').unbind();
	$("#list").tablesorter({
		headers: {
			5: {sorter:false}
		}
	});

	var val = obj.val();
	$.post(
		uri,
		{"id": id, "content": val, "columnname": column_name}
	);
}

function editPostSlider(uri, id, column_name, val){
	$('#'+column_name+'_num'+id).html(val);
	$('#list th').unbind();
	$("#list").tablesorter({
		headers: {
			5: {sorter:false}
		}
	});
	$.post(
		uri,
		{"id": id, "content": val, "columnname": column_name}
	);
}

function getData(data, status){
	if(status == "success"){
		$('#task_list').html(data);
		$("#list").tablesorter({
			sortList: [[0,1]],
			headers: {
				5: {sorter:false}
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