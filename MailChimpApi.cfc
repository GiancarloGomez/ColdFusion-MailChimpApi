/**
* @author   Giancarlo Gomez <giancarlo.gomez@gmail.com>
* @version  0.0.1-alpha
*
* Most calls in this CFC are direct references to the MailChimp 3.0 API
* It is still a work in progress as not all endpoints are coded for due to
* me not requiring in my own development
*/
component output="false" accessors="true"
{
    property name="timestamp"   type="date";
    property name="apiUrl"      type="string";
    property name="endPoint"    type="string";

    public any function init(
        required string apiKey,
        required string apiUrl
    ){
        // set the time stamp on init
        setTimeStamp(now());
        // set the api key on init from config or passed in value
        setApiKey(arguments.apiKey);
        setApiUrl(arguments.apiUrl);
    }

    /**
    * Get links to all other resources available in the API and details about the MailChimp User account.
    *
    * http://developer.mailchimp.com/documentation/mailchimp/reference/root/
    *
    * @fields A comma-separated list of fields to return. Reference parameters of sub-objects with dot notation.
    * @exclude_fields A comma-separated list of fields to exclude. Reference parameters of sub-objects with dot notation.
    */
    public struct function getApi(
        string fields = "",
        string exclude_fields = ""
    ){
        var path = prepareParameters(arguments);
        // call service and return struct
        return sendCall(path:path);
    }

    /* ==========================================================================
    LISTS
    ========================================================================== */

        /**
        * Get information about all lists (main wrapper for subcalls)
        *
        * http://developer.mailchimp.com/documentation/mailchimp/reference/lists/
        *
        * @method HTTP Method to pass to sendCall()
        * @fields A comma-separated list of fields to return. Reference parameters of sub-objects with dot notation.
        * @exclude_fields A comma-separated list of fields to exclude. Reference parameters of sub-objects with dot notation.
        * @count The number of records to return.
        * @offset The number of records from a collection to skip. Iterating over large collections with this parameter can be slow.
        * @before_date_created Restrict response to lists created before the set date. (UTC)
        * @since_date_created Restrict results to lists created after the set date. (UTC)
        * @before_campaign_last_sent Restrict results to lists created before the last campaign send date. (UTC)
        * @since_campaign_last_sent Restrict results to lists created after the last campaign send date. (UTC)
        * @email Restrict results to lists that include a specific subscriber’s email address.
        * @callPath Addition to path sent in from sub calls
        * @body The content to pass to the sendCall() function to set as body
        */
        public struct function lists(
            string method = "GET",
            string fields = "",
            string exclude_fields = "",
            numeric count,
            numeric offset,
            date before_date_created,
            date since_date_created,
            date before_campaign_last_sent,
            date since_campaign_last_sent,
            string email,
            string callPath,
            string body = ""
        ){
            var path =  "lists" &
                        (structKeyExists(arguments,"callPath") && len(arguments.callPath) ? arguments.callPath : "") &
                        prepareParameters(data:arguments,excludeKeys:"method,callPath,body");
            // call service and return struct
            return sendCall(path:path,method:arguments.method,body:arguments.body);
        }

        /**
        * Get information about a specific list
        * Refer to getLists for full set of parameters that can be passed
        *
        * http://developer.mailchimp.com/documentation/mailchimp/reference/lists/#read-get_lists_list_id
        *
        * @listID List ID to fetch
        */
        public struct function list(
            required string listID
        ){
            var params = structCopy(arguments);
            // delete the listID parameter and set it as callPath required by list call
            structDelete(params,"listID");
            // set callPath
            params.callPath = "/" & arguments.listID;
            // call service and return struct
            return lists(argumentCollection:params);
        }

        /**
        * Create a new list
        * Refer to MailChimp API docs for JSON values
        *
        * http://developer.mailchimp.com/documentation/mailchimp/reference/lists/#create-post_lists
        *
        * @body JSON body content
        */
        public struct function listCreate(
            required string body
        ){
            var params = {
                method  : "POST",
                body    : arguments.body
            };
            // call service and return struct
            return lists(argumentCollection:params);
        }

        /**
        * Update the settings for a specific list
        *
        * @listID List ID to delete
        * @body JSON body content
        */
        public struct function listUpdate(
            required string listID,
            required string body
        ){
            var params = {
                method      : "PATCH",
                body        : arguments.body,
                callPath    : "/" & arguments.listID
            };
            // call service and return struct
            return lists(argumentCollection:params);
        }

        /**
        * Delete a list
        *
        * @listID List ID to delete
        */
        public struct function listDelete(
            required string listID
        ){
            var params = {
                method      : "DELETE",
                callPath    : "/" & arguments.listID
            };
            // call service and return struct
            return lists(argumentCollection:params);
        }

        /**
        * Batch subscribe or unsubscribe list members.
        * Refer to MailChimp API docs for JSON values
        *
        * http://developer.mailchimp.com/documentation/mailchimp/reference/lists/#create-post_lists_list_id
        *
        * @listID List ID to batch update
        * @body JSON body content
        */
        public struct function listBatchUpdate(
            required string listID,
            required string body
        ){
            var params = {
                method      : "POST",
                callPath    : "/" & arguments.listID,
                body        : arguments.body
            };
            // call service and return struct
            return lists(argumentCollection:params);
        }

    /* ==========================================================================
    MEMBERS
    ========================================================================== */

        /**
        * Get information about members in a list (main wrapper for subcalls)
        *
        *http://developer.mailchimp.com/documentation/mailchimp/reference/lists/members/
        *
        * @listID The unique id for the list
        * @method HTTP Method to pass to sendCall()
        * @fields A comma-separated list of fields to return. Reference parameters of sub-objects with dot notation.
        * @exclude_fields A comma-separated list of fields to exclude. Reference parameters of sub-objects with dot notation.
        * @count The number of records to return.
        * @offset The number of records from a collection to skip. Iterating over large collections with this parameter can be slow.
        * @email_type The email type.
        * @status The subscriber’s status.
        * @since_timestamp_opt Restrict results to subscribers who opted-in after the set timeframe. (UTC)
        * @before_timestamp_opt Restrict results to subscribers who opted-in before the set timeframe. (UTC)
        * @since_last_changed Restrict results to subscribers whose information changed after the set timeframe. (UTC)
        * @before_last_changed Restrict results to subscribers whose information changed before the set timeframe. (UTC)
        * @unique_email_id A unique identifier for the email address across all MailChimp lists.
        * @vip_only A filter to return only the list’s VIP members. Passing true will restrict results to VIP list members, passing false will return all list members.
        * @interest_category_id The unique id for the interest category.
        * @interest_ids Used to filter list members by interests. Must be accompanied by interest_category_id and interest_match. The value must be a comma separated list of interest ids present for the given interest category.
        * @interest_match Used to filter list members by interests. Must be accompanied by interest_category_id and interest_ids. “any” will match a member with any of the interest supplied, “all” will only match members with every interest supplied, and “none” will match members without any of the interest supplied.
        * @callPath Addition to path sent in from sub calls
        * @body The content to pass to the sendCall() function to set as body
        */
        public struct function members(
            string method = "GET",
            string fields = "",
            string exclude_fields = "",
            numeric count,
            numeric offset,
            string email_type,
            string status,
            date since_timestamp_opt,
            date before_timestamp_opt,
            date since_last_changed,
            date before_last_changed,
            string unique_email_id,
            boolean vip_only,
            string interest_category_id,
            string interest_ids,
            string interest_match,
            string callPath,
            string body = ""
        ){
            var path =  "lists/" & arguments.listID & "/members" &
                        (structKeyExists(arguments,"callPath") && len(arguments.callPath) ? arguments.callPath : "") &
                        prepareParameters(data:arguments,excludeKeys:"method,listID,body");
            // call service and return struct
            return sendCall(path:path,method:arguments.method,body:arguments.body);
        }

        /**
        * Get information about a specific list member, including a currently subscribed, unsubscribed, or bounced member.
        *
        * http://developer.mailchimp.com/documentation/mailchimp/reference/lists/members/#read-get_lists_list_id_members_subscriber_hash
        *
        * @listID The unique id for the list
        * @email The email to work with (transformed to a lowercase MD5 hash in function)
        */
        public struct function member(
            required string listID,
            required string email
        ){
            var params = structCopy(arguments);
            // delete the email parameter and set to callPath
            structDelete(params,"email");
            // set callPath
            params.callPath = "/" & hash(arguments.email,"MD5").toLowerCase();
            // call service and return struct
            return members(argumentCollection:params);
        }

        /**
        * Add a new member to the list
        *
        * @listID The unique id for the list
        * @body JSON body content
        */
        public struct function memberCreate(
            required string listID,
            required string body
        ){
            var params = {
                method      : "POST",
                listID      : arguments.listID,
                body        : arguments.body
            };
            // call service and return struct
            return members(argumentCollection:params);
        }

        /**
        * Update information for a specific list member
        *
        * @listID The unique id for the list
        * @email The email to work with (transformed to a lowercase MD5 hash in function)
        * @body JSON body content
        * @updateOnly This call allows to add or update only, by default we allow both - set to true to only update
        */
        public struct function memberUpdate(
            required string listID,
            required string email,
            required string body,
            boolean updateOnly = false
        ){
            var params = {
                method      : arguments.updateOnly ? "PATCH" : "PUT",
                callPath    : "/" & hash(arguments.email,"MD5").toLowerCase(),
                listID      : arguments.listID,
                body        : arguments.body
            };
            // call service and return struct
            return members(argumentCollection:params);
        }

        /**
        * Delete a member from a list
        *
        * @listID The unique id for the list
        * @email The email to work with (transformed to a lowercase MD5 hash in function)
        */
        public struct function memberDelete(
            required string listID,
            required string email
        ){
            var params = {
                method      : "DELETE",
                callPath    : "/" & hash(arguments.email,"MD5").toLowerCase(),
                listID      : arguments.listID
            };
            // call service and return struct
            return members(argumentCollection:params);
        }

    /* ==========================================================================
    PRIVATE
    ========================================================================== */

        /**
        * Prepare URL parameters to pass in call
        *
        * @data A structure of data to loop thru and return as query parameters
        * @keys Specific keys to work with, if not all keys are evaluated
        * @excludeKeys Specific keys to exclude
        */
        private string function prepareParameters(
            required struct data,
            string keys = "",
            string excludeKeys = ""
        ){
            var _keys     = len(arguments.keys) ? arguments.keys.toLowerCase() : arguments.data.keyList().toLowerCase();
            var _key     = "";
            var params     = [];
            var pos     = 0;
            // delete any key that should not be evaluated
            for (_key in arguments.excludeKeys){
                pos = _keys.listFindNoCase(_key);
                if (pos)
                    _keys = _keys.listDeleteAt(pos);
            }
            // loop thru the keys and only work with simple ones that contain a value
            for (_key in _keys){
                if (structKeyExists(arguments.data, _key) && isSimpleValue(arguments.data[_key]) && len(arguments.data[_key])){
                    if (isDate(arguments.data[_key]))
                        params.append(_key & "=" & dateTimeFormat(arguments.data[_key],"yyyy-mm-dd hh:mm:ss"));
                    else
                        params.append(_key & "=" & arguments.data[_key]);
                }
            }
            // prepare and return final params to pass
            return params.len() ? "?" & params.toList("&") : "";
        }

        /**
        * Prepare and send call to MailChimp API
        */
        private struct function sendCall(
            string path     = "",
            string method   = "GET",
            string body     = ""
        ){
            var response     = {
                success     : false,
                statusCode  : "",
                message     : "",
                data        : {}
            };
            var httpService = new http(
                url         : getApiUrl() & arguments.path,
                method      : arguments.method,
                username    : "dfa",
                password    : getApiKey()
            );
            var httpResponse = {};
            // add body if one is set
            if (len(arguments.body))
                httpService.addParam(type:"body",value:arguments.body);
            // send response and set response
            httpResponse        = httpService.send().getPrefix();
            response.statusCode = httpResponse.statuscode;
            // deletes return 204 no content and good calls return 200ok
            response.success    = listFindNoCase("204 No Content,200 OK",response.statuscode) ? true : false;
            // attempt to deserialize response
            try{
                if (len(httpResponse.fileContent) && isJSON(httpResponse.fileContent))
                    response.data = deserializeJSON(httpResponse.fileContent);
            }
            catch (any e){
                response.message = e.message;
            }
            // pass in erro message from mailchimp detail
            if (!response.success && !len(response.message) && structKeyExists(response.data,"detail"))
                response.message = response.data.detail;
            // return struct
            return response;
        }

}