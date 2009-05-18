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
import com.structuredlogs.components.skins.CustomDataEditorSkin;
import com.structuredlogs.data.TestPoint;
import com.structuredlogs.data.TestPointDataPart;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.controls.Text;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.events.IndexChangedEvent;

import spark.components.Button;
import spark.components.DropDownList;
import spark.components.Group;
import spark.components.SkinnableContainer;
import spark.components.TextInput;
import spark.components.supportClasses.ItemRenderer;
import spark.components.supportClasses.SkinnableComponent;
import spark.primitives.SimpleText;
import spark.primitives.supportClasses.TextGraphicElement;
	

/**
 * 	This Spark component holds the assertion TestPoint name value pairs inside a TestPointAssertion 
 *  instance.
 */
public class CustomDataEditor extends SkinnableComponent
{
	/**
     *  Constructor.
     *  
     */
    public function CustomDataEditor():void
    {
        super();
        //skinClass="com.structuredlogs.components.skins.SelectionBox"
        setStyle("skinClass", CustomDataEditorSkin);
        logicLookup = createCustomLogicData();
        paramElements = new Array();
    }

    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    [SkinPart(required="true")]
    /**
     *  A skin part that defines which custom operator you want to use. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var operatorDropDown:DropDownList;

	[SkinPart(required="true")]
    /**
     *  A skin part that defines the editor part to link parameters to other
     *  TestPoint comparingData values.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var linkedGroup:Group;

	[SkinPart(required="true")]
    /**
     *  A skin part that defines the editor part for the paramaters for the specific operator.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var parameterGroup:Group;

	[SkinPart(required="true")]
    /**
     *  A skin part that defines the editor part selecting of previous TestPoint for linked type.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var previousAssertions:DropDownList;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
	
	protected var logicLookup:Object;
	protected var linkedMode:Boolean = false;
	protected var paramElements:Array;
	
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

	[Bindable]
	public function get color1():Number
	{
		return 0xBBCCBB;
	}
	public function set color1(value:Number):void
	{
		;
	}
	
	public var scriptBox:TestPointScriptBox;
	public var relatedAssertion:ITestPointAssertion;
	
	//----------------------------------
    //  valueObject
    //----------------------------------

	private var origValueObject:Object;
	public function set valueObject(value:Object):void
	{
		origValueObject = value;
		setupData();
	}

    /**
     *  @private
     */
    public function getValueObject():Object          
    {
    	var object:Object = new Object();
		var logicName:String = operatorDropDown.selectedItem.toString();
		var logicObj:Object = logicLookup[logicName];
		object.tpop = logicObj.op;
		object.tptype = logicObj.type;
		object.params = [];
		for each (var element:* in paramElements)
    	{
    		if (element is TextInput)
    		{
    			object.params.push((element as TextInput).text);
    		}
    		else
    		{
    			object.params.push({tpop:"linked", tptype: "slt", 
    				params: [{tpname: element.tpname, tpuid: element.tpuid, tpkey: element.tpkey}]});
    		}
    	}

        return object;
    }
	
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

	
    //--------------------------------------------------------------------------
    //
    //  Overriden Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function getCurrentSkinState():String
    {
    	if (linkedMode)
            return "linkedMode";
            
        return "default";
    }
		
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        // Push down to the part only if the label was explicitly set
        if (instance == operatorDropDown)
        {
        	//operatorDropDown.requiresSelection = true;
        	var ac:ArrayCollection = new ArrayCollection();
        	for (var logicKey:String in logicLookup)
        		ac.addItem(logicKey);
        	ac.sort = new Sort();
        	ac.refresh();
            operatorDropDown.dataProvider = ac;
        	operatorDropDown.addEventListener(IndexChangedEvent.SELECTION_CHANGED, typeChangeHandler);
			setupData();
        }
        if (instance == linkedGroup)
        {
        }
        if (instance == previousAssertions)
        {
			previousAssertions.labelField = "label";
        	previousAssertions.addEventListener(IndexChangedEvent.SELECTION_CHANGED, selectLinkedHandler);
        }
    }
    
    /**
     *	Setup initial data. 
     */
    protected function setupData():void
    {
    	if (!operatorDropDown || !origValueObject)
    		return;
    	try
    	{
    		if (origValueObject["tptype"] != undefined)
    		{
    			operatorDropDown.selectedItem = origValueObject.tptype + "|" + origValueObject.tpop;
    		}
    			
    	}
    	catch (error:Error)
    	{
    		
    	}
    }
    
    protected function typeChangeHandler(event:IndexChangedEvent):void
    {
    	if (event.newIndex < 0 || operatorDropDown.dataProvider.length == 0
    		|| !parameterGroup)
    		return;
    	var logicName:String = operatorDropDown.dataProvider.getItemAt(event.newIndex).toString();
    	// Create paramterGroup
    	setupParamterGroup(logicLookup[logicName], logicLookup[logicName].paramCount);
    }
    protected function setupParamterGroup(logicData:Object, numParams:int):void
    {
    	paramElements = new Array();
    	var i:int = 0;
    	var input:TextInput;
    	var label:TextGraphicElement;
    	// Clear out elements
    	for (i = 0; i < parameterGroup.numElements; i++)
    	{
    		if (parameterGroup.getElementAt(i) is TextInput)
    		{
    			input = parameterGroup.getElementAt(i) as TextInput;
    			input.removeEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
    		}
    	}
    	parameterGroup.removeAllElements();
    	// Create the number of params
    	if (logicData["displayPrefix"] != undefined)
    	{
    		label = new SimpleText();
			label.setStyle("verticalCenter", 0);
			//if (label.height == 0)
			//	label.height = this.height;
			label.setStyle("fontWeight", "bold");
    		//label.width = 20; 
    		label.text = logicData["displayPrefix"];
    		parameterGroup.addElement(label);
    	}
    	for (i = 0; i < numParams; i++)
    	{
    		// Separator after first item
    		if (logicData["displaySepartor"] != undefined && i > 0)
	    	{
	    		label = new SimpleText();
				label.setStyle("verticalCenter", 0);
	    		//if (label.height == 0)
				//	label.height = this.height;
	    		label.setStyle("fontWeight", "bold");
	    		label.text = logicData["displaySepartor"];
	    		parameterGroup.addElement(label);
	    	}
	    	if (!(origValueObject is Number || origValueObject is String)
	    		&& origValueObject.params
	    		&& !(origValueObject.params[i] is Number || origValueObject.params[i] is String)
	    		&& origValueObject.params[i]["tpop"] 
	    		&& origValueObject.params[i]["tpop"] == "linked")
	    	{
	    		var linked:SimpleText = new SimpleText();
				linked.setStyle("verticalCenter", 0);
				linked.setStyle("fontWeight", "bold");
				linked.text = origValueObject.params[i].params[0].tpname + "("+origValueObject.params[i].params[0].tpuid+")"+origValueObject.params[i].params[0].tpkey;
				
		    	parameterGroup.addElement(linked);
		    	var button:Button = new Button();
		    	button.width = 10;
		    	button.height = 10;
		    	button.top = 8;
		    	button.addEventListener(MouseEvent.CLICK, linkedButtonHandler, false, 0 , true);
		    	paramTextLookup[button.id] = linked;
		    	parameterGroup.addElement(button);
		    	paramElements[i] = origValueObject.params[i].params[0];
    		}
    		else
    		{
    			input = new TextInput();
	    		input.width = 40;
	    		input.doubleClickEnabled = true;
	    		input.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler, false, 0, true);
	    		if (!(origValueObject is Number || origValueObject is String)
	    			&& origValueObject.params)
	    			input.text = (origValueObject.params[i]) + "";
	    		parameterGroup.addElement(input);
	    		paramElements[i] = input;
    		}
    	}
    }
    protected var doubleClickParam:TextInput;
    protected function doubleClickHandler(event:MouseEvent):void
    {
    	if (!linkedMode)
    	{
    		doubleClickParam = event.currentTarget as TextInput;
    		goLinkedMode();
    	}
    }
    protected function goLinkedMode():void
    {
    	linkedGroup.x = ((parent.width/2) - (linkedGroup.width/2)) - this.x;
		
		var previousItems:ArrayCollection = new ArrayCollection();
		// Get previous assertions
		if (scriptBox)
		{
			// Loop the TestPoint's
			for each (var assert:TestPointAssertion in scriptBox.assertionList.dataProvider)
			{
				if (assert == relatedAssertion)
					break;
					
				var testPoint:TestPoint = assert.getTestPoint();
				for each (var dataPart:TestPointDataPart in testPoint.dataParts)
				{
					previousItems.addItem({label: assert.getTestPoint().tpname+"("+assert.getTestPoint().tpuid+")" + "." + dataPart.name, 
					tpname: testPoint.tpname, tpuid: testPoint.tpuid, tpkey: dataPart.name});
				}
			}
		}
		previousAssertions.dataProvider = previousItems;
		
		if (previousAssertions && previousAssertions.dataProvider.length > 0)
		{
    		linkedMode = true;
    		invalidateSkinState();
		}
    }
    public function closeLinkedMode():void
    {
    	doubleClickParam = null;
    	linkedMode = false;
    	invalidateSkinState();
    }
    protected function selectLinkedHandler(event:Event):void
    {
    	if (previousAssertions.dataProvider.length == 0)
    		return;
    	var selected:Object = previousAssertions.selectedItem;
    	var paramIndex:int = 0;
    	for (var k:int = 0; k < paramElements.length; k++)
    	{
    		if (paramElements[k] is IVisualElement && paramElements[k] == doubleClickParam)
    			break;
    		paramIndex++;
    	}
    	doubleClickParam.removeEventListener(MouseEvent.CLICK, doubleClickHandler);
    	var index:int = parameterGroup.getElementIndex(doubleClickParam);
    	parameterGroup.removeElement(doubleClickParam);
    	var linked:SimpleText = new SimpleText();
		linked.setStyle("verticalCenter", 0);
		linked.setStyle("fontWeight", "bold");
		linked.text = selected.label;
    	parameterGroup.addElementAt(linked, index);
    	var button:Button = new Button();
    	button.width = 10;
    	button.height = 10;
    	button.top = 8;
    	button.addEventListener(MouseEvent.CLICK, linkedButtonHandler, false, 0 , true);
    	paramTextLookup[button.id] = linked;
    	parameterGroup.addElementAt(button, index+1);
    	paramElements[paramIndex] = selected;
    	previousAssertions.dataProvider.removeAll();
    	closeLinkedMode();
    }
    private var paramTextLookup:Object = new Object();
    protected function linkedButtonHandler(event:MouseEvent):void
    {
    	var button:Button = (event.currentTarget as Button);
    	button.removeEventListener(MouseEvent.CLICK, linkedButtonHandler);
    	var linked:SimpleText = paramTextLookup[button.id];
    	var index:int = parameterGroup.getElementIndex(linked);
    	parameterGroup.removeElement(linked);
    	parameterGroup.removeElement(button);
		var input:TextInput = new TextInput();
		input.width = 40;
		input.doubleClickEnabled = true;
		input.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler, false, 0, true);
		parameterGroup.addElementAt(input, index);
    	paramElements[index] = input;
    }
    
    
    
    private function createCustomLogicData():Object
    {
    	var logic:Object = new Object();
    	logic["slt|minus"] = {op: "minus", type: "slt", paramCount: 2, displaySepartor: " - " };
    	logic["slt|add"] = {op: "add", type: "slt", paramCount: 2, displaySepartor: " + "};
    	logic["hamcrest|greaterThan"] = {op: "greaterThan", type: "hamcrest", paramCount: 1, displayPrefix: " > "};
    	logic["hamcrest|lessThan"] = {op: "lessThan", type: "hamcrest", paramCount: 1, displayPrefix: " < "};
    	return logic;
    }
    
}
}