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
import com.structuredlogs.components.skins.DefaultTestPointAssertionRenderer;
import com.structuredlogs.components.skins.ScriptBox;
import com.structuredlogs.components.supportClasses.TestPointAssertionRenderer;
import com.structuredlogs.data.TestPoint;
import com.structuredlogs.data.TestPointScript;
import com.structuredlogs.events.SLogEventLevel;
import com.structuredlogs.utils.JSON;
import com.structuredlogs.utils.SparkDragHelper;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.collections.ArrayCollection;
import mx.collections.IList;
import mx.core.ClassFactory;
import mx.core.IDataRenderer;
import mx.core.IFactory;
import mx.core.UIComponent;
import mx.events.DragEvent;

import spark.components.Button;
import spark.components.Group;
import spark.components.IItemRenderer;
import spark.components.List;
import spark.components.TextInput;
import spark.components.supportClasses.ItemRenderer;
import spark.components.supportClasses.SkinnableComponent;

/**
 *  Dispatched when the user presses the save script button for this component.
 *
 *  @eventType flash.events.Event
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="save", type="flash.events.Event")]

/**
 * 	This Spark component holds the assertion TestPoint values for creating scripts.
 *  When keeps the assertions in its own list for adding and removing, then 
 *  generates a <code>TestPointScript</code> instance when saving or evaulating.
 */
public class TestPointScriptBox extends SkinnableComponent
{
	
	/**
     *  Constructor.
     *  
     */
    public function TestPointScriptBox():void
    {
        super();
        setStyle("skinClass", ScriptBox);
    }


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
    public var inputName:TextInput;
    
    [SkinPart(required="true")]
    /**
     *  A skin part that defines the script identifier textinput. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var inputIdentifier:TextInput;
    
    [SkinPart(required="true")]
    /**
     *  A skin part that defines the script description textinput. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var inputDescription:TextInput;
    
    [SkinPart(required="true")]
    /**
     *  A skin part that defines the script save button. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var saveButton:Button;
    
    [SkinPart(required="true")]
    /**
     *  A skin part that defines the script cancel button. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var cancelButton:Button;

	[SkinPart(required="true")]
    /**
     *  A skin part that defines the list of available assertions. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var assertionList:List;
	
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
	
	
	/**
	 * 	The visual list of assertion TestPoints.
	 */
	protected var availableAssertions:IList;
	
	/**
	 * 	The drag helper class
	 */
    protected var dragHelper:SparkDragHelper;
    
	/**
	 * 	@private
	 * 	The actual testPointScript
	 */
	protected var testPointScript:TestPointScript;
	protected var currentCheckIndex:int = 0;
	
	/**
	 * 	@private
	 * 	saveMode
	 */
	protected var saveMode:Boolean = false;
	
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
	/**
	 * 	The boxLabel for the script box.
	 */
	public var boxLabel:String;
    
	/**
	 * 	The name of this TestPoint test script.
	 */
	public var scriptName:String = "";
	
	/**
	 * 	The identifier of this TestPoint test script.
	 */	
	public var scriptIdentifier:String = "";
	
	/**
	 * 	The description of this TestPoint test script.
	 */	
	public var scriptDescription:String = "";
	
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

	/**
	 * 	Set the test script that is assotiated with this box.
	 */
	public function setScript(script:TestPointScript):void
	{
		// Save out old script
		saveScript();
		
		assertionList.dataProvider.removeAll();
		
		testPointScript = script;
		scriptName = script.name;
		scriptDescription = script.description;
		scriptIdentifier = script.identifier;
		// Loop over script assertions and add to the assertionList dataProvider
		var items:Array = script.getAssertions();
		for each (var assertion:TestPoint in items)
		{
			var newTPAssert:TestPointAssertion = new TestPointAssertion();
			newTPAssert.parseTestPoint(assertion);
			newTPAssert.getTestPoint().testPointScript = script;
			newTPAssert.scriptBox = this;
			addAssertion(newTPAssert);
		}
		
	}

	/**
	 *	Set the state to save script and display script saving form. 
	 */
	public function saveScriptMode():void
	{
		saveMode = true;
		invalidateSkinState();
	}

    /**
     *  @private
     */
    override protected function getCurrentSkinState():String
    {
    	if (saveMode)
            return "saveMode";
            
        return "default";
    }
    
	/**
	 * 	Masking list dataprovider API to be specific to assertions
	 */
	public function addAssertion(assertion:ITestPointAssertion, index:int = -1):void
	{
		if (assertion.getTestPoint().tpuid == "")
			assertion.getTestPoint().tpuid = "tp" + (new Date()).getTime().toString(32);
		assertion.scriptBox = this;
		assertionList.dataProvider.addItemAt(assertion, (index > -1) ? index : assertionList.dataProvider.length);
		clearData();
	}
    
	/**
	 * 	Masking list dataprovider API to be specific to assertions
	 */
	public function moveAssertion(assertion:ITestPointAssertion, newIndex:int):void
	{
		if (assertionList.dataProvider.getItemIndex(assertion) < newIndex)
			newIndex--;
		removeAssertion(assertion);
		addAssertion(assertion, newIndex);
		assertion.scriptBox = this;
		//assertionList.dataProvider.addItemAt(assertion, (index > -1) ? index : assertionList.dataProvider.length);
		
		clearData();
	}
	
	/**
	 * 	Masking list dataprovider API to be specific to assertions
	 */
	public function removeAssertion(assertion:ITestPointAssertion):void
	{
		assertionList.dataProvider.removeItemAt(assertionList.dataProvider.getItemIndex(assertion));
		
		clearData();
	}
	
	/**
	 * 	Receiving data even though we might not have saved out yet.
	 */
	public function checkAssertion(testData:TestPoint):void
	{
		// Update testpointscript?
		var length:int = assertionList.dataProvider.length;
		if (length > 0)
		{	
			var index:int = currentCheckIndex;
			if (index < length)
			{	
				var currentAssertion:TestPoint = (assertionList.dataProvider.getItemAt(index) as TestPointAssertion).getTestPoint();
				var isValid:Boolean = true;
				// Check TestPoint Name
				isValid = (currentAssertion.tpcat == testData.tpcat
							&& currentAssertion.tpname == testData.tpname);
							
				if (isValid)
				{					
					var clone:TestPoint = testData.clone();
					clone.tpuid = currentAssertion.tpuid;
					currentAssertion.setComparingTestPoint(clone);
					currentCheckIndex++;
				}
			}
			
		}
		
		if (testPointScript)
			testPointScript.checkAssertion(testData);
	}
	
	/**
	 * 	Clear data.
	 */
	public function clearData():void
	{
		currentCheckIndex = 0;
		for each (var testAssert:TestPointAssertion in assertionList.dataProvider)
		{
			testAssert.getTestPoint().setComparingTestPoint(null);
		}
		if (testPointScript)
			testPointScript.clearData();
	}

    //--------------------------------------------------------------------------
    //
    //  Overriden Methods
    //
    //--------------------------------------------------------------------------
		
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        // Push down to the part only if the label was explicitly set
        if (instance == inputName)
            inputName.text = scriptName;
        if (instance == inputDescription)
            inputDescription.text = scriptDescription;
        if (instance == inputIdentifier)
            inputIdentifier.text = (scriptIdentifier == "") ? "slt" + (new Date()).getTime().toString(32) : scriptIdentifier;
        if (instance == cancelButton)
        {
        	cancelButton.addEventListener(MouseEvent.CLICK, cancelHandler);
        }
        if (instance == saveButton)
        {
        	saveButton.addEventListener(MouseEvent.CLICK, saveHandler);
        }
        if (instance == assertionList)
        {
        	if (!dragHelper)
        		dragHelper = new SparkDragHelper();
        	assertionList.dataProvider = new ArrayCollection();
        	assertionList.itemRenderer = new ClassFactory(DefaultTestPointAssertionRenderer);
        	assertionList.dataGroup.addEventListener(Event.ADDED, addItemRendererHandler);
        	assertionList.dataGroup.addEventListener(Event.REMOVED, removeItemRendererHandler);
        	
    		dragHelper.registerDrop(this as UIComponent);
        }
    }
    
    protected function addItemRendererHandler(event:Event):void
    {
    	if (event.target is IItemRenderer && event.target is UIComponent)
    	{
    		dragHelper.registerDrag(event.target as UIComponent);
    	}	
    }
    
    protected function removeItemRendererHandler(event:Event):void
    {
    	if (event.target is IItemRenderer && event.target is UIComponent)
    	{
    		dragHelper.unregisterDrag(event.target as UIComponent);
    	}	
    }
    
    protected function cancelHandler(event:MouseEvent):void
    {
    	saveMode = false;
    	invalidateSkinState();
    }
    protected function saveHandler(event:MouseEvent):void
    {
    	// TODO error checking
    	testPointScript.name = inputName.text;
    	testPointScript.identifier = inputIdentifier.text;
    	testPointScript.description = inputDescription.text;
		//var header:Object = {name:inputName.text,identifier:inputIdentifier.text,description:inputDescription.text}
    	// Fire Event Off
    	dispatchEvent(new Event("save"));
    	saveMode = false;
    	invalidateSkinState();
    }   



    /**
     *  Returns the index where the dropped items should be added 
     *  to the drop target.
     *
     *  @param event A DragEvent that contains information about
     *  the position of the mouse. If <code>null</code> the
     *  method should return the <code>dropIndex</code> value from the 
     *  last valid event.
     *
     *  @return Index where the dropped items should be added.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function calculateDropIndex(event:DragEvent = null):int
    {
    	var lastDropIndex:int = assertionList.dataProvider.length;
        if (event)
        {
            var item:IItemRenderer;
            var currentItem:IItemRenderer;
            var lastItem:UIComponent;
            //var pt:Point = new Point(event.localX, event.localY);
            var pt:Point = new Point(assertionList.dataGroup.contentMouseX, assertionList.dataGroup.contentMouseY);
            pt = DisplayObject(event.target).localToGlobal(pt);
            pt = this.parentApplication.globalToLocal(pt);

            var rc:int = assertionList.dataGroup.numElements;
            for (var i:int = 0; i < rc; i++)
            {
            	currentItem = assertionList.dataGroup.getElementAt(i) as IItemRenderer;
                if (currentItem is IItemRenderer)
                    lastItem = currentItem as UIComponent;
                else
                	continue;
	            var pt2:Point = new Point(lastItem.x, lastItem.y);
	            pt2 = DisplayObject(event.target).localToGlobal(pt2);
	            pt2 = this.parentApplication.globalToLocal(pt2);

                if (pt2.y <= pt.y + (lastItem.height/2) && pt.y + (lastItem.height/2) < pt2.y + lastItem.height)
                {
                    //item = lastItem;
                    lastDropIndex = i;
                    break;
                }
            }

        }

        return lastDropIndex;
    }
    
    public function saveScript():TestPointScript
    {
    	if (!testPointScript)
    		testPointScript = new TestPointScript();
    	var assertions:Array = new Array();
    	for each (var assert:TestPointAssertion in assertionList.dataProvider)
    	{
    		assertions.push(assert.getTestPoint());
    	}
    	testPointScript.setAssertions(assertions);
    	return testPointScript;
    }
	
}
}