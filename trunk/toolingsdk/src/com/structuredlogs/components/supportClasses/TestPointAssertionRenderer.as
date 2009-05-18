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

package com.structuredlogs.components.supportClasses
{

import com.structuredlogs.components.ITestPointAssertion;
import com.structuredlogs.components.TestPointDataBox;
import com.structuredlogs.components.skins.SelectionBox;
import com.structuredlogs.data.TestPoint;

import flash.events.MouseEvent;

import mx.core.IFactory;
import mx.events.FlexEvent;

import spark.components.Button;
import spark.components.IItemRenderer;
import spark.components.List;
import spark.components.MXMLComponent;
import spark.primitives.supportClasses.TextGraphicElement;
	
	

/**
 * 	This Spark component the render's TestPointAssertion's in IItemRendererOwner classes.
 */
public class TestPointAssertionRenderer extends MXMLComponent implements IItemRenderer
{

	/**
     *  Constructor.
     *  
     */
    public function TestPointAssertionRenderer():void
    {
        super();
        
        // Initially state is dirty
        dataIsDirty = true;
        
        addHandlers()
    }

    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------

    /**
     *  A skin part that defines the name textinput. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var assertionName:TextGraphicElement;

    /**
     *  A skin part that defines the name move up. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var dataBoxShrinkButton:Button;
    
    /**
     *  A skin part that defines the list of name value pairs. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var dataBox:TestPointDataBox;
	
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
     *  Flag that is set when the mouse is hovered over the item renderer.
     */
    private var hovered:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------


    //----------------------------------
    //  allowDeselection
    //----------------------------------

    /**
     *  @private
     *  Storage for the allowDeselection property 
     */
    private var _allowDeselection:Boolean = true;

    /**
     *  @inheritDoc 
     *
     *  @default true
     */    
    public function get allowDeselection():Boolean
    {
        return _allowDeselection;
    }
    
    /**
     *  @private
     */    
    public function set allowDeselection(value:Boolean):void
    {
        if (value == _allowDeselection)
            return;
            
        _allowDeselection = value;
    }
    
    //----------------------------------
    //  caret
    //----------------------------------

    /**
     *  @private
     *  Storage for the caret property 
     */
    private var _caret:Boolean = false;

    /**
     *  @inheritDoc 
     *
     *  @default false  
     */    
    public function get caret():Boolean
    {
        return _caret;
    }
    
    /**
     *  @private
     */    
    public function set caret(value:Boolean):void
    {
        if (value == _caret)
            return;

        _caret = value;
        currentState = getCurrentRendererState(); 
    }
    
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
            currentState = getCurrentRendererState();
        }
    }
       
    //----------------------------------
    //  labelText
    //----------------------------------
    [Bindable("textChanged")]
    
    /**
     *  @private 
     *  Storage var for labelText
     */ 
    private var _labelText:String = "";
    
    /**
     *  @inheritDoc 
     *
     *  @default ""    
     */
    public function get labelText():String
    {
        return _labelText;
    }
    
    /**
     *  @private
     */ 
    public function set labelText(value:String):void
    {
        if (value != _labelText)
            _labelText = value;
        dispatchEvent(new FlexEvent("textChanged"));
    }
  	
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

	override public function set data(value:Object):void
	{
		super.data = value;
		dataIsDirty = true;
		invalidateProperties();
	}


    /**
     *  @private
     *  Return the skin state. This can be overridden by subclasses to add more states.
     *  NOTE: Undocumented for now since MXMLComponent class has not been fleshed out.
     */
    protected function getCurrentRendererState():String
    {
    	// TODO (jszeto) Add selectedCaret state support (true if selected && caret)
        if (selected)
            return "selected";
        
        if (hovered)
            return "hovered";
        
        // TODO (dsubrama) Caret state support will be turned on when the 
        // packaged renderers support the state visually 
        //if (caret)
        //    return "caret"; 
            
        return "normal";
    }

    /**
     *  @private
     */ 
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (dataIsDirty && data != null)
        {
            dataIsDirty = false;
        	var assertion:ITestPointAssertion = (data as ITestPointAssertion);
        	var testPoint:TestPoint = assertion.getTestPoint()
        	if (assertionName)
        	{
        		var uid:String = (testPoint.tpuid) ? " (" + testPoint.tpuid + ")" : "";
        		assertionName.text = testPoint.tpname + uid;
        	}
        }
    }    

    //--------------------------------------------------------------------------
    //
    //  Event handling
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Attach the mouse events.
     */
    private function addHandlers():void
    {
        addEventListener(MouseEvent.ROLL_OVER, itemRenderer_rollOverHandler);
        addEventListener(MouseEvent.ROLL_OUT, itemRenderer_rollOutHandler);
    }
    
    /**
     *  @private
     *  Mouse rollOver event handler.
     */
    protected function itemRenderer_rollOverHandler(event:MouseEvent):void
    {
        hovered = true;
        currentState = getCurrentRendererState();
    }
    
    /**
     *  @private
     *  Mouse rollOut event handler.
     */
    protected function itemRenderer_rollOutHandler(event:MouseEvent):void
    {
        hovered = false;
        currentState = getCurrentRendererState();
    }
 	
}
}