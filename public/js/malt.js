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
	var table_color = $('#add [name=table_color]').val();
	var limit_date = $('#add [name=limit_date]').val();
	$('#add [name=importance]').val(50);
	$('#add [name=content]').val('');
	$('#add [name=table_color]').val('#ffffff');
	$('#add [name=limit_date]').val('');
	$.post(
		uri,
		{"content": content, "importance": importance, "table_color": table_color, "limit_date": limit_date},
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
			7: {sorter:false}
		}
	});

	var val = obj.val();
	$.post(
		uri,
		{"id": id, "content": val, "columnname": column_name}
	);
}

function editPostSlider(uri, id, column_name, val, flag){
	$('#'+column_name+'_num'+id).html(val);
	$('#list th').unbind();
	$("#list").tablesorter({
		headers: {
			7: {sorter:false}
		}
	});
	if(flag){
		$.post(
			uri,
			{"id": id, "content": val, "columnname": column_name}
		);
		$('.td'+id).css("background-color",val);
	}else{
		$.post(
			uri,
			{"id": id, "content": val, "columnname": column_name}
		);
	}
}

function getData(data, status){
	if(status == "success"){
		$('#task_list').html(data);
		$("#list").tablesorter({
			sortList: [[6,1]],
			headers: {
				7: {sorter:false}
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

function remainingTime(id){
	var now_date = new Date();
	var limit_date_html = $('#limit_date_num'+id).html();
	if(limit_date_html === "") return;
	var limit_date = Date.parse(limit_date_html);
	var remaining_time = (limit_date-now_date.getTime())/1000;
	if(remaining_time > 0){
		$('#remaining_time'+id).html(Math.ceil(remaining_time/86400)+'日'+Math.ceil(remaining_time/3600%24)+'時間'+Math.ceil((remaining_time)/60%60)+'分'+Math.ceil(remaining_time%60-1)+'秒');
		var color = Math.ceil(255 * (604800-remaining_time) / 604800);
		if(color < 0) color = 0;
		$('#remaining_time'+id).css("color","#"+color.toString(16)+"0000");
		setTimeout(function(){remainingTime(id);}, 1000);
	}
}

$(document).ready(function() {
	$.get(
		"table",
		getData
	);
});