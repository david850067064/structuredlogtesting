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

package {
	
import com.structuredlogs.targets.LogHistoryTarget;
import com.structuredlogs.targets.TraceTarget;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;

/**
 * 	Example ActionScript application showing the basic usages of logging targets.
 * 
 */
public class BasicTargetUsageAS extends Sprite
{
	public function BasicTargetUsageAS()
	{
		SLog.debug(BasicTargetUsageAS, "First message no targets, should not see me");
		setupTargets();
		setupUI();
	}
	
	private var textfield:TextField;
	private var logHistoryTarget:LogHistoryTarget;
	
	private function setupTargets():void
	{
		var traceTarget:TraceTarget = new TraceTarget();
		traceTarget.includeCategory = true;
		traceTarget.includeDate = true;
		traceTarget.includeLevel = true;
		traceTarget.includeTime = true;

		logHistoryTarget = new LogHistoryTarget();
		logHistoryTarget.includeCategory = true;
		logHistoryTarget.includeDate = true;
		logHistoryTarget.includeLevel = true;
		logHistoryTarget.includeTime = true;
		logHistoryTarget.max = 10;
		
		SLog.addTarget(traceTarget);
		SLog.addTarget(logHistoryTarget);
		SLog.debug(BasicTargetUsageAS, "You should see this message in the console");
	}
	
	private function setupUI():void
	{
		textfield = new TextField();
		textfield.width = 400;
		textfield.height = 600;
		textfield.y = 40;
		textfield.multiline = true;
		textfield.defaultTextFormat = new TextFormat("Verdana", 8);
		addChild(textfield);
		
		var button:MovieClip = new MovieClip();
		button.graphics.beginFill(0x336699, 1);
		button.graphics.drawRoundRect(0, 0, 50, 20, 10, 10);
		button.graphics.endFill();
		button.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		addChild(button);

		var buttonText:TextField = new TextField();
		buttonText.width = 45;
		buttonText.height = 12;
		buttonText.multiline = false;
		buttonText.y = 2;
		buttonText.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		buttonText.defaultTextFormat = new TextFormat("Verdana", 8, 0xCCCCCC, true);
		buttonText.text = "Click Me";
		button.addChild(buttonText);
	}
	
	/**
	 * 	Click handler
	 */
	private function mouseDownHandler(event:MouseEvent):void
	{
		SLog.debug(event.currentTarget, "Target's values: " + event.localX + "," + event.localY); 
		textfield.text = logHistoryTarget.toString();
	}
}
}
