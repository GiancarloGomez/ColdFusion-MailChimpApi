# ColdFusion-MailChimpApi
ColdFusion CFC for MailChimp 3.0 API

### Methods

* __public struct function getApi()__  
  Get links to all other resources available in the API and details about the MailChimp User account.<br />
  http://developer.mailchimp.com/documentation/mailchimp/reference/root/
* __public struct function lists()__  
  Get information about all lists (main wrapper for subcalls)  
* __public struct function list()__  
  Get information about a specific list
* __public struct function listCreate()__  
  Create a new list<br />
  http://developer.mailchimp.com/documentation/mailchimp/reference/lists/#create-post_lists
* __public struct function listUpdate()__  
  Update the settings for a specific list
* __public struct function listDelete()__  
  Delete a list
* __public struct function listBatchUpdate()__  
  Batch subscribe or unsubscribe list members
  http://developer.mailchimp.com/documentation/mailchimp/reference/lists/#create-post_lists_list_id
* __public struct function members()__  
  Get information about members in a list (main wrapper for subcalls)
* __public struct function member()__  
  Get information about a specific list member, including a currently subscribed, unsubscribed, or bounced member.
  http://developer.mailchimp.com/documentation/mailchimp/reference/lists/members/#read-get_lists_list_id_members_subscriber_hash
* __public struct function memberCreate()__  
  Add a new member to the list
* __public struct function memberUpdate()__  
  Update information for a specific list member
* __public struct function memberDelete()__  
  Delete a member from a list
* __private string function prepareParameters()__
  Prepare URL parameters to pass in call
* __private struct function sendCall()__  
  Prepare and send call to MailChimp API


### How to use

```javascript
// create new instance
mc = new MailChimpApi(
	apiKey : "YOUR API KEY",
	apiUrl : "https://<dc>.api.mailchimp.com/3.0/"
);
```
To learn how to get your API Key and URL read <a href="http://developer.mailchimp.com/documentation/mailchimp/guides/get-started-with-mailchimp-api-3/" target="blank">Get Started with the MailChimp API</a>

```javascript
// Get API Root
mc.getApi();
```

__Working With Lists__
```javascript
// Get Lists
mc.lists(exclude_fields:"_links,lists._links");

// The call also accepts all parameters accepted by the API
// In this call we exclude the _links values at root and within the lists and only want the top 2
mc.lists(exclude_fields:"_links,lists._links",count:2);

/* ==========================================================================
* CREATE EXAMPLE
* if using ColdFusion 2016 you can use the setMetaData function
* to make sure Zip is not converted to number. In this example
* I added a -0000 to the end of it or you can add a space before
* to keep it as a string when using serializeJSON()
========================================================================== */

// Prepare a JSON object using a ColdFusion struct, the structure is detailed in the MailChimp API documentation
newList = {
  "name" : "My created list",
  "contact" : {
    "company"  : "ABC Company",
    "address1" : "125 Main Ave",
    "city"     : "Anywhere",
    "state"    : "FL",
    "country"  : "US",
    "zip"      : "33012-0000",
    "phone"    : "305-555-5555"
  },
  "permission_reminder" : "You signed up for this type of communication from us!",
  "use_archive_bar"     : true,
  "campaign_defaults"   : {
    "from_name"  : "ABC Company",
    "from_email" : "abc@fusedevelopments.com",
    "subject"    : "An email from ABC Company / Fuse Developments",
    "language"   : "English"
  },
  "notify_on_subscribe"   : "giancarlo.gomez@gmail.com",
  "notify_on_unsubscribe" : "giancarlo.gomez@gmail.com",
  "email_type_option"     : false,
  "visibility"            : "prv"
};

mc.listCreate(body:serializeJSON(newList));

/* ==========================================================================
* UPDATE EXAMPLE
* Using the same struct above we simply want to update the name
* This will require you to have a valid list ID which is returned from the create
* function
========================================================================== */
newList.name = "This is a better name for my list";
mc.listUpdate(listID:"THE LIST ID",body:serializeJSON(newList));

/* ==========================================================================
* BATCH UPDATE EXAMPLE
* Easily add or update a batch of members to a list
* MailChimp has a limit of 500 members per call
========================================================================== */
data = {
  "members" :[
    {
      "email_address" : "user_1@thisisatest.com",
      "status"        : "subscribed",
      "merge_fields"  : {
        "FNAME" : "User",
        "LNAME" : "One"
      }
    },
	{
 	 "email_address" : "user_2@thisisatest.com",
 	 "status"        : "subscribed",
 	 "merge_fields"  : {
 	   "FNAME" : "User",
 	   "LNAME" : "Two"
 	 }
    }
  ],
  "update_existing": true
};

mc.listBatchUpdate(listID:"THE LIST ID",body:serializeJSON(data));

// DELETE EXAMPLE
mc.listDelete(listID:"THE LIST ID");
```

__Working With Members__
```javascript

// Get all Members in a list
mc.members(listID:"THE LIST ID");

// Get a member from a list
mc.member(listID:"THE LIST ID",email:"user_1@thisisatest.com");

// CREATE EXAMPLE
// Prepare a JSON object using a ColdFusion struct, the structure is detailed in the MailChimp API documentation
newMember = {
  "email_address" : "user_3@thisisatest.com",
  "status"        : "subscribed",
  "merge_fields"  : {
    "FNAME" : "User",
    "LNAME" : "Three"
  }
};

mc.memberCreate(listID:"THE LIST ID",body:serializeJSON(newMember));

// UPDATE EXAMPLE
newMember.merge_fields.FNAME = "John";
newMember.merge_fields.LNAME = "Doe";
mc.memberUpdate(listID:"THE LIST ID",email:newMember.email_address,body:serializeJSON(newMember)));

// DELETE EXAMPLE
mc.memberDelete(listID:"THE LIST ID",email:newMember.email_address);
```
