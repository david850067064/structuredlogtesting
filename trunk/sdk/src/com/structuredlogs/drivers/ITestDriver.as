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
	
import com.structuredlogs.data.TestPointScript;

/**
 * 	Interface for classes that are passed into an instance of the TestDriver class.
 */
public interface ITestDriver
{
	/**
	 *  Method is called when the <code>TestDriver</code> loads a Structured Log File (.slf) 
	 * 	and creates the <code>TestPointScript</code>.
	 */
	function scriptCreatedHandler(script:TestPointScript):void
	
	/**
	 *  Method is called when the <code>TestDriver</code> encounters an error loading a 
	 * 	Structured Log File (.slf) containing a TestPoint script.
	 */
	function scriptErrorHandler(scriptName:String, message:String = ""):void
	
	/**
	 *  Method is called when the <code>TestDriver</code> encounters a <code>TestPointScript</code>
	 *  that is finished comparing all the assertions.
	 */
	function scriptFinishedHandler(script:TestPointScript):void
	
	/**
	 *  Method is called when the <code>TestDriver</code> has finished loading all
	 *  the Structured Log File (.slf) containing a TestPoint scripts.
	 */
	function driverReady():void
}
}