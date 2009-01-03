////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
/*
MODIFICATIONS Under Any Previous Licenses
Modified (c) 2009 Renaun Erickson (http://renaun.com, http://structuredlogs.com)
*/

package com.structuredlogs
{

import com.structuredlogs.events.SLogEvent;
import com.structuredlogs.events.SLogEventLevel;

import flash.events.EventDispatcher;

import mx.logging.ILogger;

/**
 *  The logger that is used within the logging framework.
 *  This class dispatches events for each message logged using the <code>log()</code> method.
 */
public class SLogLogger extends EventDispatcher implements ILogger
{

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
         *
         *  @param category The category for which this log sends messages.
	 */
	public function SLogLogger(category:String)
	{
		super();

		_category = category;
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  category
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the category property.
	 */
	private var _category:String;

	/**
	 *  The category this logger send messages for.
	 */	
	public function get category():String
	{
		return _category;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @inheritDoc
	 */	
	public function log(level:int, msg:String, ... rest):void
	{
		// we don't want to allow people to log messages at the 
		// Log.Level.ALL level, so throw a RTE if they do
		if (level < SLogEventLevel.DEBUG)
		{
        	throw new Error("Level must be greater then SLogEvent.ALL");
		}
        	
		if (hasEventListener(SLogEvent.LOG))
		{
			// replace all of the parameters in the msg string
			for (var i:int = 0; i < rest.length; i++)
			{
				msg = msg.replace(new RegExp("\\{"+i+"\\}", "g"), rest[i]);
			}

			dispatchEvent(new SLogEvent(msg, level));
		}
	}

	/**
	 *  @inheritDoc
	 */	
	public function debug(msg:String, ... rest):void
	{
		if (hasEventListener(SLogEvent.LOG))
		{
			// replace all of the parameters in the msg string
			for (var i:int = 0; i < rest.length; i++)
			{
				msg = msg.replace(new RegExp("\\{"+i+"\\}", "g"), rest[i]);
			}

			dispatchEvent(new SLogEvent(msg, SLogEventLevel.DEBUG));
		}
	}

	/**
	 *  @inheritDoc
	 */	
	public function error(msg:String, ... rest):void
	{
		if (hasEventListener(SLogEvent.LOG))
		{
			// replace all of the parameters in the msg string
			for (var i:int = 0; i < rest.length; i++)
			{
				msg = msg.replace(new RegExp("\\{"+i+"\\}", "g"), rest[i]);
			}

			dispatchEvent(new SLogEvent(msg, SLogEventLevel.ERROR));
		}
	}

	/**
	 *  @inheritDoc
	 */	
	public function fatal(msg:String, ... rest):void
	{
		if (hasEventListener(SLogEvent.LOG))
		{
			// replace all of the parameters in the msg string
			for (var i:int = 0; i < rest.length; i++)
			{
				msg = msg.replace(new RegExp("\\{"+i+"\\}", "g"), rest[i]);
			}

			dispatchEvent(new SLogEvent(msg, SLogEventLevel.FATAL));
		}
	}

	/**
	 *  @inheritDoc
	 */	
	public function info(msg:String, ... rest):void
	{
		if (hasEventListener(SLogEvent.LOG))
		{
			// replace all of the parameters in the msg string
			for (var i:int = 0; i < rest.length; i++)
			{
				msg = msg.replace(new RegExp("\\{"+i+"\\}", "g"), rest[i]);
			}

			dispatchEvent(new SLogEvent(msg, SLogEventLevel.INFO));
		}
	}

	/**
	 *  @inheritDoc
	 */	
	public function warn(msg:String, ... rest):void
	{
		if (hasEventListener(SLogEvent.LOG))
		{
			// replace all of the parameters in the msg string
			for (var i:int = 0; i < rest.length; i++)
			{
				msg = msg.replace(new RegExp("\\{"+i+"\\}", "g"), rest[i]);
			}

			dispatchEvent(new SLogEvent(msg, SLogEventLevel.WARN));
		}
	}
}

}
