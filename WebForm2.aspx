<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm2.aspx.cs" Inherits="TestASPApplication.WebForm2" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
	<title></title>
	<script src="JavaScriptTest.js"></script>
<script>
$(document).ready(function(){

 $.get("https://www.googleapis.com/youtube/v3/channels", 
		 {
		 part : 'contentDetails',
		 id: 'UCcvb8futgX64UIuAx45RzwQ',
		 key: 'AIzaSyCwFPOVc1MgZXjI9daB_8sUux6tE2sORmo'
		 
		 }	
		 , function(data, status){
		   $.each(data.items,function(i,item){
		   console.log(item);
		   var pid= item.contentDetails.relatedPlaylists.uploads;
		   getVids(pid);
		   })
	});
 function getVids(pid)
 {
	 $.get("https://www.googleapis.com/youtube/v3/playlistItems", 
			 {
			 part : 'snippet',
			 maxResults : 10,
			 playlistId : pid,
			 key: 'AIzaSyCwFPOVc1MgZXjI9daB_8sUux6tE2sORmo'
			 }	
			 , function(data, status){
			 var output;
			   $.each(data.items,function(i,item){
			   console.log('Video ID : ' +  item.snippet.resourceId.videoId);
			   //debugger;
			   output = '<li><iframe src=\"//www.youtube.com/embed/'+ item.snippet.resourceId.videoId+'\"></iframe></li>'
			   $('#results').append(output);
			   var VidTitle = item.snippet.title;
				console.log('Video Title : ' +VidTitle);
			   })
		});
 
 }

});

</script>

</head>
<body>
	<form id="form1" runat="server">
	<div>
	<h1>YouTube Videos</h1>
<ul id="results"></ul>
	</div>
	</form>
</body>
</html>
