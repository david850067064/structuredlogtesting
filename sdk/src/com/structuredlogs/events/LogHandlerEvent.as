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
 *  Represents one or more log statements assocaitated to the specified identifier.
 * 
 * 	Fired by the SLogLocalConnection class.
 */
public class LogHandlerEvent extends Event
{

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

    /**
     *  Event type constant; identifies a logging event.
     */
    public static const UPDATE:String = "update";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------


	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
     *  Constructor.
     * 
     * 	@param messages An array of StructuredLog formated objects.
     * 	@param identifier String associated with the array of messages.
     */
    public function LogHandlerEvent(messages:Array, identifier:String)
    {
        super(LogHandlerEvent.UPDATE, false, false);

        this.messages = messages;
        this.identifier = identifier;
    }

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  identifier
	//----------------------------------

    /**
     *  Provides the identifier that the messages are assocaited with.
     */
    public var identifier:String;

	//----------------------------------
	//  message
	//----------------------------------

    /**
     *  An array of StructuredLog formated objects.
     */
    public var messages:Array;

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
        return new LogHandlerEvent(messages, identifier);
    }
}

}