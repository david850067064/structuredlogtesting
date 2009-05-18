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

import flash.utils.describeType;

import mx.utils.ArrayUtil;


[RemoteClass(alias="com.structuredlogs.data.TestPointDataPart")]

/**
 * 	The data class that defines a TestPoint instance used in
 * 	Structured Log Testing.
 */
public class TestPointDataPart
{
	
    //--------------------------------------------------------------------------
    //
    //  Constants
    //
    //--------------------------------------------------------------------------

	public static const TYPE_VALUE:String = "Value";
	public static const TYPE_CONSTANT:String = "Constant";
	public static const TYPE_CUSTOM:String = "Custom";

	/**
	 *	Static function to create TestPoint instance from a message
	 * 	string. 	
	 */
	public static function parseObject(name:String, value:*):TestPointDataPart
	{
		if (name == "" || value == null)
			return null;
		try
		{
			var dataPart:TestPointDataPart= new TestPointDataPart();
			dataPart.name = name;
			dataPart.value = value;
			
			try
			{
				if (value is Boolean || value == null)
					dataPart.valueType = TYPE_CONSTANT;
				else if (value["tptype"] != null && value["tptype"] != undefined)
					dataPart.valueType = TYPE_CUSTOM;
				else
					dataPart.valueType = TYPE_VALUE;
			}
			catch (error:Error)
			{
				dataPart.valueType = TYPE_VALUE;
			}
			return dataPart;
		}
		catch (error:Error)
		{
			trace(error.message);
		}	
		return null;
	}

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //-------------------------------------------------------------------------- 
    
    /**
     *	The string representation of the value that was compared for pass/fail
     *  logic.
     */
    protected var calculatedValue:String;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //-------------------------------------------------------------------------- 

	/**
	 * 	Assertion <code>TestPoint</code> that this TestPointDataPart is related too.
	 */
	public var testPoint:TestPoint;
		
	/**
	 * 	Associated data that the TestPoint as an assertion can compare with.
	 */
	public var comparingDataPart:TestPointDataPart;
	
	/**
	 * 	The name part of the data part's name value pair name or identifier
	 */
	public var name:String;
	
	private var _value:*;
	/**
	 * 	The value of the data part.
	 */
	public function set value(v:*):*
	{
		_value = v;
	}
	public function get value():*
	{
		return _value;
	}
	
	/**
	 * 	The value JSON representation of the data part.
	 */
	public var valueJSON:String;
	
	/**
	 * 	The value's type (number, string, boolean, related logic, ...)
	 */
	public var valueType:String;
	
	
	/**
	 * 	Clone the TestPointDataPart instance.
	 */
	public function clone():TestPointDataPart
	{ 
		var clone:TestPointDataPart = new TestPointDataPart();
		clone.name = name;
		clone.value = value;
		clone.valueJSON = valueJSON;
		clone.valueType = valueType;
		return clone;
	}
	
	/**
	 * 	Compare values to see if they are acceptable output.  This function
	 *  resolves any relationship logic of the TestPoint data point assertions.
	 */
	public function get passed():Boolean
	{
		if (!comparingDataPart)
			return false;
			
		var pass:Boolean = true;
		// This will get complicated with different rules
		pass = pass && compareData(this, comparingDataPart);
		return pass;
	}
	
	/**
	 * 	Return any failure information for not passing.
	 */
	public function getFailureReasons():Array
	{
		var errors:Array = new Array();
		if (!comparingDataPart)
		{
			errors.push("No comparing data present.");
			return errors;
		}

		// This will get complicated with different rules
		if (!compareData(this, comparingDataPart))
		{
			errors.push(name + " is not valid: " + calculatedValue + " != " + comparingDataPart.value);
		}
	
		return errors;
	}
	
	/**
	 * 	Compares <code>TestPoit</code> data values.
	 */
	protected function compareData(data1:TestPointDataPart, data2:TestPointDataPart):Boolean
	{
		var pass:Boolean = false;
		var assertionObject:Object = data1.value;
		var classInfo:XML = describeType(assertionObject);
		if (testPoint
			&& classInfo.@isDynamic.toString() == "true"
			&& assertionObject.tptype != "")
		{
			var params:Array = new Array();
			var operator:String = "";
			for(var i:int = 0;i < assertionObject.params.length; i++)
			{
				var paramObject:Object = assertionObject.params[i];
				params.push(testPoint.testPointScript.getTestPointValue(paramObject) as String);
			}
			operator = assertionObject.tptype + "|" + assertionObject.tpop;
			switch (operator)
			{
				case "slt|minus":
					// Expects 2 parameters
					calculatedValue = (int(params[0]) - int(params[1])).toString();
					return (int(data2.value) == (int(params[0]) - int(params[1])));
				break;
				case "slt|add":
					// Expects 2 parameters
					calculatedValue = (int(params[0]) + int(params[1])).toString();
					return (int(data2.value) == (int(params[0]) + int(params[1])));
				break;
				case "hamcrest|greaterThan":
					// Expects 1 parameters
					calculatedValue = int(params[0]).toString();
					return int(data2.value) > int(params[0]);
				break;
				case "hamcrest|lessThan":
					// Expects 1 parameters
					calculatedValue = int(params[0]).toString();
					return int(data2.value) < int(params[0]);
				break;
				default:
				break;
			}
				
		}
		else
		{
			calculatedValue = data1.value;
			pass = data1.value == data2.value;
		}
		
		return pass;
	}
	
	/**
	 * 	Serialize the value part.  TestPoint will set
	 *  the name and take the value JSON value from here.
	 */
	public function serialize():String
	{
		// TODO check this process out
		//var obj:Object = new Object();
		//obj[name] = value;
		return (new JSON).encode(value);
	}	
	
	/**
	 * 	Checks the TestPointDataPart data for equality.  Data points are converted
	 *  to strings for comparison.
	 */
	public function equals(log:TestPointDataPart):Boolean
	{
		// Maybe do valueType checks here?
		return (log.value) && (value.toString() == value.toString());
	}
	
	/**
	 * 	String representation of the TestPointDataPart
	 */
	public function toString():String
	{
		var returnValue:String = value;
		if (valueType == TestPointDataPart.TYPE_CONSTANT)
			returnValue = (value === true) ? 'true' : (value === false) ? "false" : "null";
		if (valueType == TestPointDataPart.TYPE_CUSTOM)
			returnValue = value.tpop+"["+(value.params as Array).join(",")+"]";
		if (comparingDataPart)
			returnValue += " *"+calculatedValue+"*";
		return name + " (" + returnValue + ")";
	}
}
}