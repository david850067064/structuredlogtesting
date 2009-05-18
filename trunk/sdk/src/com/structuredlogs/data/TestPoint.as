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
import com.structuredlogs.events.TestPointEvent;
import com.structuredlogs.utils.JSON;

import flash.events.EventDispatcher;
import flash.utils.describeType;

/**
 *  Dispatched when the user presses the Button control.
 *  If the <code>autoRepeat</code> property is <code>true</code>,
 *  this event is dispatched repeatedly as long as the button stays down.
 *
 *  @eventType com.structuredlogs.events.TestPointEvent.ASSERTION_CHECK
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="assertionCheck", type="com.structuredlogs.events.TestPointEvent")]

[RemoteClass(alias="com.structuredlogs.data.TestPoint")]

/**
 * 	The data class that defines a TestPoint instance used in
 * 	Structured Log Testing.
 */
public class TestPoint extends EventDispatcher
{

	/**
	 *	Static function to create TestPoint instance from a message
	 * 	string. 	
	 */
	public static function parseMessage(message:String):TestPoint
	{
		var testPoint:TestPoint;
		if (message == "")
			return null;
		try
		{
			var msgObject:Object = (new JSON()).decode(message);
			testPoint = new TestPoint();
			for (var key:String in msgObject)
			{
				if (key == "testPointName"
					|| key == "tpname")
					testPoint.tpname = msgObject[key];
				else if (key == "testClassName"
					|| key == "tpcat")
					testPoint.tpcat = msgObject[key];
				else if (key == "testDescription"
					|| key == "tpdesc")
					testPoint.tpdesc = msgObject[key];
				else if (key == "testUniqueID"
					|| key == "tpuid")
					testPoint.tpuid = msgObject[key];
				else
				{
					testPoint.dataParts[key] = (TestPointDataPart.parseObject(key, msgObject[key]));
					(testPoint.dataParts[key] as TestPointDataPart).testPoint = testPoint;
				}	
			}
		}
		catch (error:Error)
		{
			return null;
		}	

		return testPoint;
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
	
	/**
	 * 	Assertion <code>TestPointScript</code> that this TestPoint is related too.
	 */
	public var testPointScript:TestPointScript;
	
	/**
	 * 	The TestPoint name or identifier
	 */
	public var tpname:String = "";
	
	/**
	 * 	The category of the TestPoint.
	 */
	public var tpcat:String = "";
	
	/**
	 * 	The description of the TestPoint.
	 */
	public var tpdesc:String = "";
	
	/**
	 * 	The unique identifier of the TestPoint.
	 */
	public var tpuid:String = "";
	
	/**
	 * 	The name value pair values that make up the <code>TestPoint</code> custom data.
	 */
	public var dataParts:Object = new Object();
	
	/**
	 * 	Clone the TestPoint instance.
	 */
	public function clone():TestPoint
	{ 
		var clone:TestPoint = new TestPoint();
		clone.tpname = tpname;
		clone.tpcat = tpcat;
		clone.tpdesc = tpdesc;
		clone.tpuid = tpuid;
		for each (var dataPart:TestPointDataPart in dataParts)
		{
			clone.dataParts[dataPart.name] = dataPart.clone();
			(clone.dataParts[dataPart.name] as TestPointDataPart).testPoint = clone;
		}
		return clone;
	}
	
	/**
	 * 	Check if the TestPoint as an assertion pass with its comparingTestPoint.
	 */
	public function get passed():Boolean
	{			
		var pass:Boolean = true;
		for each (var dataPart:TestPointDataPart in dataParts)
		{
			// This will get complicated with different rules
			pass = pass && dataPart.passed;
		}
		return pass;
	}
	
	/**
	 * 	Return any failure information for not passing.
	 */
	public function getFailureReasons():Array
	{
		var errors:Array = new Array();
		if (dataParts.length == 0)
		{
			errors.push("No comparing data present.");
			return errors;
		}

		for each (var dataPart:TestPointDataPart in dataParts)
		{
			errors.splice(errors.length, 0, dataPart.getFailureReasons());
		}
		return errors;
	}
	
	
	/**
	 * 	Associated data that the TestPoint as an assertion can compare with.
	 */
	public function setComparingTestPoint(value:TestPoint):void
	{
		for each (var dataPart:TestPointDataPart in dataParts)
		{
			if (value != null)
				dataPart.comparingDataPart = value.dataParts[dataPart.name];
			else
				dataPart.comparingDataPart = null;
		}
		dispatchEvent(new TestPointEvent(TestPointEvent.ASSERTION_CHECK));
	}
	
	/**
	 * 
	 */
	public function serialize():String
	{
		var obj:Object = new Object();
		obj.tpname = tpname;
		obj.tpcat = tpcat;
		obj.tpdesc = tpdesc;
		obj.tpuid = tpuid;
		for each (var dataPart:TestPointDataPart in dataParts)
		{
			obj[dataPart.name] = dataPart.value;
		}
		return (new JSON).encode(obj);
	}
	
	
	/**
	 * 	Checks the TestPoint data for equality.  Data points are converted
	 *  to strings for comparison.
	 */
	public function equals(log:TestPoint):Boolean
	{
		var isSame:Boolean = true;
		for each (var dataPart:TestPointDataPart in dataParts)
		{
			if (log.dataParts[dataPart.name] == null)
				return false;
			isSame = isSame && dataPart.equals(log.dataParts[dataPart.name]);
		}			
		return isSame;
	}
	/**
	 * 	String representation of the TestPoint
	 */
	public function get numDataParts():int
	{
		var numDataParts:int = 0;
		for each (var dataPart:TestPointDataPart in dataParts)
		{
			numDataParts++;
		}
		return numDataParts;
	}
	
	/**
	 * 	String representation of the TestPoint
	 */
	override public function toString():String
	{
		var uid:String = (tpuid) ? "(" + tpuid + ")" : "";
		var header:String = "[" + tpname + uid + ((tpdesc != "") ? "\"" + tpdesc + "\"" : "") + "]"
		var str:String = "";
		for each (var dataPart:TestPointDataPart in dataParts)
		{
			str += "\n" + dataPart.name + ": " + dataPart.value.toString();
		}		
		return header + str;
	}
}
}