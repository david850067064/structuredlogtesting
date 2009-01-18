/*
Copyright (c) 2009 Renaun Erickson (http://renaun.com, http://structuredlogs.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/
package com.structuredlogs.targets
{

import com.structuredlogs.events.SLogEvent;
import com.structuredlogs.events.SLogEventLevel;
import com.structuredlogs.utils.JSON;

import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import mx.logging.ILogger;

/**
 *  Provides a logger target that outputs to a <code>LocalConnection</code>,
 *  connected to the Debug application.
 */
public class RemoteSLogTarget extends LineFormattedTarget
{

	//--------------------------------------------------------------------------
	//
	//  Constant
	//
	//--------------------------------------------------------------------------

	/**
	 * 	Success status of log submission.
	 */
	public static const SUCCESS:String = "success";
	
	/**
	 * 	Progress status of log submission.
	 */
	public static const PROGRESS:String = "progress";
	
	/**
	 * 	Failure status of log submission.
	 */
	public static const FAILURE:String = "failure";
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
     *  Constructor.
	 *
	 *  <p>Constructs an instance of a logger target that will send
	 *  the log data to the Debug application.</p>
     */
    
    public function RemoteSLogTarget() 
	{
		super();
        clearHistory();

        // Turn On Logger
        includeDate = true;
        includeCategory = true;
        includeLevel = true;
        includeTime = true;
        
        callbacks = new Dictionary(true);
    }

	//--------------------------------------------------------------------------
	//
	//  Private
	//
	//--------------------------------------------------------------------------

    private var pendingLog:Array;
    
    private var callbacks:Dictionary;
    
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

    /**
     *  The log history data collection.
     */
    public var logHistory:Array;

    /**
     *  The maximum log statements to store in the history.
     *  @default 50000
     */
    public var max:int = 50000;

    /**
     *  The number logs sent at a time.
     *  @param int 2000
     */
    public var submitCount:int = 2000;

    /**
     *  The log statement separator string used when toString() is called.
     *  
     *  @default \n 
     */
    public var separator:String = "\n";


	//--------------------------------------------------------------------------
	//  captureURL
	//--------------------------------------------------------------------------

	private var _captureURL:String = "/slog/remote/";
	
	[Bindable]
	/**
	 * 	The remote capture url.  This url is set a http request with the post paramerters:
	 * 	instanceID 	= The identifier for this log instance.
	 * 	log 		= The log data in a JSON format.
	 *  submitter 	= (optional) The person's name that submitted the log.
	 * 	note 		= A note to go with the log data.
	 */
	public function get captureURL():String
	{
		return _captureURL;
	}
	public function set captureURL(value:String):void
	{
		_captureURL = value;
	}

	//--------------------------------------------------------------------------
	//  identifier
	//--------------------------------------------------------------------------

	private var _identifier:String = "default";
	
	[Bindable]
	/**
	 * 	Application specific identifier. Typically set with a
	 *  username or user specific bit of information.
	 */
	public function get identifier():String
	{
		return _identifier;
	}
	public function set identifier(value:String):void
	{
		if (value == "")
			value = "default";
		_identifier = value;
	}

	//--------------------------------------------------------------------------
	//  developer
	//--------------------------------------------------------------------------

	private var _developer:String = "";
	
	[Bindable]
	/**
	 * 	Developer
	 */
	public function get developer():String
	{
		return _developer;
	}
	public function set developer(value:String):void
	{
		_developer = value;
	}

	//--------------------------------------------------------------------------
	//  note
	//--------------------------------------------------------------------------

	private var _note:String = "";
	
	[Bindable]
	/**
	 * 	Note
	 */
	public function get note():String
	{
		return _note;
	}
	public function set note(value:String):void
	{
		_note = value;
	}

	//--------------------------------------------------------------------------
	//  secretKey
	//--------------------------------------------------------------------------

	private var _secretKey:String;
	// Used if _secretKey is null
	private var internalSecretKey:String = "01400f616b12e8b4ca13fa767a1c89d9";
	
	[Bindable]
	/**
	 * 	Application specific identifier. Typically set with a
	 *  username or user specific bit of information.
	 */
	public function get secretKey():String
	{
		return _secretKey;
	}
	public function set secretKey(value:String):void
	{
		_secretKey = value;
	}

	//--------------------------------------------------------------------------
	//  instanceID
	//--------------------------------------------------------------------------
    
    private var _instanceID:String;
	
	/**
	 * 	The unique idenitifer generated by the target to use as a reference between
	 *  the client submitting the log and the remote data.
	 */
	public function get instanceID():String
	{
		return _instanceID;
	}
	private function setInstanceID(value:String):void
	{
		if (value == "")
			value = "default";
		_instanceID = value;
	}
	public function resetInstanceID():void
	{
		_instanceID = null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *	Clear history object
	 */
	public function clearHistory():void
	{
		logHistory = new Array();
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

    /**
     *  Override to send the data in the format of XPanel
     */
    override public function logEvent(event:SLogEvent):void
    {
    	var date:Date = new Date();
    	if (!instanceID)
    	{
			var randomNum:Number = Math.floor(Math.random()*(0xffffffff));
			var randomNum2:Number = Math.floor(Math.random()*getTimer());
			// Since getTime() is just milleseconds from 1970, I went ahead and brought it up to 20080129.  This
			// was done to make the tag size smaller but still give it more uniqueness confindence.
			var randomString:String = randomNum.toString(36) + (date.getTime()-1201640391598).toString(36) + randomNum2.toString(36);    		
    		setInstanceID(randomString);
    	}
    	
		var level:int = event.level;    	
		if (event.level == SLogEventLevel.ALL)
			level = 1;

		var dateString:String = "";
    	if (includeDate || includeTime)
    	{
    		var date1:String = "";
    		var date2:String = "";
    		var d:Date = date;
    		if (includeDate)
    		{
    			date1 = Number(d.getUTCMonth() + 1).toString() + "/" +
					   d.getUTCDate().toString() + "/" + 
					   d.getUTCFullYear();
    		}	
    		if (includeTime)
    		{
    			date2 = pad(d.getUTCHours()) + ":" +
					   pad(d.getUTCMinutes()) + ":" +
					   pad(d.getUTCSeconds()) + "." +
					   d.getUTCMilliseconds();
					   
    		}
    		dateString = date1 + " " + date2 + " " + (d.getTimezoneOffset()/60);
    	}

 		var category:String = includeCategory ?
							  ILogger(event.target).category + fieldSeparator :
							  "";
		
		var logObject:Object = new Object();
		logObject.timer = getTimer();
		logObject.date = dateString;
		logObject.category = category;
		logObject.message = event.message;
		logObject.level = level;
		logObject.identifier = identifier;
		logObject.instanceID = instanceID;
		
		if (logHistory.length > max)
			logHistory.shift();
			
		logHistory.push(logObject);		  
    }    

    /**
	 *  @private
	 */
	private function pad(num:Number, str:String = "0"):String
    {
        return num > 9 ? num.toString() : str + num.toString();
    } 

    public function toTextString(data:Array = null):String
    {
    	if (data == null)
    		data = logHistory.toArray();
    	var str:String = "";
    	for (var i:int = 0; i < data.length; i++)
    	{
    		str += pad(data[i].level, " ") + " ["+data[i].date+"]" + data[i].category + " " + data[i].message + separator;
    	}
    	return str;
    }

	/**
	 * 	A big string with one encoded JSON object per line
	 */
	public function toJSONString(data:Array = null):String
    {
    	if (data == null)
    		data = logHistory;
    	var str:String = "";
    	for (var i:int = 0; i < data.length; i++)
    	{
    		var json:JSON = new JSON();
    		str += json.encode(data[i]) + separator;
    	}
    	return str;
    }  

	/**
	 * 	Send the log to the remote capture endpoint.
	 * 
	 * 	instanceID 	= The identifier for this log instance.
	 * 	log 		= The log data in a JSON format.
	 *  submitter 	= (optional) The person's name that submitted the log.
	 * 	note 		= A note to go with the log data.
	 */
	public function sendLog(callback:Function):void
    {
    	if (logHistory.length == 0 || instanceID == null)
    	{
    		if (callback != null)
    			callback("success no log");
    		return;
    	}
    	if (!pendingLog)
    		pendingLog = new Array();
    	
    	var addArray:Array = logHistory.toArray();
    	for (var j:int = 0; j < addArray.length; j++)
    		pendingLog.push(addArray[j]);
    	clearHistory();
    	
    	sendPendingLogs(callback);
    }
    
    private function sendPendingLogs(callback:Function):void
    {
    	callback(RemoteSLogTarget.PROGRESS, pendingLog.length);
    	
    	var spliceLength:int = Math.min(submitCount, pendingLog.length);
    	var logData:String = toJSONString(pendingLog.splice(0, spliceLength));
   		var service:URLLoader = new URLLoader();
   		service.addEventListener(Event.COMPLETE, completeHandler);
   		service.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
   		service.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
   		
   		callbacks[service] = callback;

		var urlRequest:URLRequest = new URLRequest(captureURL);
        urlRequest.method = URLRequestMethod.POST;

        var variables:URLVariables = new URLVariables();
        variables.instanceID 	= instanceID;
        variables.log 			= logData;
        variables.developer 	= developer;
        variables.identifier 	= identifier;
        variables.note 			= note;
        //variables.salt 			= ((new Date()).getTime()).toString(36);
        //variables.hash			= MD5.hash(instanceID + "" + variables.salt + "" + ((secretKey == null) ? internalSecretKey : secretKey));
        urlRequest.data = variables;    	
    	
    	service.load(urlRequest);
    }
    
    // Default Submit window

    /**
    public function remoteCaptureDialog():void
    {
    	var window:RemoteRIALoggerWindow = PopUpManager.createPopUp(Application.application as DisplayObject, RemoteRIALoggerWindow, false) as RemoteRIALoggerWindow;
    	PopUpManager.centerPopUp(window);
    	window.target = this;
    	window.lblInstanceID.text = instanceID;
    }
    * */
    
    private function completeHandler(event:Event):void
    {
    	var callback:Function;
    	var loader:URLLoader = event.target as URLLoader;
    	if (callbacks[loader] != null)
    		callback = callbacks[loader];
    	
    	delete callbacks[loader];
    		
    	if (pendingLog.length > 0)
    	{
    		sendPendingLogs(callback);
    		return;
    	}
    	
    	var xml:XML = new XML(loader.data);
    	if (callback != null)
    	{
    		if (xml.data.@type == "error")
    			callback(xml.data.toString());
    		else
    		{
    			callback(RemoteSLogTarget.SUCCESS);
    		}
    	}
    }
    
    private function errorHandler(event:Event):void
    {
    	var callback:Function;
    	var loader:URLLoader = event.target as URLLoader;
    	if (callbacks[loader] != null)
    		callback = callbacks[loader];
    	
    	delete callbacks[loader];
    		
    	if (pendingLog.length > 0)
    	{
    		sendPendingLogs(callback);
    		return;
    	}
    		    	
    	if (callback != null)
    		callback(RemoteSLogTarget.FAILURE);
    }
    
    public function toString():String
    {
    	return "RemoteSLogTarget[" + this.id + "]";
    }
}
}