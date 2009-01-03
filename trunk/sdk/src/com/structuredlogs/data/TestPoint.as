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
import com.structuredlogs.utils.JSON;
	

[RemoteClass(alias="com.structuredlogs.data.TestPoint")]

/**
 * 	The data class that defines a TestPoint instance used in
 * 	Structured Log Testing.
 */
dynamic public class TestPoint
{

	/**
	 *	Static function to create TestPoint instance from a message
	 * 	string. 	
	 */
	public static function parseMessage(message:String):TestPoint
	{
		var msgObject:Object = (new JSON()).decode(message);
		var testPoint:TestPoint = new TestPoint();
		for (var key:String in msgObject)
		{
			testPoint[key] = msgObject[key];
		}			

		return testPoint;
	}
	
	
	/**
	 * 	The TestPoint name or identifier
	 */
	public var tpname:String;
	
	/**
	 * 	The category of the TestPoint.
	 */
	public var tpcat:String;
	
	/**
	 * 	The description of the TestPoint.
	 */
	public var tpdesc:String;
	
	/**
	 * 	Clone the TestPoint instance.
	 */
	public function clone():TestPoint
	{ 
		var clone:TestPoint = new TestPoint();
		clone.tpname = tpname;
		clone.tpcat = tpcat;
		clone.tpdesc = tpdesc;
		for (var key:String in this)
			clone[key] = this[key];
		return clone;
	}
	
	/**
	 * 	String representation of the TestPoint
	 */
	public function toString():String
	{
		var header:String = "[" + tpname + ((tpdesc != "") ? "\"" + tpdesc + "\"" : "") + "]"
		var str:String = "";
		for (var key:String in this)
		{
			if (key == "tpname" ||
				key == "tpdesc" ||
				key == "tpcat")
				continue;
			str += "\n" + key + ": " + this[key];
		}		
		return header + str;
	}
}
}