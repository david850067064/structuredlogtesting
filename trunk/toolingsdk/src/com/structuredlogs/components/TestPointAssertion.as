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

import spark.components.supportClasses.SkinnableComponent;
import spark.primitives.supportClasses.TextGraphicElement;
	
	

/**
 * 	This Spark component holds the assertion TestPoint values for creating scripts.
 *  Along with all the visual logic to create complex assertion logic based on other
 *  <code>TestPointAssertion</code>'s
 */
public class TestPointAssertion extends SkinnableComponent implements ITestPointAssertion
{

    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------

    [SkinPart(required="true")]
    /**
     *  A skin part that defines the name textinput. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var assertionName:TextGraphicElement;
	
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
  
  	protected var assertionSource:TestPoint;


	
	//----------------------------------
    //  scriptBox
    //----------------------------------

	private var _scriptBox:TestPointScriptBox;

    /**
     *  TestPoint assertion associated with this instance.
     *  
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function set scriptBox(value:TestPointScriptBox):void
    {
        _scriptBox = value;
    }

    /**
     *  @private
     */
    public function get scriptBox():TestPointScriptBox          
    {
        return _scriptBox;
    }
	
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
 
	public function parseTestPoint(assertion:TestPoint):void
	{
		assertionSource = assertion.clone();
	}
	
	public function getTestPoint():TestPoint
	{
		return assertionSource;
	}
	
	override public function toString():String
	{
		return (assertionSource) ? assertionSource.toString() : super.toString();
	}
}
}