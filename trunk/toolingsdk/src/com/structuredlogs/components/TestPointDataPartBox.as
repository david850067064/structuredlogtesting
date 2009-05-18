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

import com.structuredlogs.components.skins.DataPartBox;
import com.structuredlogs.data.TestPoint;
import com.structuredlogs.data.TestPointDataPart;
import com.structuredlogs.events.TestPointEvent;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.core.IFactory;
import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;

import spark.components.Button;
import spark.components.DropDownList;
import spark.components.IItemRenderer;
import spark.components.List;
import spark.components.MXMLComponent;
import spark.components.TextInput;
import spark.components.supportClasses.SkinnableComponent;
import spark.primitives.supportClasses.TextGraphicElement;
	
	

/**
 * 	This Spark component the render's TestPointAssertion's in IItemRendererOwner classes.
 */
public class TestPointDataPartBox extends SkinnableComponent
{

	/**
     *  Constructor.
     *  
     */
    public function TestPointDataPartBox():void
    {
        super();
        
        // Initially state is dirty
        dataIsDirty = true;
        
        setStyle("skinClass", DataPartBox);
        //addHandlers()
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
    public var labelElement:TextGraphicElement;

    [SkinPart(required="true")]
    /**
     *  A skin part that defines the label of the button. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var editLabelElement:TextGraphicElement;
    
    [SkinPart(required="true")]
    /**
     *  A skin part that defines the script edit value textinput. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var editTypeDropDown:DropDownList;
    
    [SkinPart(required="true")]
    /**
     *  A skin part that defines the script edit value textinput. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var editConstantDropDown:DropDownList;
    
    [SkinPart(required="true")]
    /**
     *  A skin part that defines the script edit value textinput. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var editInputValue:TextInput;
    
    [SkinPart(required="true")]
    /**
     *  A skin part that defines the script edit value textinput. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var editCustomEditor:CustomDataEditor;
    
    [SkinPart(required="true")]
    /**
     *  A skin part that defines the button to go into edit mode. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var editButton:Button;
	
    //--------------------------------------------------------------------------
    //
    //  Private Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Whether the renderer's state is invalid or not.
     */
    private var dataIsDirty:Boolean = false;
    
    /**
     *  @private
     *  Whether the renderer's state is invalid or not.
     */
    private var dataPart:TestPointDataPart;
    private var scriptBox:TestPointScriptBox;
    private var relatedAssertion:ITestPointAssertion;
    
    private var editMode:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    
    //----------------------------------
    //  selected
    //----------------------------------
    /**
     *  @private
     *  storage for the selected property 
     */    
    private var _selected:Boolean = false;
    
    /**
     *  @inheritDoc 
     *
     *  @default false
     */    
    public function get selected():Boolean
    {
        return _selected;
    }
    
    /**
     *  @private
     */    
    public function set selected(value:Boolean):void
    {
        if (value != _selected)
        {
            _selected = value;
        }
    }
       
  	
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

	public function setDataPart(value:TestPointDataPart):void
	{
		
		dataPart = value;
		dataPart.testPoint.addEventListener(TestPointEvent.ASSERTION_CHECK, checkHandler);
		dataIsDirty = true;
		invalidateProperties();
	}

	public function setScriptBox(value:ITestPointAssertion):void
	{
		relatedAssertion = value;
		scriptBox = value.scriptBox;
		dataIsDirty = true;
		invalidateProperties();
	}

	public function setEditMode():void
	{
		editMode = !editMode;
		if (editMode)
		{
			setupEditElements();
		}
		invalidateSkinState();
	}
	
	protected function saveEditValues():void
	{
		dataPart.valueType = editTypeDropDown.selectedItem;
		if (editTypeDropDown.selectedItem == TestPointDataPart.TYPE_VALUE)
		{
			dataPart.value = editInputValue.text;
		}
		else if (editTypeDropDown.selectedItem == TestPointDataPart.TYPE_CONSTANT)
		{			
			if (editConstantDropDown.selectedItem === "true")
				dataPart.value = true;
			if (editConstantDropDown.selectedItem === "false")
				dataPart.value = false;
			if (editConstantDropDown.selectedItem === "null")
				dataPart.value = null;
		}
		else if (editTypeDropDown.selectedItem == TestPointDataPart.TYPE_CUSTOM)
		{			
			dataPart.value = editCustomEditor.getValueObject();
		}
		dataIsDirty = true;
		invalidateProperties();
	}
	
	/**
	 * 	Setup for edit fields on start and if they user changes the types while editing.
	 */
	protected function setupEditElements():void
	{
		// Type DropDown
		//editTypeDropDown.selectedItem = dataPart.valueType;
		// editTypeDropDown.prompt = dataPart.valueType;
		for (var i:int = 0; i < editTypeDropDown.dataProvider.length; i++)
		{
			if (editTypeDropDown.dataProvider[i] == dataPart.valueType)
			{
				editTypeDropDown.selectedIndex = i;
				break;
			}
		}

		if (dataPart.valueType == TestPointDataPart.TYPE_VALUE)
		{
			editInputValue.text = dataPart.value;
		}
		else if (dataPart.valueType == TestPointDataPart.TYPE_CONSTANT)
		{			
			var index:int = -1;
			// Constant DropDown
			if (dataPart.value === true)
				index = 0;
			if (dataPart.value === false)
				index = 1;
			if (dataPart.value === null)
				index = 2;
			if (index > -1)
			{
				editConstantDropDown.selectedIndex = index;
				editConstantDropDown.prompt = editConstantDropDown.selectedItem;
			}	
		}
		else if (dataPart.valueType == TestPointDataPart.TYPE_CUSTOM)
		{
			
		}
	}

	public function closeDataEdit(save:Boolean):void
	{
		if (save)
		{
			// DO SAVE HERE
			saveEditValues();
		}
		editMode = false;
		invalidateSkinState();		
	}
	
    
    private function typeChangeHandler(event:IndexChangedEvent):void
    {
    	invalidateSkinState();
    }

		
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
    	super.partAdded(partName, instance);
        
        // Push down to the part only if the label was explicitly set
        if (instance == editTypeDropDown)
        {
        	editTypeDropDown.dataProvider = new ArrayCollection([TestPointDataPart.TYPE_VALUE, 
        															TestPointDataPart.TYPE_CONSTANT, 
        															TestPointDataPart.TYPE_CUSTOM]);
        	editTypeDropDown.addEventListener(IndexChangedEvent.SELECTION_CHANGED, typeChangeHandler);
        }
        if (instance == editConstantDropDown)
        {
        	editConstantDropDown.dataProvider = new ArrayCollection(["true", 
        															"false", 
        															"null"]);
        }
        if (instance == editCustomEditor)
        {
			dataIsDirty = true;
			invalidateProperties();
        }
    }

    /**
     *  @private
     */
    override protected function getCurrentSkinState():String
    {
    	if (editMode)
    	{
    		if (editTypeDropDown.selectedItem == TestPointDataPart.TYPE_CONSTANT)
				return "editModeTypeConstant";
			else if (editTypeDropDown.selectedItem == TestPointDataPart.TYPE_CUSTOM)
				return "editModeTypeCustom";
			else
            	return "editMode";
		}
		if (dataPart.comparingDataPart != null)
		{
			return (dataPart.passed) ? "passed" : "failed";
		}
            
        return "default";
    }

    /**
     *  @private
     */ 
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (dataIsDirty && dataPart != null)
        {
            dataIsDirty = false;
            if (labelElement)
           		labelElement.text = getAssertText();
            
            if (editCustomEditor && dataPart)
            {
        		editCustomEditor.valueObject = dataPart.value;
        		editCustomEditor.relatedAssertion = relatedAssertion;
        		editCustomEditor.scriptBox = scriptBox;
            }
        }
    }    
    //--------------------------------------------------------------------------
    //
    //  Event handling
    //
    //--------------------------------------------------------------------------
    
    public function getAssertText():String
    {
    	var compareData:String = "";
    	if (dataPart.comparingDataPart)
    		compareData = dataPart.comparingDataPart.value;
    	return dataPart.toString() + " = " + compareData;
    }
    
    protected function checkHandler(event:Event):void
    {
    	dataIsDirty = true;
    	invalidateProperties();
    	invalidateSkinState();
    }
 	
}
}