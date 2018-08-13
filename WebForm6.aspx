<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm6.aspx.cs" Inherits="TestASPApplication.WebForm6" %>

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
		var ACCESS_TOKEN = null;
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
	   */https://www.googleapis.com/youtube/v3/channels?part=id&mine=true&access_token=HereYourAccessToken
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
	      gapi.auth2.getAuthInstance().signIn().then(function (response) {
	          debugger;
	          ACCESS_TOKEN = gapi.auth2.getAuthInstance().currentUser.get().Zi.access_token;
	      }, function (reason) {
	          alert(reason);
	      });
	      
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
		}).then(function (response) {
		 
		  var channel = response.result.items[0];
		  appendPre('This channel\'s ID is ' + channel.id + '. ' +
					'Its title is \'' + channel.snippet.title + ', ' +
					'and it has ' + channel.statistics.viewCount + ' views.');
		});
	  }

	  function GetChannels() {
	      var xhr = new XMLHttpRequest();
	      xhr.open('GET',
              'https://www.googleapis.com/youtube/v3/channels?part=contentDetails&mine=true&' +
              'access_token=' + ACCESS_TOKEN);

	      xhr.onreadystatechange = function (e) {
	          if (xhr.readyState === 4 && xhr.status === 200) {
	              debugger;
	              console.log(xhr.response);
	              let jsonResponse = $.parseJSON(xhr.response);
	              let PlayListid = jsonResponse.items[0].contentDetails.relatedPlaylists.uploads;
	              GetPlaylistVideos(PlayListid);
	          } else if (xhr.readyState === 4 && xhr.status === 401) {
	              gapi.auth2.getAuthInstance().signIn()
	          }
	      };
	      xhr.send(null);
	  }
	  function GetPlaylistVideos(PlayListid) {

	      var xhr = new XMLHttpRequest();
	      xhr.open('GET',
              'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&mine=true&maxResults=10&playlistId=' +PlayListid+
              '&access_token=' + ACCESS_TOKEN);

	      xhr.onreadystatechange = function (e) {
	          if (xhr.readyState === 4 && xhr.status === 200) {
	              console.log(xhr.response);
	              let jsonResponse = $.parseJSON(xhr.response);
	              $.each(jsonResponse.items, function (i, item) {
	                    	  console.log('Video ID : ' + item.snippet.resourceId.videoId);
	                    	  output = '<li><iframe src=\"//www.youtube.com/embed/' + item.snippet.resourceId.videoId + '\"></iframe></li>'
	                    	  $('#results').append(output);
	                    	  var VidTitle = item.snippet.title;
	                    	  console.log('Video Title : ' + VidTitle);
	                      });
	          } else if (xhr.readyState === 4 && xhr.status === 401) {
	              gapi.auth2.getAuthInstance().signIn()
	          }
	      };

	      xhr.send(null);
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
