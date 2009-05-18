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
import com.structuredlogs.components.skins.DataBox;
import com.structuredlogs.components.supportClasses.IHostBox;
import com.structuredlogs.data.TestPoint;
import com.structuredlogs.data.TestPointDataPart;
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
import mx.core.ClassFactory;
import mx.core.DragSource;
import mx.core.IDataRenderer;
import mx.core.IFactory;
import mx.core.IUIComponent;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.events.FlexEvent;
import mx.managers.DragManager;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;
import mx.utils.ArrayUtil;
import mx.utils.ObjectUtil;

import spark.components.Button;
import spark.components.Group;
import spark.components.IItemRenderer;
import spark.components.List;
import spark.components.SkinnableContainer;
import spark.components.TextInput;
import spark.components.supportClasses.ItemRenderer;
import spark.components.supportClasses.SkinnableComponent;
import spark.primitives.supportClasses.TextGraphicElement;
	

/**
 * 	This Spark component holds the assertion TestPoint name value pairs inside a TestPointAssertion 
 *  instance.
 */
public class TestPointDataBox extends SkinnableComponent implements IHostBox
{
	/**
     *  Constructor.
     *  
     */
    public function TestPointDataBox():void
    {
        super();
        //skinClass="com.structuredlogs.components.skins.SelectionBox"
        setStyle("skinClass", DataBox);
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
    public var dataGroup:Group;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
	
	/**
	 * 	@private
	 * 	saveMode
	 */
	protected var editFlag:Boolean = false;
    
    protected var dragHelper:SparkDragHelper;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
	

	[Bindable]
	public function get color1():Number
	{
		return 0xBBBBBB;
	}
	public function set color1(value:Number):void
	{
		;
	}
	
	//----------------------------------
    //  label
    //----------------------------------

	private var _label:String = "TestPoint Data";

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
	
	//----------------------------------
    //  assertionTestPoint
    //----------------------------------

	private var _assertionTestPoint:ITestPointAssertion;


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
    public function set assertionTestPoint(value:ITestPointAssertion):void
    {
        _assertionTestPoint = value;
        setupData();
    }

    /**
     *  @private
     */
    public function get assertionTestPoint():ITestPointAssertion          
    {
        return _assertionTestPoint;
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
    	if (editFlag)
            return "editMode";
            
        return "default";
    }
		
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        // Push down to the part only if the label was explicitly set
        if (instance == labelElement)
        {
            labelElement.text = label;
            labelElement.setStyle("textAlign", "left");
            labelElement.setStyle("fontSize", 11);
        }
        if (instance == dataGroup)
        {
        	setupData();
        }
        /*
        if (instance == listElement)
        {
        	listElement.dataProvider = new ArrayCollection();
        	setupData();
    		if (!dragHelper)
    			dragHelper = new SparkDragHelper();
        	listElement.itemRenderer = new ClassFactory(DefaultTestPointDataRenderer);
        	listElement.dataGroup.addEventListener(Event.ADDED, addItemRendererHandler);
        	listElement.dataGroup.addEventListener(Event.REMOVED, removeItemRendererHandler);
        	
    		//dragHelper.registerDrop(this as UIComponent);
        }
        */
    }
    protected function setupData():void
    {
    	if (!dataGroup || !assertionTestPoint)
			return;
    	var nvp:Object = assertionTestPoint.getTestPoint().dataParts;
    	for each (var dataPart:TestPointDataPart in nvp)
    	{
    		var element:TestPointDataPartBox = new TestPointDataPartBox();
    		element.setDataPart(dataPart);
    		element.setScriptBox(assertionTestPoint);
    		element.percentWidth = 100;
    		dataGroup.addElement(element);
    	}
    	label = "Name Value Pair's (" + assertionTestPoint.getTestPoint().numDataParts + ")";
    	if (labelElement)
    		labelElement.text = label;
    }
    
    private var lastHeight:Number = 0;
    private var toggle:Boolean = false;
    public function hideList():void
    {
    	if (!toggle)
    	{
    		dataGroup.visible = false;
    		dataGroup.includeInLayout = false;
    	}
    	else
    	{
    		
    		dataGroup.visible = true;
    		dataGroup.includeInLayout = true;
    		
    	}
    	toggle = !toggle;
    }
}
}