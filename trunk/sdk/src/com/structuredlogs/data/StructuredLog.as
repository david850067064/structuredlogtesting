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

package com.structuredlogs.data
{
import com.structuredlogs.events.SLogEventLevel;
	

[RemoteClass(alias="com.structuredlogs.data.StructuredLog")]

/**
 * 	The data class that defines a structured log statement used in
 * 	Structured Log Testing.
 */
public class StructuredLog
{
	/**
	 * 	The datetime of the log message.
	 */
	public var datetime:Date;
	
	/**
	 * 	The category of the log message.
	 */
	public var category:String;
	
	/**
	 * 	The message of the log message.
	 */
	public var message:String;
	
	/**
	 * 	The level of the log message.
	 */
	public var level:Number;
	
	/**
	 * 	The unique identifier for this data object.
	 */
	public var identifier:String;
	
	/**
	 * 	Format a string representation of the log data in a text line format.
	 */
	public function getDisplayText(displayCategory:Boolean, displayTime:Boolean):String
	{
		var displayText:String = "";
		if (level == SLogEventLevel.TESTPOINT)
		{
			var testPoint:TestPoint = TestPoint.parseMessage(message);
			displayText = testPoint.toString();
		}
		else
		{
			displayText = message;
		}
		if (displayCategory)
			displayText = "(" + category + ") " + displayText;
		if (displayTime)
		{
			var date:String = Number(datetime.getMonth() + 1).toString() + "/" +
				datetime.getDate().toString() + "/" + 
				datetime.getFullYear() + " ";
			date += padTime(datetime.getHours()) + ":" +
				padTime(datetime.getMinutes()) + ":" +
				padTime(datetime.getSeconds()) + "." +
				padTime(datetime.getMilliseconds(), true);			
			displayText = "[" + date + "] " + displayText;
		}			

		return displayText;
	}

    /**
     *  @private
     */
    private function padTime(num:Number, millis:Boolean = false):String
    {
        if (millis)
        {
            if (num < 10)
                return "00" + num.toString();
            else if (num < 100)
                return "0" + num.toString();
            else 
                return num.toString();
        }
        else
        {
            return num > 9 ? num.toString() : "0" + num.toString();
        }
    }
	
	/**
	 * 
	 */
	public function clone():StructuredLog
	{ 
		var clone:StructuredLog = new StructuredLog();
		clone.datetime = datetime;
		clone.category = category;
		clone.level = level;
		clone.message = message;
		clone.identifier = identifier;
		return clone;
	}
	
	/**
	 * 
	 */
	public function toString():String
	{
		return "("+category+") " + message;
	}
}
}