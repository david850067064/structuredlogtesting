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

package com.structuredlogs.drivers
{

import com.structuredlogs.data.StructuredLogCommand;
import com.structuredlogs.data.TestPoint;
import com.structuredlogs.data.TestPointScript;
import com.structuredlogs.events.SLogEvent;
import com.structuredlogs.events.SLogEventLevel;
import com.structuredlogs.targets.LineFormattedTarget;
import com.structuredlogs.utils.JSON;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.Timer;
import flash.utils.getQualifiedClassName;

import mx.logging.ILogger;

/**
 * 	The <code>TestDriver</code> class is a custom target that load Structured Log File (.slf) 
 *  scripts and then match incoming data with the scripts.  The driver checks the incoming data
 *  with the TestPoint assertions to check for passing conditions then fires an event when it has
 *  finished comparing enough data for the script's assertions. 
 *  
 *  It is possible for an active script to not be given enough data to compare.
 */
public class TestDriver extends LineFormattedTarget
{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *	Constructor 
     */
	public function TestDriver()
	{
		// Filter out other log items
		level = SLogEventLevel.TESTPOINT;
		filters = ["*"];
	}

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *	Array of all active scripts 
     */
    private var activeScripts:Object = new Object();
	
	/**
	 * 	@private
	 * 	The current ITestDriver
	 */
	protected var driverApplication:ITestDriver;

	/**
	 * 	@private
	 *	Driver global timeout timer.
	 */
	protected var driverTimer:Timer = new Timer(timeout, 1);
	
    //--------------------------------------------------------------------------
    //  related to loading scripts
    //--------------------------------------------------------------------------   

	/**
	 *	Are all scripts loaded and ready to go
	 */
	protected var isLoaded:Boolean = false;

	/**
	 * 	@private
	 *	The script loading index.
	 */
	protected var scriptLoadIndex:int = 0;

	/**
	 *	@private
	 * 	The URLoader used for loading scripts.
	 */
	protected var loader:URLLoader;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

	/**
	 * 	Array of all the <code>TestPointScript</code> loaded by the <code>TestDriver</code>.
	 * 	The <code>TestPointScript</code> values are index by <code>TestPointScript.name</code>
	 */
	public var allScripts:Object = new Object();
	
	/**
	 * 	TestDriver unique identifier for display reasons (optional)
	 */
	public var name:String;

	/**
	 * 	The default timeout in seconds, the driver wont run longer then the timeout
	 */
	public var timeout:int = 60000;

    //--------------------------------------------------------------------------
    //  scripts
    //--------------------------------------------------------------------------    

	/**
	 * 	@private
	 */
	private var _scripts:Array = new Array();
	
	/**
	 * 	An array of Structured Log File (.slf) names to be loaded into <code>TestPointScript</code>
	 *  instances.
	 */
	public function get scripts():Array
	{
		return _scripts;
	}
	/**
	 * 	@private
	 */
	public function set scripts(value:Array):void
	{
		isLoaded = false;
		_scripts = value;
	}

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //-------------------------------------------------------------------------- 

	/**
	 * 	Start loading scripts and fire off driverReady for <code>ITestDriver</code> classes
	 * 	to start their code execution
	 * 
	 * 	@param driver The <code>ITestDriver</code> handling all the scripts and code execution
	 * 	@param overrideScripts You can set the scripts value specifically here.
	 */  
	public function start(driver:ITestDriver, overrideScripts:Array = null):void
	{
		// Stop the last driverTimer if its running
		if (driverTimer.running)
			driverTimer.stop();
			
		if (!name)
		{
			name = getQualifiedClassName(driver).replace("::", ".");
			SLog.addTarget(this);
		}
			
		if (overrideScripts)
		{
			isLoaded = false;
			scripts = overrideScripts;
		}
		
		// Store the driver locally
		driverApplication = driver;
		
		// Only load the scripts if they need to be
		if (!isLoaded)
		{
			allScripts = new Object();
			scriptLoadIndex = 0;
			loadScripts();
		}
		else
		{
			resetScripts();
			driverReady();
		}
	}
	
	public function loadScripts():void
	{
		if (scriptLoadIndex < scripts.length)
		{
			// Only do this once	
			//if (!loader)
			//{
				loader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, completeHandler);
				loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			//}
			
			loader.load(new URLRequest(scripts[scriptLoadIndex]));
		}
		else
		{
			isLoaded = true;
			driverReady();
		}
	}
	
	/**
	 * 	Sets up the timer for timeout and calls the <code>driverReady()</code> on the 
	 *  driver class.
	 */
	protected function driverReady():void
	{
		driverTimer.delay = timeout;
		driverTimer.reset();
		driverTimer.start();
		driverApplication.driverReady();
	}
	
	protected function resetScripts():void
	{
		for each (var tpScript:TestPointScript in allScripts)
		{
			tpScript.clearData();
		}
	}
	
	/**
	 * 	Handles the loading of a TestPoint script
	 */
	protected function completeHandler(event:Event):void
	{			
		removeListeners();
		
		// Create new script from the loader's data
		try
		{
			var data:String = (event.target as URLLoader).data as String;		
			var lines:Array = data.split("\n");
			var header:Object = (new JSON()).decode(lines[0]);
			
			var assertions:Array = new Array();
			// Add assertions now to catch handler
			for (var i:int = 1;i < lines.length;i++)
			{
				assertions.push(TestPoint.parseMessage(lines[i]));
			}
				
			var newScript:TestPointScript = new TestPointScript(assertions);		
			newScript.name = header.name;
			newScript.identifier = header.identifier;
			newScript.description = header.description;
			
			allScripts[newScript.name] = newScript;
			driverApplication.scriptCreatedHandler(newScript);
		}
		catch(error:Error)
		{
			;//Alert.show("error: " + error.message);
		}
		// Had some error just ignore and go to the next
		scriptLoadIndex++;
		loadScripts();
	}
	
	protected function removeListeners():void
	{
		if (loader)
		{
			loader.removeEventListener(Event.COMPLETE, completeHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
		}
	}
	
	protected function errorHandler(event:ErrorEvent):void
	{
		removeListeners()
		driverApplication.scriptErrorHandler(scripts[scriptLoadIndex], event.text);
		
		// Had some error just ignore and go to the next
		scriptLoadIndex++;
		loadScripts();
	}

	/**
	 * 	Override the Event levels to work with each debug application correctly
	 */	
    override public function logEvent(event:SLogEvent):void
    {
		if (!driverTimer.running)
			return;
		var level:int = event.level;
 		
 		// Ignore non TestPoint log messages, should be filtered by setting level property in Constructor
 		//if (level != RIALogger.TESTPOINT_LEVEL)
 		//	return;
 		
 		var category:String = ILogger(event.target).category;

		// TODO TestDriver can read all the categories from the scripts and only listen on those
		// if (!categoryHash[category])
		// 	return

		/*
		var logObject:LogObjectVO = new LogObjectVO();
    	logObject.datetime = new Date();
    	logObject.category = category;
    	logObject.level = level;
    	logObject.message = event.message;
    	logObject.identifier = name;
    	*/
    	
    	var tps:TestPointScript;
    	var testPoint:TestPoint = TestPoint.parseMessage(event.message);
    	if (testPoint.tpname == StructuredLogCommand.SLOG_ACTIVATE_SCRIPT)
    	{
    		var scriptName:String = testPoint.dataParts["scriptName"].value;
    		if (testPoint.dataParts["activate"].value)
    		{
    			activeScripts[scriptName] = allScripts[scriptName]; 	
    		}
    		else
    		{
    			tps = activeScripts[scriptName];
    			activeScripts[scriptName] = null;
    			delete activeScripts[scriptName];
    			
    			// If it is there assume deactivation means stop looking an fire off scriptFinishedHandler
    			if (tps)
    				driverApplication.scriptFinishedHandler(tps);
    		}
    		return;
    	}
    	
    	// Let each script check assertions
    	for each (tps in activeScripts)
    	{
    		if (!tps)
    			continue;
    		tps.checkAssertion(testPoint);
    		if (tps.assertionLength == tps.currentDataLength)
    		{
    			activeScripts[tps.name] = null;
    			delete activeScripts[tps.name];
    			
    			driverApplication.scriptFinishedHandler(tps);
    		}
    	}
    }
	
}
}