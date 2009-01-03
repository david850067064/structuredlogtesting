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

package com.structuredlogs.connection
{
import com.structuredlogs.events.LogHandlerEvent;

import flash.events.EventDispatcher;
import flash.net.LocalConnection;
import flash.utils.ByteArray;

/**
 *  Dispatched when a message is received over the LocalConnection.
 *
 *  @eventType com.structuredlogs.events.LogHandlerEvent.UPDATE
 */
[Event(name="update", type="com.structuredlogs.events.LogHandlerEvent")]

/**
 * 	Class that encapsulates the functionality to receive SLog
 *  message sent by StructuredLogTarget.
 */
public class SLogLocalConnection extends EventDispatcher
{

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function SLogLocalConnection() 
    {
		super();
    }
    
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var connection:LocalConnection;
    
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 * 	Start listening on the local connection for SLog messages.
	 */
	public function start():void
	{
		if (!connection)
			resetConnection(true);
	}
	
	/**
	 * 	Stop listening on the local connection for SLog messages.
	 */
	public function stop():void
	{
		if (connection)
			resetConnection(false);
	}

	/**
	 * 	@private
	 * 	Switches the local connection on or off.
	 */
	private function resetConnection(onOff:Boolean):void
    {
    	try
    	{
        	if (onOff)
        	{
        		connection = new LocalConnection();
        		connection.allowDomain("*");
        		connection.client = this;
        		connection.connect("_slog");
        	}
        	else
        	{
        		if (connection)
        		{
        			connection.close();
        			connection = null;
        		}
        	}
        }
        catch (error:Error)
        {
        	connection = null;
        }
    }

	/**
	 * 	Method called by StructuredLogTarget to receive messages from SLog.
	 */
    public function logHandler(message:ByteArray, identifier:String):void
    { 
    	dispatchEvent(new LogHandlerEvent(message.readObject(), identifier));
    }
    
}
}