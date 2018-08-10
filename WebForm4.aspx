<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm4.aspx.cs" Inherits="TestASPApplication.WebForm4" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="GoogleAPI.js"></script>
    <script src="JavaScriptTest.js"></script>
    <script>
        $(document).ready(function () {
            //alert('function is going to call');
            gapi.load('client', {
                callback: function () {
                    
                    handleClientLoad();
                },
                onerror: function () {
                    
                    alert('gapi.client failed to load!');
                },
                timeout: 5000, 
                ontimeout: function () {
                 
                    alert('gapi.client could not load in a timely manner!');
                }
            });

           
        });

        var apiKey = 'AIzaSyDNRKAN4oJV52oGHotHSDWAdcatxub0ZE8';
        var clientId = '487346152943-660l88i25t3uh108qfimgeii8hlcg4bl.apps.googleusercontent.com';
        var scopes ='https://www.googleapis.com/auth/youtube.upload https://www.googleapis.com/auth/youtube.force-ssl';
        function handleClientLoad() {
            debugger;
            gapi.client.setApiKey(apiKey);
            window.setTimeout(checkAuth, 1);
        }
        function checkAuth() {

            gapi.auth2.authorize({
                client_id: clientId,
                scope: scopes,
                response_type: 'token'
            }, function (response) {
                debugger;
                if (response.error) {
                    alert(response.error);
                    return;
                }
                else {
                    debugger;
                    alert(response.access_token);
                    var accessToken = response.access_token;
                    var idToken = response.id_token;

                    var request = gapi.client.request({
                        'method': 'GET',
                        'path': '/youtube/v3/channels',
                        'params': { 'part': 'contentDetails', 'mine': 'true' }
                    }).then(function (data, status) {
                        debugger;
                        getVids(data.result.items["0"].contentDetails.relatedPlaylists.uploads);
                    }, function (error) {
                        debugger;
                        alert(error);
                    });
            
                    //request.execute(function(response) {
                    //    debugger;
                    //    console.log(response);
                    //    CallAPI(data);
                    //});

                 
                    

                }
            
            
                
            });


           // gapi.auth.authorize({ client_id: clientId, scope: scopes, immediate: true }, handleAuthResult);
        }
        function handleAuthResult(authResult) {
            alert(authResult);
        }

        

        function getVids(pid) {
            var request = gapi.client.request({
                'method': 'GET',
                'path': '/youtube/v3/playlistItems',
                'params': { 'part': 'snippet', 'mine': 'true', 'maxResults': 10,'playlistId' :pid }
            }).then(function (data, status) {
                var output;
                $.each(data.result.items, function (i, item) {
                    console.log('Video ID : ' + item.snippet.resourceId.videoId);
                    debugger;
                    output = '<li><iframe src=\"//www.youtube.com/embed/' + item.snippet.resourceId.videoId + '\"></iframe></li>'
                    $('#results').append(output);
                    var VidTitle = item.snippet.title;
                    console.log('Video Title : ' + VidTitle);
                });
                debugger;

            });

        }
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
