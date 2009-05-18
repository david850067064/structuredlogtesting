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

package com.structuredlogs.utils
{
import com.structuredlogs.components.ITestPointAssertion;
import com.structuredlogs.components.TestPointAssertion;
import com.structuredlogs.components.TestPointScriptBox;
import com.structuredlogs.components.TestPointSelectionBox;
import com.structuredlogs.components.skins.DefaultTestPointAssertionRenderer;
import com.structuredlogs.data.TestPoint;

import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.describeType;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import mx.core.DragSource;
import mx.core.EventPriority;
import mx.core.IDataRenderer;
import mx.core.IFlexDisplayObject;
import mx.core.UIComponent;
import mx.events.DragEvent;
import mx.managers.DragManager;
import mx.skins.halo.ListDropIndicator;

import spark.components.IItemRenderer;
import spark.components.IItemRendererOwner;
import spark.components.List;
import spark.components.TextInput;
import spark.skins.*;
import spark.utils.LabelUtil;


/**
 * 	A drag and drop helper class until spark components support drag and drop.
 */
public class SparkDragHelper
{

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

	private var mouseDownPoints:Object = new Object();;
	private var isPresseds:Object = new Object();
	private var components:Object = new Object();
	private var globalApplication:UIComponent;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

	public var moveThreshold:int = 4;

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *	Register the UIComponent that want drag and drop implemented. 
     */
    public function registerDrag(comp:UIComponent):void
    {
    	if (!(comp is UIComponent))
    		return;
    	if (!globalApplication)
    		globalApplication = comp.parentApplication as UIComponent;
    	
    	if (!components[comp])
    		components[comp] = comp;
		components[comp].addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true) 
		components[comp].addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true)  
		components[comp].addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true)  
    }
    public function unregisterDrag(comp:UIComponent):void
    {
    	if (!(comp is UIComponent))
    		return;
    	if (!globalApplication)
    		globalApplication = comp.parentApplication as UIComponent;
    	
    	//if (!components[comp])
    	//	components[comp] = comp;
		components[comp].removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler); 
		components[comp].removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);  
		components[comp].removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		isPresseds[comp] = null;
		mouseDownPoints[comp] = null;
		components[comp] = null;
		 
    }

    /**
     *	Register the UIComponent that want drag and drop implemented. 
     */
    public function registerDrop(comp:UIComponent):void
    {
    	if (!(comp is UIComponent))
    		return;
    	if (!globalApplication)
    		globalApplication = comp.parentApplication as UIComponent;
    	if (!components[comp])
    		components[comp] = comp;
        components[comp].addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler, false,
                         EventPriority.DEFAULT_HANDLER);
        components[comp].addEventListener(DragEvent.DRAG_EXIT, dragExitHandler, false,
                         EventPriority.DEFAULT_HANDLER);
        components[comp].addEventListener(DragEvent.DRAG_OVER, dragOverHandler, false,
                         EventPriority.DEFAULT_HANDLER);
        components[comp].addEventListener(DragEvent.DRAG_DROP, dragDropHandler, false,
                         EventPriority.DEFAULT_HANDLER);
    }    
    
    /**
     * 
     */
    protected function mouseDownHandler(event:MouseEvent):void
    {
    	if (event.target.toString().indexOf("DataPartBox") > 0)
    	{
    		return;
    	}
		var comp:UIComponent = (event.currentTarget as UIComponent);
		//trace("MD: " + event.currentTarget + "\n" + event.target);
        if (!comp)
        	return;
		var pt:Point = new Point(event.localX, event.localY);
        pt = DisplayObject(comp).localToGlobal(pt);
        pt = globalApplication.globalToLocal(pt);
        mouseDownPoints[comp] = pt;
        isPresseds[comp] = true;
    }  
       
    /**
     * 
     */  
    protected function mouseMoveHandler(event:MouseEvent):void
    {
    	if (event.target.toString().indexOf("DataPartBox") > 0)
    	{
    		return;
    	}
        var comp:UIComponent = (event.currentTarget as UIComponent);
        if (!comp
        	|| !isPresseds[comp]
        	|| !mouseDownPoints[comp])
        	return;
        trace("MOUSEMOVE: " + event.target + "\nCurrent: " + event.currentTarget);
		var pt:Point = new Point(event.localX, event.localY);
        pt = DisplayObject(comp).localToGlobal(pt);
        pt = globalApplication.globalToLocal(pt);

        var mouseDownPoint:Point = mouseDownPoints[comp] as Point;
		//trace("MOUSEMOVE: " + describeType(event.currentTarget).toXMLString().substr(0, 120));
        if (!DragManager.isDragging &&
        	(Math.abs(mouseDownPoint.x - pt.x) > moveThreshold ||
             Math.abs(mouseDownPoint.y - pt.y) > moveThreshold))
        {
        	isPresseds[comp] = false;
        	mouseDownPoints[comp] = null;
			var dragSource:DragSource = new DragSource();
			var data:Object = (comp as IItemRenderer).data;
			var rendererClass:Class = getDefinitionByName(getQualifiedClassName(comp)) as Class;
			var dragItem:UIComponent = new rendererClass();
			(dragItem as IDataRenderer).data = data;
			dragItem.width = comp.width;
			dragItem.height = comp.height;	
			IItemRenderer(dragItem).labelText = data.toString();//LabelUtil.itemToLabel(data, list.labelField, list.labelFunction);;
						
			dragSource.addData(IItemRenderer(comp).data, "assertion");
			DragManager.doDrag(comp, dragSource, event, dragItem, 0, 0, 0.6, true);
        }
    }   
     
    /**
     * 
     */
    protected function mouseUpHandler(event:MouseEvent):void
    {
    	var comp:UIComponent = (event.currentTarget as UIComponent);
    	if (!comp)
    		return;
    	comp.stopDrag();
    	isPresseds[comp] = false;
    }



    /**
     *  Handles <code>DragEvent.DRAG_ENTER</code> events.  This method
     *  determines if the DragSource object contains valid elements and uses
     *  the <code>showDropFeedback()</code> method to set up the UI feedback.
     *
     *  @param event The DragEvent object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function dragEnterHandler(event:DragEvent):void
    {
        if (event.isDefaultPrevented())
            return;

        DragManager.acceptDragDrop(event.currentTarget as UIComponent);
        DragManager.showFeedback(event.ctrlKey ? DragManager.COPY : DragManager.MOVE);
        //showDropFeedback(event);
    }

    /**
     *  Handles <code>DragEvent.DRAG_OVER</code> events. This method
     *  determines if the DragSource object contains valid elements and uses
     *  the <code>showDropFeedback()</code> method to set up the UI feeback.
     *
     *  @param event The DragEvent object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function dragOverHandler(event:DragEvent):void
    {
        if (event.isDefaultPrevented())
            return;
		//if (event.dragInitiator is DefaultTestPointAssertionRenderer)
		//{
        	DragManager.showFeedback(event.ctrlKey ? DragManager.COPY : DragManager.MOVE);
		//}
        //showDropFeedback(event);
    }

    /**
     *  Handles <code>DragEvent.DRAG_EXIT</code> events. This method hides
     *  the UI feeback by calling the <code>hideDropFeedback()</code> method.
     *
     *  @param event The DragEvent object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function dragExitHandler(event:DragEvent):void
    {
        if (event.isDefaultPrevented())
            return;

        //hideDropFeedback(event);
        
        DragManager.showFeedback(DragManager.NONE);
    }

    /**
     *  Handles <code>DragEvent.DRAG_DROP events</code>. This method  hides
     *  the drop feedback by calling the <code>hideDropFeedback()</code> method.
     *
     *  <p>If the action is a <code>COPY</code>, 
     *  then this method makes a deep copy of the object 
     *  by calling the <code>ObjectUtil.copy()</code> method, 
     *  and replaces the copy's <code>uid</code> property (if present) 
     *  with a new value by calling the <code>UIDUtil.createUID()</code> method.</p>
     * 
     *  @param event The DragEvent object.
     *
     *  @see mx.utils.ObjectUtil
     *  @see mx.utils.UIDUtil
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function dragDropHandler(event:DragEvent):void
    {   
        if (event.isDefaultPrevented())
            return;


    	if (event.target is TextInput
    		|| event.currentTarget is TextInput)
    	{
    		return;
    	}
        //hideDropFeedback(event);

        if (event.target is TestPointScriptBox)
        {
        	//trace("dragDropHandler::HERE");
        	var testPoint:ITestPointAssertion = event.dragSource.dataForFormat("assertion") as ITestPointAssertion;
        	var index:int = (event.target as TestPointScriptBox).calculateDropIndex(event);
			if (event.dragInitiator is DefaultTestPointAssertionRenderer)
				(event.target as TestPointScriptBox).moveAssertion(testPoint, index);
			else
			{
				testPoint.scriptBox = (event.target as TestPointScriptBox);
        		(event.target as TestPointScriptBox).addAssertion(testPoint, index);
			}
        }

    }
    
    
    
    /**
     *  Displays a drop indicator under the mouse pointer to indicate that a
     *  drag and drop operation is allowed and where the items will
     *  be dropped.
     *
     *  @param event A DragEvent object that contains information as to where
     *  the mouse is.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function showDropFeedback(event:DragEvent):void
    {
        if (!dropIndicator)
        {
            dropIndicator = IFlexDisplayObject(new ListDropIndicator());

            dropIndicator.x = 2;
            dropIndicator.setActualSize((event.target as UIComponent).width - 4, 4);
            dropIndicator.visible = true;
            (event.target as UIComponent).addChild(DisplayObject(dropIndicator));
        }

    }

    /**
     *  Hides the drop indicator under the mouse pointer that indicates that a
     *  drag and drop operation is allowed.
     *
     *  @param event A DragEvent object that contains information about the
     *  mouse location.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function hideDropFeedback(event:DragEvent):void
    {
        if (dropIndicator)
        {
            DisplayObject(dropIndicator).parent.removeChild(DisplayObject(dropIndicator));
            dropIndicator = null;
        }
    }
    
    protected var dropIndicator:IFlexDisplayObject;
}
}