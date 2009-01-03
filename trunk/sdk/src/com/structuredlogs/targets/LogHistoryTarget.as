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

/**
 *  Collects a history of messages.
 */
public class LogHistoryTarget extends LineFormattedTarget
{

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function LogHistoryTarget() 
	{
		super();
        clearHistory();
    }
    
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
     *  @default 1000
     */
    public var max:int = 1000;

    /**
     *  The log statement separator string used when toString() is called.
     *  
     *  @default \n 
     */
    public var separator:String = "\n";

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *	Clear log history.
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
     *  @private
     *  This method outputs the specified message directly to 
     *  <code>trace()</code>.
     *  All output will be directed to flashlog.txt by default.
     *
     *  @param message String containing preprocessed log message which may
     *  include time, date, category, etc. based on property settings,
     *  such as <code>includeDate</code>, <code>includeCategory</code>, etc.
     */
    override public function internalLog(message:String):void
    {
		if (logHistory.length > max)
			logHistory.shift();
			
		logHistory.push(message);		  
    }    

	/**
	 *	Display the log statements separatored sorted from latest to earliest. 
	 */
    public function toString():String
    {
    	logHistory.reverse();
    	var str:String = logHistory.join(separator);
    	logHistory.reverse();
    	return str;
    }
  
}
}