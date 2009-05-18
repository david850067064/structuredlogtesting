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

package com.structuredlogs.components
{
	import com.structuredlogs.data.TestPoint;
	
	

/**
 * 	This Spark component holds the assertion TestPoint values for creating scripts.
 *  When keeps the assertions in its own list for adding and removing, then 
 *  generates a <code>TestPointScript</code> instance when saving or evaulating.
 */
public interface ITestPointAssertion
{
	
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
  
	
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
 
 	/**
 	 * 	Parse TestPoint for structure of the assertion logic.
 	 */
 	function parseTestPoint(assertion:TestPoint):void;
 	
 	/**
 	 * 	Get TestPoint the defined assertion logic.
 	 */
 	function getTestPoint():TestPoint;
 	
 	/**
 	 * 	Get TestPointScriptBox that this assertion is tied to.
 	 */
 	function set scriptBox(value:TestPointScriptBox):void;
 	
 	/**
 	 * 	Set TestPointScriptBox that this assertion is tied to.
 	 */
 	function get scriptBox():TestPointScriptBox;
 	
 
}
}