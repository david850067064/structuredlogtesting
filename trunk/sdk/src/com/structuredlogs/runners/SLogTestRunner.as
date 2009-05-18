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

package com.structuredlogs.runners 
{
	

import com.structuredlogs.data.TestPointScript;
import com.structuredlogs.drivers.ITestDriver;
import com.structuredlogs.drivers.TestDriver;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

import flex.lang.reflect.Field;
import flex.lang.reflect.Klass;

import org.flexunit.Assert;
import org.flexunit.assertThat;
import org.flexunit.async.Async;
import org.flexunit.async.AsyncLocator;
import org.flexunit.experimental.runners.statements.TheoryAnchor;
import org.flexunit.internals.AssumptionViolatedException;
import org.flexunit.internals.runners.InitializationError;
import org.flexunit.internals.runners.model.EachTestNotifier;
import org.flexunit.internals.runners.statements.ExpectAsync;
import org.flexunit.internals.runners.statements.IAsyncStatement;
import org.flexunit.runner.Description;
import org.flexunit.runner.IDescription;
import org.flexunit.runner.notification.IRunNotifier;
import org.flexunit.runners.BlockFlexUnit4ClassRunner;
import org.flexunit.runners.ParentRunner;
import org.flexunit.runners.model.FrameworkMethod;
import org.flexunit.runners.model.TestClass;
import org.flexunit.token.AsyncTestToken;
import org.flexunit.token.ChildResult;
import org.flexunit.utils.ClassNameUtil;

/**
 * 	<code>SLogTestRunner</code> is a custom FlexUnit4 runner for Structured Log Testing unit type tests.  It 
 *  helps load Structured Log File (.slf) test scripts and use the Structured Log Testing
 *  <code>TestDriver</code> class to drive the test.
 */
public class SLogTestRunner extends BlockFlexUnit4ClassRunner implements ITestDriver
{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //-------------------------------------------------------------------------- 

	/**
	 * 	Constructor
	 */
	public function SLogTestRunner(klass:Class) 
	{
		super(klass);
	}

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //-------------------------------------------------------------------------- 

	/**
	 * 	@private
	 * 	Structured Log Testing test driver.
	 */
	protected var testDriver:TestDriver = new TestDriver();
	/**
	 * 	@private
	 *  Used to know if the scripts are ready if run() is called before then.
	 */
	protected var isReady:Boolean = false;
	/**
	 * 	@private
	 * 	Store any tests that need to be played after the TestDriver is ready.
	 */
	protected var tests:Array = new Array();

	/**
	 * 	@private
	 * 	Notifier bucket for scripts
	 */
	protected var scriptNotifiers:Object;
	
	/**
	 * 	@private
	 * 	Used with the async metadata value in the TestDriver tag.
	 */
	protected var asyncDelay:Number;
	/**
	 * 	@private
	 * 	Used with the async metadata value in the TestDriver tag.
	 */
	protected var asyncFunction:Function;
	/**
	 * 	@private
	 * 	Used with the async metadata value in the TestDriver tag.
	 */
	protected var asyncTestObject:Object;

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //-------------------------------------------------------------------------- 

	/**
	 * 	@private
	 * 	
	 */
	override protected function collectInitializationErrors(errors:Array):void 
	{
		super.collectInitializationErrors(errors);

		validateSLFFields(errors);
		// Load scripts if there are no errors
		if (errors.length == 0)
			loadSLFScripts(errors);
	}

	/**
	 * 	@private
	 * 	Used to validate the presence of SLF fields and that they are set to static.
	 */
	private function validateSLFFields(errors:Array):void 
	{
		var klassInfo:Klass = new Klass(testClass.asClass);

		for (var i:int=0; i<klassInfo.fields.length; i++) 
		{
			if (!(klassInfo.fields[i] as Field).isStatic) 
			{
				errors.push( new Error("SLF field " + (klassInfo.fields[i] as Field).name + " must be static"));
			}
		}
		var testMethods:Array = testClass.getMetaDataMethods("TestDriver");
		if (testMethods.length != 1)
			errors.push(new Error("There has to be one and only one TestDriver method."));
	}

	/**
	 * 	Loop over the [SLF] properties and load the scripts.
	 */
	private function loadSLFScripts(errors:Array):void 
	{
		var klassInfo:Klass = new Klass(testClass.asClass);
		var scripts:Array = new Array();
		for (var i:int=0; i<klassInfo.fields.length; i++) 
		{
			var field:Field = klassInfo.fields[i] as Field;
			var scriptName:String;
			try {
				scriptName = field.getObj(null) as String;
				scripts.push(scriptName);
			} catch (e:TypeError) {
				errors.push(new Error("unexpected: field from getClass doesn't exist on object"));
				continue;
			}
		}
		try
		{
			// Start TestDriver
			testDriver.start(this, scripts);
		}
		catch (error:Error)
		{
			errors.push(error);
		}
	}

    //--------------------------------------------------------------------------
    //  ITestDriver methods
    //--------------------------------------------------------------------------    
	
	/**
	 * 	Required by the <code>ITestDriver</code> interface.
	 * 
	 * 	@see com.structuredlogs.drivers.ITestDriver
	 */
	public function driverReady():void
	{
		isReady = true;
		// Run any delayed tests
		for each(var obj:Object in tests)
		{
			run(obj.notifier, obj.parentToken);
		}
		tests = new Array();
	}
	
	/**
	 * 	Required by the <code>ITestDriver</code> interface.
	 * 
	 * 	@see com.structuredlogs.drivers.ITestDriver
	 */
	public function scriptCreatedHandler(script:TestPointScript):void
	{
		
	}
	
	/**
	 * 	Required by the <code>ITestDriver</code> interface.
	 * 
	 * 	@see com.structuredlogs.drivers.ITestDriver
	 */
	public function scriptFinishedHandler(script:TestPointScript):void
	{
		// Double make sure its inactiviated to optimize checks
		SLog.testActivateScript(script.name, false);
		var loopNotifier:EachTestNotifier
		try
		{
			loopNotifier = scriptNotifiers[script.name];
			var msg:String = "";
			if (!script.passed)
			{
				msg = script.name + " did not pass!\n";
				for each (var errorString:String in script.getFailureReasons())
				{
					msg += errorString + "\n";
				}
			}
			Assert.assertEquals(msg, true, script.passed);
		}
		catch (error:Error)
		{
			if (loopNotifier)
				loopNotifier.addFailure(error);
		}
		if (script.status == TestPointScript.STATUS_COMPLETED
			&& scriptNotifiers)
		{
			loopNotifier = scriptNotifiers[script.name];
			loopNotifier.fireTestFinished();
		}
		
		var allCompleted:Boolean = true;
		// Check if all scripts have passed
		for (var scriptName:String in testDriver.allScripts) 
		{
			var testScript:TestPointScript = testDriver.allScripts[scriptName] as TestPointScript;
			allCompleted = allCompleted && (testScript.status == TestPointScript.STATUS_COMPLETED); 
		}
		if (allCompleted && asyncFunction != null)
		{
			asyncFunction(null);
		}
	}
	
	/**
	 * 	Required by the <code>ITestDriver</code> interface.
	 * 
	 * 	@see com.structuredlogs.drivers.ITestDriver
	 */
	public function scriptErrorHandler(scriptName:String, message:String = ""):void
	{
		throw new InitializationError([new Error("SLF script '" + scriptName + "' failed to load")]);
		//throw new Error("SLF script '" + scriptName + "' failed to load");
	}

    //--------------------------------------------------------------------------
    //  Overridden methods
    //--------------------------------------------------------------------------  

	/**
	 * 	@inheritDoc
	 */
	override public function run(notifier:IRunNotifier, parentToken:AsyncTestToken):void 
	{
		if (isReady)
			super.run(notifier, parentToken);
		else
			tests.push({notifier: notifier, parentToken: parentToken});
	}

	/**
	 * 	@private
	 */
	override protected function validateTestMethods(errors:Array):void 
	{
		var method:FrameworkMethod;
		var methods:Array = computeTestMethods();

		for (var i:int=0; i < methods.length; i++) 
		{
			method = methods[i];
			method.validatePublicVoid(false, errors);
		}
	}

	/**
	 * 	@private
	 */
	override protected function computeTestMethods():Array 
	{
		return testClass.getMetaDataMethods("TestDriver");
	}

	/**
	 * 	@inheritDoc
	 */
	override public function get description():IDescription 
	{
		// Creating special description and child descriptors based off scripts
		var description:IDescription = Description.createSuiteDescription(name, testClass.metadata?testClass.metadata[ 0 ]:null);
		description = description.childlessCopy();
		if (testDriver)
		{
			for (var scriptName:String in testDriver.allScripts) 
			{
				var testScript:TestPointScript = testDriver.allScripts[scriptName] as TestPointScript;
				// TODO implement any other data as XML
				var child:IDescription = Description.createTestDescription(testClass.asClass, testScript.name);//testScript.toFlexUnitMetadata());
				description.addChild(child);
			}
		}
		return description;
	}
	
	/**
	 * 	@private
	 */
	override protected function runChild( child:*, notifier:IRunNotifier, childRunnerToken:AsyncTestToken ):void 
	{
		var method:FrameworkMethod = FrameworkMethod( child );
		scriptNotifiers = new Object();

		// Create an EachTestNotifier for each TestPointScript that was loaded.
		if (testDriver)
		{
			for (var scriptName:String in testDriver.allScripts) 
			{
				var testScript:TestPointScript = testDriver.allScripts[scriptName] as TestPointScript;
				scriptNotifiers[testScript.name] = new EachTestNotifier(notifier, Description.createTestDescription(testClass.asClass, testScript.name));
			}
		}
		var error:Error;
		var loopNotifier:EachTestNotifier;

		var token:AsyncTestToken = new AsyncTestToken( ClassNameUtil.getLoggerFriendlyClassName( this ) );
		token.parentToken = childRunnerToken;
		token.addNotificationMethod( handleBlockComplete );
		//token[ "notifiers" ] = scriptNotifiers;
		
		if ( method.hasMetaData( "Ignore" ) ) {
			for each (loopNotifier in scriptNotifiers)
				loopNotifier.fireTestIgnored();
			childRunnerToken.sendResult();
			return;
		}
		
		for each (loopNotifier in scriptNotifiers)
			loopNotifier.fireTestStarted();
		try {
			var block:IAsyncStatement = methodBlock(method);
			// Setup Async call after methodBlock but before its run with evaluate()
			if (asyncDelay)
				asyncFunction = Async.asyncHandler(asyncTestObject, handleAsyncShouldPass, asyncDelay, null, handleAsyncShouldNotFail); 
			block.evaluate( token );
			
		} catch ( e:AssumptionViolatedException ) {
			error = e;
			for each (loopNotifier in scriptNotifiers)
				loopNotifier.addFailedAssumption(e);			
		} catch ( e:Error ) {
			error = e;
			for each (loopNotifier in scriptNotifiers)
				loopNotifier.addFailure(e);
		} 
		
		if ( error ) {
			for each (loopNotifier in scriptNotifiers)
				loopNotifier.fireTestFinished();
			childRunnerToken.sendResult();
			//if we have already reported the error, to the notifier, there is no need to pass it further up the chain
			//childRunnerToken.sendResult( error );
		}
	}

	/**
	 * 	@private
	 */
	private function handleBlockComplete( result:ChildResult ):void {
		var error:Error = result.error;
		var token:AsyncTestToken = result.token;
		//var eachNotifier:EachTestNotifier = result.token[ EACH_NOTIFIER ];

		var loopNotifier:EachTestNotifier;
		if ( error is AssumptionViolatedException ) {
			for each (loopNotifier in scriptNotifiers)
				loopNotifier.fireTestIgnored();
		} else if ( error ) {
			for each (loopNotifier in scriptNotifiers)
				loopNotifier.addFailure(error);
		}
		/*/ Check if the test script is finished
		for (var scriptId:String in scriptNotifiers)
		{
			var testScript:TestPointScript = testDriver.allScripts[scriptId];
			trace("WHICH SCRIPT IS DONE completed::name: " + testScript.name + " status: " + testScript.status);
			if (testScript.status == TestPointScript.STATUS_COMPLETED)
			{
				//loopNotifier = scriptNotifiers[testScript.name];
				//loopNotifier.fireTestFinished();
				//testScript.clearData();
			}
		}
		//eachNotifier.fireTestFinished();
		*/
		token.parentToken.sendResult();
	}

	/**
	 * 	@private
	 */
	override protected function withPotentialAsync( method:FrameworkMethod, test:Object, statement:IAsyncStatement ):IAsyncStatement 
	{
		var asyncValue:int = int(method.getSpecificMetaDataArg("TestDriver", "async"));
		
		var async:Boolean = (asyncValue > 0);
		if (async)
		{
			var asyncStatement:ExpectAsync = new ExpectAsync(test, statement);
			AsyncLocator.registerStatementForTest(asyncStatement, getObjectForRegistration(test));
			asyncDelay = asyncValue;
			asyncTestObject = test;
			return asyncStatement as IAsyncStatement;
		}
		return statement;
	}

	/**
	 * 	@private
	 */
    protected function handleAsyncShouldPass(event:Event, passThroughData:Object):void 
    {
    }

	/**
	 * 	@private
	 */
	protected function handleAsyncShouldNotFail(passThroughData:Object):void 
	{
	   	Assert.fail('TestDriver async timer fired with out scripts finishing!');
	}

	/**
	 * 	@private
	 */
	private function getObjectForRegistration(obj:Object):Object 
	{
		var registrationObj:Object;

		if (obj is TestClass) {
			registrationObj = (obj as TestClass).asClass;
		} else {
			registrationObj = obj;
		}
		
		return registrationObj;
	}

}
}