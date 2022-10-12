# Postman Zabbix
Postman is a great tool to perform API requests. To add bulks of hosts or get information from Zabbix, a combination with Postman is great. 
In this cheat sheet you can find how to set up a connection with Zabbix, how to perform request, check if requests are successful and to get information of add devices to Zabbix. 

## Set up Postman for Zabbix <6.0
_Note: In Zabbix, before 6.0, you need to log on, with an API request, generate a token and then you can use this token. From Zabbix 6.0 and later, you can generate a token in the frontend, see [[Postman Zabbix#Set up Postman for Zabbix 6 0]]Set up Postman for Zabbix >=Zabbix 6.0_

### Environment settings
Go to environments and create a new environment.
Create 4 variables:
- url (zabbix url including example: https://zabbix.url/zabbix/api_jsonrpc.php)
- user (zabbix user)
- id (unique ID, not used by other scripts that use the API)
- token (leave empty)

![[Pasted image 20221012114205.png]]

### Get token request
Go to Collections, create a new collection and a new request. For Zabbix, make sure in your requests to always use: 
- Request: POST
- Body: RAW
- Type: JSON

Also place {{url}} after the POST field. This URL points to the variable _url_ we have set in the environment.
![[Pasted image 20221012114625.png]]

Create the first request named _Zabbix login_

In the Body field place:
```json
{
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
        "user": "{{user}}",
        "password": "PASSWORD"
    },
    "id": {{id}}
}
```

Now in test, add a script. This script will get the token from the request and parse it to your variable so you don't have to set it manual.
```java
var jsonData = JSON.parse(responseBody);
postman.setEnvironmentVariable("token", jsonData.result);
```

After finishing, you can send the request and check if in your environment, your variable is set. 
*hint: remove your password from the body field to prevent security issues*

### Test token request
Create a new request to test if your token is working. 
In the body field place:
```json
{
    "jsonrpc": "2.0",
    "method": "user.checkAuthentication",
    "params": {
        "sessionid": "{{token}}"
    },
    "id": {{id}}
}
```

This request will use your token to perform a login and returns information about your account:
![[Pasted image 20221012115733.png]]

### Destroy token
Your token will not expire by default, however if you create a new token each time you will use Postman, you will get this information in your Zabbix database. For postman usage not a big issue but when you use scripts with logins and every time create a new token (for example multiple times per minute) you will get a lot of garbage in your database. 

You can destroy your token after usage. This will perform a logout and delete the token.
Create a new request with in the body field:
```json
{
    "jsonrpc": "2.0",
    "method": "user.logout",
    "params": [],
    "id": {{id}},
    "auth": "{{token}}"
}
```

# Set up Postman for Zabbix >=6.0

Starting from Zabbix 6.0 you can create a token in the frontend of Zabbix (you can however also use the old method mentioned above). 

### Create API token
Go to the Zabbix frontend, browse to User settings -> API tokens and Create an API token:
![[Pasted image 20221012120522.png]]

![[Pasted image 20221012120646.png]]
Make sure to copy the token, it's only displayed once. 

### Environment settings
In Postman, go to environments and create a new environment.
Create 4 variables:
- url (zabbix url including example: https://zabbix.url/zabbix/api_jsonrpc.php)
- user (zabbix user)
- id (unique ID)
- token (token generated in previous step)
![[Pasted image 20221012121053.png]]

### Test token request
Go to Collections, create a new collection and a new request. For Zabbix, make sure in your requests to always use: 
- Request: POST
- Body: RAW
- Type: JSON

Also place {{url}} after the POST field. This URL points to the variable _url_ we have set in the environment.
![[Pasted image 20221012114625.png]]

Create the first request named _Zabbix Test Token_
In the Body field place:
```json
{
    "jsonrpc": "2.0",
    "method": "authentication.get",
    "params": {
        "output": "extend"
    },
    "auth": "{{token}}",
    "id": 8
}
```

This request will use your token to perform a login and returns information about your account:
![[Pasted image 20221012115733.png]]

## Error HELP!
Common mistakes and how to solve them:

### Config mistake in request
After a request you will get _412 Precondition Failed_
![[Pasted image 20221012123308.png]]
Your request is probably not in JSON but in Text (default) or another format:

![[Pasted image 20221012123432.png]]

The Zabbix API is JSON based, always use JSON.

### Mistake in JSON format
After a request you get the message _Invalid JSON. An error occurred on the server while parsing the JSON text._
![[Pasted image 20221012134434.png]]

This cause can be different issues, first is the JSON is not right formatted, second, JSON have parameters that Zabbix can't handle. 

The first mistake is easy to find, as Postman checks the JSON syntax for errors. For example, in this way, there is a comma at a place where JSON don't need any. The comma is highlighted as well, is the rule highlighted in your request:

![[Pasted image 20221012135132.png]]

The second mistake is a little bit harder to find. In this case, my token is not between quotes. From a JSON perspective, this is not an issue, however Zabbix responds with the same error:

![[Pasted image 20221012135625.png]]

So if you get a JSON error, first check the syntax with the help of Postman, second, go and find the error in your request. 

## Add host to Zabbix
Now comes the fun and functional part, adding bulk hosts to Zabbix. You can set lots of options while adding hosts to Zabbix. Zabbix has also a well documented API, you can find all information here: https://www.zabbix.com/documentation/current/en/manual/api/reference 

First example is a basic add of a host without any variables (except environment vars).

```json
{
    "jsonrpc": "2.0",
    "method": "host.create",
    "params": {
        "host": "TEST-HOST",
        "interfaces": [
            {
                "type": 1,
                "main": 1,
                "useip": 1,
                "ip": "127.0.0.1",
                "dns": "",
                "port": "10050"
                }
        ],
        "groups": [
            {
                "groupid": "26"
            }
        ]
    },
    "auth": "{{token}}",
    "id": {{id}}
}
```

This will create a host with the name TEST-HOST, Interface is Agent type (1), monitoring based on IP, IP address 127.0.0.1 and agent port 10051. It's added to group 26, not templates or other config applied. 
When you post this command, you will get a reply that the host is created together with the host ID:
![[Pasted image 20221012134213.png]]

### How to find ID's?
If you want to import hosts, you need to apply a hostgroup and for example templates and probably point to a proxy server. There are 2 methods to find them. First find it in the frontend of Zabbix, second, find it with API requests. 

For example a hostgroup, go in Zabbix to Host Groups and hover over the group from which you will need the ID. Hover over the group, and you will see the Group ID:
![[Pasted image 20221012140331.png]]
Or open the Group and you will see the group ID in the URL:
![[Pasted image 20221012140421.png]]

The second method is to request all groups with an API request.

### Bulk add hosts to Zabbix
Postman has the ability to run over a list of comma separated values which it then turns to variables. This gives us the ability to import a bulk of hosts in Zabbix. 

First, we change our previous requests, so it points to variables where we have dynamic information about the host:
```json
{
    "jsonrpc": "2.0",
    "method": "host.create",
    "params": {
        "host": "{{hostname}}",
        "interfaces": [
            {
                "type": 1,
                "main": 1,
                "useip": 1,
                "ip": "{{ipaddress}}",
                "dns": "",
                "port": "10051"
                }
        ],
        "groups": [
            {
                "groupid": "26"
            }
        ]
    },
    "auth": "{{token}}",
    "id": {{id}}
}
```

In this case, we have changed the hostname and IP address to a variable. In Postman, always place a variable between curly brackets. 

Next, in your request, click the tab _test_ and add this script:
```Java
var jsonData = pm.response.json(); 
pm.test("Verify Json values", function () { 
    pm.expect(jsonData.result.hostids).not.eq(undefined);
});
```

![[Pasted image 20221012143710.png]]

This step is optional, however it gives you the ability to see if the host is added even if there was an error in the response from the Zabbix API.


Now we need a CSV file with all hosts and IP addresses we want to import. 
Example:
```csv
hostname,ipaddress
TEST-HOST1,10.10.10.1
TEST-HOST2,10.10.10.2
TEST-HOST3,10.10.10.3
TEST-HOST4,10.10.10.4
TEST-HOST5,10.10.10.5
```

Now in Postman, open a new Runner Tab. Under file -> New Runner Tab (or useCtrl+Shift+R).
You can now drag your request to the RUN ORDER.
(if multiple requests apprear in the RUN ORDER field, you can Deselect All and select only the request you need. In this case, we don't need to authenticate anymore. Postman by default works with groups of requests.)

![[Pasted image 20221012143200.png]]

In the right pane, select your CSV file. Click Preview to see if the values are as expected:

![[Pasted image 20221012144541.png]]

Click on Advanced and select "Save responses" this gives you the ability to debug. 
Now you can click the Run button and all hosts from the CSV will be imported.

Because we have added a test, Postman returns now 5 successfully POST requests where the hosts were added. Also note that we have saved the responses so can look back what was successful: 

![[Pasted image 20221012153418.png]]

## Hints
When creating requests, I sometimes ran into the issue that I don't know how to add some parameters, for example when configuring a host interface. A good practice is to add the hosts in the Zabbix web interface and then read the configuration of the host via the API. You then will see how it's configured. 

