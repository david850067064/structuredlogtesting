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

import com.structuredlogs.data.StructuredLog;
import com.structuredlogs.events.SLogEvent;
import com.structuredlogs.events.SLogEventLevel;

import flash.events.StatusEvent;
import flash.events.TimerEvent;
import flash.net.LocalConnection;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.getTimer;

import mx.logging.ILogger;

/**
 *  The StructuredLogTarget sends messages containing an AMF representation of an Array
 *  of StructuredLog objects over a LocalConnection.  The connection string is "_slog" 
 * 	the LocalConnection method that is called is "logHandler".
 */
public class StructuredLogTarget extends BaseTarget
{

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function StructuredLogTarget() 
    {
		super();
		lc = new LocalConnection();
        lc.addEventListener(StatusEvent.STATUS, statusEventHandler);
        connection = "_slog";
        method = "logHandler";
        _identifier = "default";
        
        timer.addEventListener(TimerEvent.TIMER_COMPLETE, send);
    }
    
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var lc:LocalConnection;
    
    /**
     *  @private
     *  The name of the method to call on the Debug application connection.
     */
    private var method:String;

    /**
     *  @private
     *  The name of the connection string to the Debug application.
     */
    private var connection:String;    

	/**
	 * 	@private
	 */
	private var messageBytes:ByteArray = new ByteArray();
	
	/**
	 * 	@private
	 */
	private var lastMessageTime:Number;
	
	
	/**
	 * 	@private
	 */
	private var currentMessageByteCount:Number = 0;
	
	/**
	 * 	@private
	 * 	Check in 50 ms if no logs have been sent, then make call.
	 */
	private var timer:Timer = new Timer(50,1);

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	private var _identifier:String;
	
	[Bindable]
	/**
	 * 	Identifier for the log, used to group log sessions
	 */
	public function get identifier():String
	{
		return _identifier;
	}
	/**
	 * 	@private
	 */
	public function set identifier(value:String):void
	{
		if (value == "")
			value = "default";
		_identifier = value;
	}

	//--------------------------------------------------------------------------
	//
	//  EventListener
	//
	//--------------------------------------------------------------------------

    private function statusEventHandler(event:StatusEvent):void 
    {
        //trace("statusEventHandler: " + event.code);
    }


	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	/**
	 * 	Override the Event levels to work with each debug application correctly
	 */	
    override public function logEvent(event:SLogEvent):void
    {
		var level:int = event.level;    	
		if (event.level == SLogEventLevel.ALL)
			level = 1;

		var logObject:StructuredLog = new StructuredLog();
    	logObject.datetime = new Date();
    	logObject.category = ILogger(event.target).category;
    	logObject.level = level;
    	logObject.message = event.message;
    	logObject.identifier = identifier;
		
		//var messageBytes:ByteArray = new ByteArray();
		messageBytes.writeObject(logObject);
		//currentMessageByteCount += messageBytes.length;

		lastMessageTime = getTimer();
		// This is keeping the objects arround... need to not store in array
		// Also maybe use on instance of StructuredLog() and just overwrite and write to
		// bytes to save on memory
		//messages.push(logObject);
		send();
		if (!timer.running)
			timer.start();
    }
    
    /**
     *	Try and send messages unless there are more logs coming, then
     *  buffer the messages to send later. 
     * 
     * 	<p>Sends data over LocalConnection "_slog" calling 
     * 	loginHandler(messageBytes, identifier).
     *  </p>
     */
    private function send(event:Event = null):void
    {
    	try
    	{
    		var eventFlag:Boolean = (event != null);
    		
    		if (event != null && (getTimer() - lastMessageTime) < 50)
    		{
    			timer.reset();
    			timer.start();
    			eventFlag = false;
    		}
    		
    		if (messageBytes.length > 30000 || eventFlag)
    		{
    			//var messageBytes:ByteArray = new ByteArray();
    			//messageBytes.writeObject(messages);
    			
	    		lc.send(connection, method, messageBytes, identifier);
	    		messageBytes.clear();
	    	}
	    }
	    catch (error:Error) 
	    {
        	//trace("LocalConnection Error: " + error.message);
	    }
    }  
    
    /**
     * 
     */
    public function toString():String
    {
    	return "StructuredLogTarget[" + this.id + "]";
    }
}
}