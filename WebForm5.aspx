<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm4.aspx.cs" Inherits="TestASPApplication.WebForm4" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
   <title>YouTube Data API Quickstart</title>
	<script src="GoogleAPI.js"></script>
	<script src="JavaScriptTest.js"></script>


</head>
<body>
	
   <p>YouTube Data API Quickstart</p>

	<!--Add buttons to initiate auth sequence and sign out-->
	<button id="authorize-button" style="display: none;">Authorize</button>
	<button id="signout-button" style="display: none;">Sign Out</button>

	<pre id="content"></pre>

	<script type="text/javascript">


		$(document).ready(function () {
			handleClientLoad();
		});

		


	  // Client ID and API key from the Developer Console
		var CLIENT_ID = '487346152943-660l88i25t3uh108qfimgeii8hlcg4bl.apps.googleusercontent.com';

	  // Array of API discovery doc URLs for APIs used by the quickstart
	  var DISCOVERY_DOCS = ["https://www.googleapis.com/discovery/v1/apis/youtube/v3/rest"];

	  // Authorization scopes required by the API. If using multiple scopes,
	  // separated them with spaces.
	  var SCOPES = 'https://www.googleapis.com/auth/youtube.upload https://www.googleapis.com/auth/youtube.force-ssl';

	  var authorizeButton = document.getElementById('authorize-button');
	  var signoutButton = document.getElementById('signout-button');

	  /**
	   *  On load, called to load the auth2 library and API client library.
	   */
	  function handleClientLoad() {
		gapi.load('client:auth2', initClient);
	  }

	  /**
	   *  Initializes the API client library and sets up sign-in state
	   *  listeners.
	   */
	  function initClient() {
		gapi.client.init({
		  discoveryDocs: DISCOVERY_DOCS,
		  clientId: CLIENT_ID,
		  scope: SCOPES
		}).then(function () {
		  // Listen for sign-in state changes.
		  gapi.auth2.getAuthInstance().isSignedIn.listen(updateSigninStatus);

		  // Handle the initial sign-in state.
		  updateSigninStatus(gapi.auth2.getAuthInstance().isSignedIn.get());
		  authorizeButton.onclick = handleAuthClick;
		  signoutButton.onclick = handleSignoutClick;
		});
	  }

	  /**
	   *  Called when the signed in status changes, to update the UI
	   *  appropriately. After a sign-in, the API is called.
	   */
	  function updateSigninStatus(isSignedIn) {
		if (isSignedIn) {
		  authorizeButton.style.display = 'none';
		  signoutButton.style.display = 'block';
		  GetChannels();
		} else {
		  authorizeButton.style.display = 'block';
		  signoutButton.style.display = 'none';
		}
	  }

	  /**
	   *  Sign in the user upon button click.
	   */
	  function handleAuthClick(event) {
		gapi.auth2.getAuthInstance().signIn();
	  }

	  /**
	   *  Sign out the user upon button click.
	   */
	  function handleSignoutClick(event) {
	      $('#results').html('');
	      $('#results').empty();
		gapi.auth2.getAuthInstance().signOut();
	  }

	  /**
	   * Append text to a pre element in the body, adding the given message
	   * to a text node in that element. Used to display info from API response.
	   *
	   * @param {string} message Text to be placed in pre element.
	   */
	  function appendPre(message) {
		var pre = document.getElementById('content');
		var textContent = document.createTextNode(message + '\n');
		pre.appendChild(textContent);
	  }

	  /**
	   * Print files.
	   */
	  function getChannel() {
		gapi.client.youtube.channels.list({
		  'part': 'snippet,contentDetails,statistics',
		  'forUsername': 'GoogleDevelopers'
		}).then(function(response) {
		  var channel = response.result.items[0];
		  appendPre('This channel\'s ID is ' + channel.id + '. ' +
					'Its title is \'' + channel.snippet.title + ', ' +
					'and it has ' + channel.statistics.viewCount + ' views.');
		});
	  }

	  function GetChannels() {
		  gapi.client.request({
			  'method': 'GET',
			  'path': '/youtube/v3/channels',
			  'params': { 'part': 'contentDetails', 'mine': 'true' }
		  }).then(function (data, status) {
			  let PlayListid = data.result.items["0"].contentDetails.relatedPlaylists.uploads;
			  GetPlaylistVideos(PlayListid);
		  }, function (error) {
			  alert(error);
		  });
	  }
	  function GetPlaylistVideos(PlayListid) {
		  var request = gapi.client.request({
			  'method': 'GET',
			  'path': '/youtube/v3/playlistItems',
			  'params': { 'part': 'snippet', 'mine': 'true', 'maxResults': 10, 'playlistId': PlayListid }
		  }).then(function (data, status) {
			  var output;
			  $.each(data.result.items, function (i, item) {
				  console.log('Video ID : ' + item.snippet.resourceId.videoId);
				  output = '<li><iframe src=\"//www.youtube.com/embed/' + item.snippet.resourceId.videoId + '\"></iframe></li>'
				  $('#results').append(output);
				  var VidTitle = item.snippet.title;
				  console.log('Video Title : ' + VidTitle);
			  });
		  });

	  }

	</script>

	  <form id="form1" runat="server">
	<div>
	<h1>YouTube Videos</h1>
        <ul id="results"></ul>
	</div>
		
	</form>
</body>
</html>
