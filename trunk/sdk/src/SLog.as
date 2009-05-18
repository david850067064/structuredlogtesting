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
package 
{

import com.structuredlogs.SLogLogger;
import com.structuredlogs.data.StructuredLogCommand;
import com.structuredlogs.events.SLogEventLevel;
import com.structuredlogs.utils.JSON;

import flash.display.DisplayObject;
import flash.utils.describeType;
import flash.utils.getQualifiedClassName;

import mx.logging.ILogger;
import mx.logging.ILoggingTarget;


/**
 *  The SLog class sends structured log statements.
 *  You must use getLogger and registerTarget methods for Logger to be able to retrieve
 * 	a list of categories or targets that are currently being used.
 * 
 * 	<p>If you include the LogController class you will have the ability to enable/disable the trace Targets
 *  at runtime.  It also provides detailed forms to create Targets and assign them to specific categories.</p>
 * 
 * 	@url http://structuredlogs.com
 *  @example
 *  <pre>
 * 	...
 * 	   // Information log method
 * 	   Logger.getLogger( "myErrors" ).info( "myFunction did not call sample text" );
 * 
 * 	   // Inserting parameters into a string
 * 	   Logger.getLogger( "debugMsgs" ).debug( "My Object {0} here I come", "Fred" );
 * 	   // output: My Object Fred here I come
 * 
 * 	...
 *  </pre>
 */
public class SLog
{
	
	//--------------------------------------------------------------------------
	//
	//  Constants
	//
	//--------------------------------------------------------------------------	

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
     *  An associative Array of existing loggers keyed by category
     */
    private static var loggers:Array;

    /**
     *  @private
     *  Array of targets that should be searched any time
     *  a new logger is created.
     */
    private static var targets:Array = [];    
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	/**
	 * 	Turns on and off logging globally.
	 * 
	 *  @default true
	 */
	public static var isLogging:Boolean = true;

	/**
	 * 	Default object parsing function handler.
	 * 
	 * 	<p>If you call <code>SLog.debug("category", myObject);</code> the 
	 *  <code>parseObjectHandler</code> method will be called.  The function
	 * 	takes one parameter of type <code>Object</code>
	 */
	public static var parseObjectHandler:Function = defaultParseHandler;
	
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------
	
	/**
     *  Logs the specified data using the <code>SLogEventLevel.DEBUG</code>
     *  level.
     *  <code>SLogEventLevel.DEBUG</code> designates informational level
     *  messages that are fine grained and most helpful when debugging
     *  an application.
	 */
	public static function debug(logObject:Object, message:Object = null, ...rest):void
	{
		if (!isLogging) 
			return;
		// assume logObject is a message
		if (message == null)
		{
			var log:ILogger = SLog.getLogger("");
			log.debug(SLog.parseMessage(logObject));
			return;
		}
		
		var msg:String = SLog.parseMessage(message);
		var logger:ILogger = SLog.getLogger(logObject);
		
		var parameters:Array = rest;
		if (rest.length > 0)
		{
			parameters.unshift(msg);
			logger["debug"].apply(logger, parameters);
		} 
		else 
		{
			logger.debug(msg);
		}
	}

	/**
     *  Logs the specified data using the <code>SLogEventLevel.ERROR</code>
     *  level.
     *  <code>SLogEventLevel.ERROR</code> designates error events
     *  that might still allow the application to continue running.
	 */
	public static function error(logObject:Object, message:Object = null, ...rest):void
	{
		if (!isLogging) 
			return;
		// assume logObject is a message
		if (message == null)
		{
			var log:ILogger = SLog.getLogger("");
			log.debug(SLog.parseMessage(logObject));
			return;
		}
		
		var msg:String = SLog.parseMessage(message);
		var logger:ILogger = SLog.getLogger(logObject);
		
		var parameters:Array = rest;
		if (rest.length > 0)
		{
			parameters.unshift(msg);
			logger["error"].apply(logger, parameters);
		} 
		else 
		{
			logger.error(msg);
		}
	}

	/**
     *  Logs the specified data using the <code>SLogEvent.INFO</code> level.
     *  <code>SLogEventLevel.INFO</code> designates informational messages that 
     *  highlight the progress of the application at coarse-grained level.
	 */
	public static function info(logObject:Object, message:Object = null, ...rest):void
	{
		if (!isLogging) 
			return;
		// assume logObject is a message
		if (message == null)
		{
			var log:ILogger = SLog.getLogger("");
			log.debug(SLog.parseMessage(logObject));
			return;
		}
		
		var msg:String = SLog.parseMessage(message);
		var logger:ILogger = SLog.getLogger(logObject);
		
		var parameters:Array = rest;
		if (rest.length > 0)
		{
			parameters.unshift(msg);
			logger["info"].apply(logger, parameters);
		} 
		else 
		{
			logger.info(msg);
		}
	}

	/**
     *  Logs the specified data using the <code>SLogEventLevel.WARN</code> level.
     *  <code>SLogEventLevel.WARN</code> designates events that could be harmful 
     *  to the application operation.
	 */
	public static function warn(logObject:Object, message:Object = null, ...rest):void
	{
		if (!isLogging) 
			return;
		// assume logObject is a message
		if (message == null)
		{
			var log:ILogger = SLog.getLogger("");
			log.debug(SLog.parseMessage(logObject));
			return;
		}
		
		var msg:String = SLog.parseMessage(message);
		var logger:ILogger = SLog.getLogger(logObject);
		
		var parameters:Array = rest;
		if (rest.length > 0)
		{
			parameters.unshift(msg);
			logger["warn"].apply(logger, parameters);
		} 
		else 
		{
			logger.warn(msg);
		}
	}


	/**
     *  Logs the specified data using the <code>SLogEventLevel.FATAL</code> 
     *  level.
     *  <code>SLogEventLevel.FATAL</code> designates events that are very 
     *  harmful and will eventually lead to application failure
	 */
	public static function fatal(logObject:Object, message:Object = null, ...rest):void
	{
		if (!isLogging) 
			return;
		// assume logObject is a message
		if (message == null)
		{
			var log:ILogger = SLog.getLogger("");
			log.debug(SLog.parseMessage(logObject));
			return;
		}
		
		var msg:String = SLog.parseMessage(message);
		var logger:ILogger = SLog.getLogger(logObject);
		
		var parameters:Array = rest;
		if (rest.length > 0)
		{
			parameters.unshift(msg);
			logger["info"].apply(logger, parameters);
		} 
		else 
		{
			logger.fatal(msg);
		}
	}

	/**
     *  Logs the specified data using the <code>SLogEventLevel.TESTPOINT</code> 
     *  level.
     *  <code>SLogEventLevel.TESTPOINT</code> designates events that are 
     *  structured to work with Structured Log Testing tools.
     *   
	 * 	@param testPointCategory The category or class that the TestPoint relates to.
	 *  @param testPointName The identifier for the testData for the TestPoint.
	 *  @param testData An object of name/value pair defining the TestPoint.
	 * 	@param testDescription (optional) The description of this TestPoint.
	 */
	public static function test(testPointCategory:Object, testPointName:String, testData:Object, testDescription:String = ""):void
	{
		if (!isLogging) 
			return;
					
		if (!(testData is Object))
			testData = {data:testData};

		var category:String = "";
		if (testPointCategory is DisplayObject || testPointCategory is Class) 
			category = getQualifiedClassName(testPointCategory).replace("::", ".");
		else 
			category = testPointCategory.toString();

		if (!testData.tpcat)
			testData.tpcat = category;

		if (!testData.tpname)
			testData.tpname = testPointName;

		if (!testData.tpdesc)
			testData.tpdesc = testDescription;
		
		var json:JSON = new JSON();
		var msg:String = json.encode(testData);
		var logger:ILogger = SLog.getLogger(category);
		trace("test sent: " + msg);
		logger.log(SLogEventLevel.TESTPOINT, msg);
	}

	/**
	 * 	A specific Structured Log Testing message to let tools know to that the specific
	 *  script should be activated or inactivated.
	 * 
	 *  <p>This is used for a test driver application to dynamic tell the Structured Log Testing
	 *  tools to load and turn on specific scripts and turn them off.  This can be used to 
	 *  load test scripts in sequence while the test driver's implementation code 
	 *  is big set of steps with no setup or tear down between tests.</p> 
	 * 
	 * 	@param scriptName The name of the test script to be activated or inactivated.
	 *  @param activate Value determine the activate state of the script.
	 */
	public static function testActivateScript(scriptName:String, activate:Boolean):void
	{
		SLog.test(SLog, StructuredLogCommand.SLOG_ACTIVATE_SCRIPT, {scriptName:scriptName, activate: activate});
	}

	/**
	 * 	A specific Structured Log Testing message to let tools know to that the specific
	 *  script should be clear their data.
	 */
	public static function testResetScripts():void
	{
		SLog.test(SLog, StructuredLogCommand.SLOG_RESET_SCRIPTS, {});
	}	
	
	/**
	 * 	@private
	 * 	Provides a method of passing in Objects to auto formated
	 */
	private static function parseMessage(message:Object):String
	{
		var msg:String = "";
		if (message is String || 
			message is int || 
			message is uint || 
			message is Number || 
			message is Boolean) 
		{
			msg = message.toString();
		} 
		else 
		{
			parseObjectHandler(message)
		}
		return msg;		
	}

	/**
	 * 	@private 
	 * 	Default object parse function
	 */
	private static function defaultParseHandler(message:Object):String
	{
		var classInfo:XML = describeType(message);
		
		var str:XML = <object>
	        </object>;
		
		str.@name = String( classInfo.@name ).replace( /::/, "." );
		for each (var a:XML in classInfo..accessor.(@access != "writeonly") ) {
			str.appendChild( "<parm name=\"" + a.@name + "\" value=\"" + message[a.@name] + "\" type=\"" + a.@type + "\"/>" );
		}
		return str.toXMLString();		
	}

	/**
	 *  Get a valid ILogger object for a specific category.
	 * 	
	 * 	<p>The ILogger implementation class used is SLogLogger.</p>
	 */		
	public static function getLogger(logObject:Object):ILogger
	{
		var category:String = logObject.toString();
		if (logObject is DisplayObject || logObject is Class || !(logObject is String)) 
		{
			try
			{
				category = getQualifiedClassName(logObject).replace("::", ".");
			}
			catch(error:Error)
			{
				// ignore and take the logObject.toString() value
			}
		}

		// Default to SLog if there are category issues
		if (SLog.hasIllegalCharacters(category)) 
			category = "SLog";

        if (!loggers)
            loggers = [];

        // get the logger for the specified category or create one if it
        // doesn't exist
        var result:ILogger = loggers[category];
        if (result == null)
        {
            result = new SLogLogger(category);
            loggers[category] = result;
        }

        // check to see if there are any targets waiting for this logger.
        var target:ILoggingTarget;
        for (var i:int = 0; i < targets.length; i++)
        {
            target = ILoggingTarget(targets[i]);
            if (categoryMatchInFilterList(category, target.filters))
                target.addLogger(result);
        }
		
		return result;
	}

    /**
     *  Allows the specified target to begin receiving notification of log
     *  events.
     *
     *  @param The specific target that should capture log events.
     */
    public static function addTarget(target:ILoggingTarget):void
    {
        if (target)
        {
        	// Check to see if its present first, if so just leave method
        	for each(var dupTarget:ILoggingTarget in targets)
        	{
        		if (dupTarget == target)
        			return;
        	}
            var filters:Array = target.filters;
            var logger:ILogger;
            // need to find what filters this target matches and set the specified
            // target as a listener for that logger.
            for (var i:String in loggers)
            {
                if (categoryMatchInFilterList(i, filters))
                    target.addLogger(ILogger(loggers[i]));
            }
            // if we found a match all is good, otherwise we need to
            // put the target in a waiting queue in the event that a logger
            // is created that this target cares about.
            targets.push(target);
        }
        else
        {
            throw new Error("Invalid Target");
        }
    }

    /**
     *  Stops the specified target from receiving notification of log
     *  events.
     *
     *  @param The specific target that should capture log events.
     */
    public static function removeTarget(target:ILoggingTarget):void
    {
        if (target)
        {
            var filters:Array = target.filters;
            var logger:ILogger;
            // Disconnect this target from any matching loggers.
            for (var i:String in loggers)
            {
                if (categoryMatchInFilterList(i, filters))
                {
                    target.removeLogger(ILogger(loggers[i]));
                }                
            }
            // Remove the target.
            for (var j:int = 0;j < targets.length; j++)
            {
                if (target == targets[j])
                {
                    targets.splice(j, 1);
                    j--;
                }
            }
        }
        else
        {
            throw new Error("Invalid Target");
        }
    }



    // private members
    /**
     *  This method checks that the specified category matches any of the filter
     *  expressions provided in the <code>filters</code> Array.
     *
     *  @param category The category to match against
     *  @param filters A list of Strings to check category against.
     *  @return <code>true</code> if the specified category matches any of the
     *            filter expressions found in the filters list, <code>false</code>
     *            otherwise.
     *  @private
     */
    private static function categoryMatchInFilterList(category:String, filters:Array):Boolean
    {
        var result:Boolean = false;
        var filter:String;
        var index:int = -1;
        for (var i:uint = 0; i < filters.length; i++)
        {
            filter = filters[i];
            // first check to see if we need to do a partial match
            // do we have an asterisk?
            index = filter.indexOf("*");

            if (index == 0)
                return true;

            index = index < 0 ? index = category.length : index -1;

            if (category.substring(0, index) == filter.substring(0, index))
                return true;
        }
        return false;
    }

    /**
     *  This method checks the specified string value for illegal characters.
     *
     *  @param value The String to check for illegal characters.
     *            The following characters are not valid:
     *                []~$^&amp;\/(){}&lt;&gt;+=`!#%?,:;'"&#64;
     *  @return   <code>true</code> if there are any illegal characters found,
     *            <code>false</code> otherwise
     */
    public static function hasIllegalCharacters(value:String):Boolean
    {
        return value.search(/[\[\]\~\$\^\&\\(\)\{\}\+\?\/=`!@#%,:;'"<>\s]/) != -1;
    }
	
}
}

