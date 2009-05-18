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
import com.structuredlogs.components.skins.SelectionBox;
import com.structuredlogs.components.supportClasses.IHostBox;
import com.structuredlogs.data.TestPoint;
import com.structuredlogs.events.SLogEventLevel;
import com.structuredlogs.utils.SparkDragHelper;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.collections.ArrayCollection;
import mx.collections.IList;
import mx.controls.listClasses.ListItemDragProxy;
import mx.core.DragSource;
import mx.core.IDataRenderer;
import mx.core.IFactory;
import mx.core.IUIComponent;
import mx.core.UIComponent;
import mx.events.FlexEvent;
import mx.managers.DragManager;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;

import spark.components.IItemRenderer;
import spark.components.List;
import spark.components.SkinnableContainer;
import spark.components.supportClasses.ItemRenderer;
import spark.components.supportClasses.SkinnableComponent;
import spark.primitives.supportClasses.TextGraphicElement;
	

/**
 * 	This Spark component holds the assertion TestPoint values for creating scripts.
 *  When keeps the assertions in its own list for adding and removing, then 
 *  generates a <code>TestPointScript</code> instance when saving or evaulating.
 */
public class TestPointSelectionBox extends SkinnableComponent implements IHostBox
{
	/**
     *  Constructor.
     *  
     */
    public function TestPointSelectionBox():void
    {
        super();
        //skinClass="com.structuredlogs.components.skins.SelectionBox"
        setStyle("skinClass", SelectionBox);
    }

    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------

    [SkinPart(required="true")]
    /**
     *  A skin part that defines the label of the button. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var labelElement:TextGraphicElement;

	[SkinPart(required="true")]
    /**
     *  A skin part that defines the list of available assertions. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var listElement:List;

	[Bindable]
	public function get color1():Number
	{
		return 0x336699;
	}
	public function set color1(value:Number):void
	{
		;
	}

	//----------------------------------
    //  label
    //----------------------------------

	private var _label:String = "";

    [Bindable("contentChange")]

    /**
     *  Text to along with the list of assertions.
     *  
     *  @default ""
     *  @eventType contentChange
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function set label(value:String):void
    {
        // label property is just a proxy to the content.
        // The content setter will dispatch the event.
        _label = value;
        dispatchEvent(new Event("contentChange"));
    }

    /**
     *  @private
     */
    public function get label():String          
    {
        return _label;
    }
	
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    	
	/**
	 * 	The visual list of assertion TestPoints.
	 */
	protected var availableAssertions:IList;
	
	
    protected var dragHelper:SparkDragHelper;
	
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
	/**
	 * 	Masking list dataprovider API to be specific to assertions
	 */
	public function addAssertion(assertion:TestPoint, index:int = -1):void
	{
		// Add if unique
		assertions.addItemAt(assertion, (index > 0) ? index : availableAssertions.length);
	}
	
	/**
	 * 	Set assertions
	 */
	public function set assertions(value:IList):void
	{
		availableAssertions = value;
		if (listElement)
			listElement.dataProvider = availableAssertions;
	}
	
	/**
	 * 	Get assertions
	 */
	public function get assertions():IList
	{
		if (!availableAssertions)
		{
			availableAssertions = new ArrayCollection();
			if (listElement)
				listElement.dataProvider = availableAssertions;
		}
		return availableAssertions;
	}
	
	/**
	 * 	Masking list dataprovider API to be specific to assertions
	 */
	public function removeAssertion(assertion:TestPoint):void
	{
		availableAssertions.removeItemAt(availableAssertions.getItemIndex(assertion));
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
        if (instance == labelElement)
            labelElement.text = label;
        if (instance == listElement)
        {
        	if (!dragHelper)
        		dragHelper = new SparkDragHelper();
        	listElement.dataProvider = availableAssertions;
        	listElement.dataGroup.addEventListener(Event.ADDED, addItemRendererHandler);
        	listElement.dataGroup.addEventListener(Event.REMOVED, removeItemRendererHandler);
        	
    		//dragHelper.registerDrop(this as UIComponent);
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
	
}
}