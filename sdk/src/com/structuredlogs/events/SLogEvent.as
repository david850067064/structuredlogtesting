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
package com.structuredlogs.events
{

import flash.events.Event;

/**
 *  Represents the log information for a single logging event.
 *  The loging system dispatches a single event each time a process requests
 *  information be logged.
 *  This event can be captured by any object for storage or formatting.
 */
public class SLogEvent extends Event
{

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

    /**
     *  Event type constant; identifies a logging event.
     */
    public static const LOG:String = "log";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

    /**
     *  Returns a string value representing the level specified.
	 *
     *  @param The level a string is desired for.
	 *
     *  @return The level specified in English.
     */
    public static function getLevelString(value:uint):String
    {
        switch (value)
        {
            case SLogEventLevel.INFO:
			{
                return "INFO";
			}

            case SLogEventLevel.DEBUG:
			{
                return "DEBUG";
            }

            case SLogEventLevel.ERROR:
			{
                return "ERROR";
            }

            case SLogEventLevel.WARN:
			{
                return "WARN";
            }

            case SLogEventLevel.FATAL:
			{
                return "FATAL";
            }

            case SLogEventLevel.FATAL:
			{
                return "FATAL";
            }

            case SLogEventLevel.ALL:
			{
                return "ALL";
            }
		}

		return "UNKNOWN";
    }

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
     *  Constructor.
	 *
     *  @param msg String containing the log data.
	 *
     *  @param level The level for this log event.
     *  Valid values are:
     *  <ul>
     *    <li><code>SLogEventLevel.TESTPOINT</code> designates events that are 
     *    structured to work with Structured Log Testing tools.</li>
     * 
     *    <li><code>SLogEventLevel.FATAL</code> designates events that are very
     *    harmful and will eventually lead to application failure</li>
     *
     *    <li><code>SLogEventLevel.ERROR</code> designates error events that might
     *    still allow the application to continue running.</li>
     *
     *    <li><code>SLogEventLevel.WARN</code> designates events that could be
     *    harmful to the application operation</li>
	 *
     *    <li><code>SLogEventLevel.INFO</code> designates informational messages
     *    that highlight the progress of the application at
	 *    coarse-grained level.</li>
	 *
     *    <li><code>SLogEventLevel.DEBUG</code> designates informational
     *    level messages that are fine grained and most helpful when
     *    debugging an application.</li>
	 *
     *    <li><code>SLogEventLevel.ALL</code> intended to force a target to
     *    process all messages.</li>
     *  </ul>
     */
    public function SLogEvent(message:String = "",
							 level:int = 0 /* SLogEventLevel.ALL */)
    {
        super(SLogEvent.LOG, false, false);

        this.message = message;
        this.level = level;
    }

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  level
	//----------------------------------

    /**
     *  Provides access to the level for this log event.
     *  Valid values are:
     *    <ul>
     *      <li><code>LogEventSLogEventLevel.INFO</code> designates informational messages
     *      that highlight the progress of the application at
     *      coarse-grained level.</li>
     *
     *      <li><code>SLogEventLevel.DEBUG</code> designates informational
     *      level messages that are fine grained and most helpful when
     *      debugging an application.</li>
     *
     *      <li><code>SLogEventLevel.ERROR</code> designates error events that might
     *      still allow the application to continue running.</li>
     *
     *      <li><code>SLogEventLevel.WARN</code> designates events that could be
     *      harmful to the application operation.</li>
     *
     *      <li><code>SLogEventLevel.FATAL</code> designates events that are very
     *      harmful and will eventually lead to application failure.</li>
     * 
     *    	<li><code>SLogEventLevel.TESTPOINT</code> designates events that are 
     *    	structured to work with Structured Log Testing tools.</li>
     *    </ul>
     */
    public var level:int;

	//----------------------------------
	//  message
	//----------------------------------

    /**
     *  Provides access to the message that was logged.
     */
    public var message:String;

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: Event
	//
	//--------------------------------------------------------------------------

    /**
	 *  @private
     */
    override public function clone():Event
    {
        return new SLogEvent(message, level);
    }
}

}