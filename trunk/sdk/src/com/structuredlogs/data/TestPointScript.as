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

import flash.utils.describeType;

import mx.collections.ArrayCollection;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;

/**
 * 	
 */
[Bindable]
public class TestPointScript
{
	
    //--------------------------------------------------------------------------
    //
    //  Constants
    //
    //-------------------------------------------------------------------------- 
    
    /**
     *	The status of the script when being run by <code>TestDriver</code>.  The
     *  default status means there is no data being compared with this script.
     */
	public static const STATUS_DEFAULT:String = "Default";
	
    /**
     *	The status of the script when being run by <code>TestDriver</code>.  The
     *  running status means there is some data being compared with the script's
     *  assertions.
     */	
	public static const STATUS_RUNNING:String = "Running";
	
    /**
     *	The status of the script when being run by <code>TestDriver</code>.  The
     *  completed status means there is all data has been compared with the script's
     *  assertions.
     */	
	public static const STATUS_COMPLETED:String = "Completed";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //-------------------------------------------------------------------------- 
    
    /**
     *	Constructor 
     */
	public function TestPointScript(assertions:Array = null)
	{
		if (assertions)
		{
			setAssertions(assertions);
		}
	}

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //-------------------------------------------------------------------------- 
	
	
	/**
	 * 	@private
	 * 	The assertions associated with this TestPoint script.
	 */
	protected var assertions:Array = new Array();


    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //-------------------------------------------------------------------------- 

	/**
	 * 	The name of this TestPoint test script.
	 */
	public var name:String;
	
	/**
	 * 	The identifier of this TestPoint test script.
	 */	
	public var identifier:String;
	
	/**
	 * 	The description of this TestPoint test script.
	 */	
	public var description:String = "";
	
	/**
	 * 	A flag telling the test script to check assertions with data for matching tpname 
	 *  in the order the data comes in.  If set to false it just looks for matches of 
	 *  data and assertions ignoring non-matches.
	 */	
	public var strictOrder:Boolean = true;
	
	/**
	 *  The current number of data items matching assertion TestPoint names.
	 */
	public var currentDataLength:int = 0;
	
	/**
	 * 	The number of assertions in the <code>TestPointScript</code>.
	 */
	public function get assertionLength():int
	{
		return assertions.length;
	}
	
    //--------------------------------------------------------------------------
    //  status
    //--------------------------------------------------------------------------  
    
	/**
	 * 	@private
	 */
	private var _status:String = "";
	
	/**
	 * 	The status of the script when being run by <code>TestDriver</code>.
	 */
	public function get status():String
	{
		if (assertions.length > 0 && currentDataLength == 0)
		{
			_status = TestPointScript.STATUS_DEFAULT;
		}
		else if (assertions.length > 0 && assertions.length < currentDataLength)
		{
			_status = TestPointScript.STATUS_RUNNING;
		}
		else if (assertions.length > 0 && assertions.length == currentDataLength)
		{
			_status = TestPointScript.STATUS_COMPLETED;
		}
		return _status;
	}
	/**
	 * 	@private
	 */
	public function set status(value:String):void
	{
		_status = value;
	}
	
    //--------------------------------------------------------------------------
    //  passed
    //--------------------------------------------------------------------------  
	
	/**
	 * 	Is the script assertions pass or fail
	 */
	public function get passed():Boolean
	{
		if (assertions.length > 0 && assertions.length == currentDataLength)
		{
			var pass:Boolean = true;
			for each (var assertion:TestPoint in assertions)
			{
				pass = pass && assertion.passed;
			}
			return pass;
		}
		else
		{
			return false;
		}
	}
	
	/**
	 * 	Return any failure information for not passing.
	 */
	public function getFailureReasons():Array
	{
		var errors:Array = new Array();
		if (assertions && assertions.length > 0)
		{
			for each (var assertion:TestPoint in assertions)
			{
				for each(var error:String in assertion.getFailureReasons())
				{
					errors.push(assertion.tpname + " (" + assertion.tpuid + "): " + error);
				}
			}
		}
		return errors;
	}

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //-------------------------------------------------------------------------- 

	/**
	 * 	Set the assertions for this script
	 */
	public function setAssertions(assertions:Array):void
	{
		if (assertions)
		{
			this.assertions = assertions;
			for each (var assertion:TestPoint in this.assertions)
			{
				assertion.testPointScript = this;
			}
		}
	}
	
	/**
	 * 	Get the assertions for this script
	 */
	public function getAssertions():Array
	{
		return assertions;
	}

	/**
	 * 	
	 */
	public function clearData():void
	{
		for each(var testPoint:TestPoint in assertions)
			testPoint.setComparingTestPoint(null);
		currentDataLength = 0;
		status = "";
	}

	/**
	 * 	Checks the current log item for possible assertion validation
	 */
	public function checkAssertion(item:TestPoint):void
	{
		
		// TODO implement strictOrder = false option, whats false mean?
		
		var index:int = currentDataLength;
		if (index < assertions.length)
		{	
			var currentAssertion:TestPoint = assertions[index] as TestPoint;
			var isValid:Boolean = true;
			// Check TestPoint Name
			isValid = (currentAssertion.tpcat == item.tpcat
						&& currentAssertion.tpname == item.tpname);

			// Check TestPoint Data
			//for (var key:String in assertPoint)
			//{
			//	isValid = (item[key] == assertPoint[key]) && isValid;
			//}
			
			if (isValid)
			{					
				var clone:TestPoint = item.clone();
				clone.tpuid = currentAssertion.tpuid;
				currentAssertion.setComparingTestPoint(clone);
				currentDataLength++;
			}
		}
	}
	
	/**
	 * 	Recursive function that can read <code>TestPoint</code> logic rules
	 *  and retrieve values.
	 */
	public function getTestPointValue(object:Object):*
	{
		var classInfo:XML = describeType(object);
		//trace("getTestPointValue: " + classInfo.toXMLString());
		if (classInfo.@isDynamic.toString() == "true"
			&& object.tptype != "")
		{
			//trace("getTestPointValue1: " + object.tptype);
			if (object.tptype == "slt")
			{
				var params:Array;
				var operator:String = object.tpop;
				switch (operator)
				{
					case "linked":
						params = object.params;
						try
						{
							var assertionData:TestPoint = getAssertion(params[0].tpname, params[0].tpuid);
							//trace("getTestPointValue1BB: " + assertionData.dataParts[params[0].tpkey].comparingData.value);
							return (assertionData.dataParts[params[0].tpkey] as TestPointDataPart).comparingDataPart.value + "";
						}
						catch (error:Error)
						{
							
							trace("getTestPointValue11: " + error.message);
						} 
					break;
					default:
					break;
				}
			}
		}
			//trace("getTestPointValue2: " + object.toString());
		return object.toString();
	}

	/**
	 * 	Checks if tpcat and tpname are the same
	 */
	public function checkDuplicateItemByName(item:TestPoint):Boolean
	{
		for each (var assertPoint:TestPoint in assertions)
		{
			// Check TestPoint Name
			if (assertPoint.tpcat == item.tpcat
					&& assertPoint.tpname == item.tpname)
				return true;
		}
		return false;
	}

	/**
	 * 	Retrieve linked assertion.
	 */
	public function getAssertion(tpname:String, tpuid:String = null):TestPoint
	{
		for each (var assertPoint:TestPoint in assertions)
		{
			// Check TestPoint Name
			if (assertPoint.tpname == tpname
				&& (tpuid == null || assertPoint.tpuid == tpuid))
				return assertPoint;
		}
		return null;
	}
	
	/**
	 * 	toString()
	 */
	public function toString():String
	{
		return name + " ["+identifier+"]";
	}
}
}