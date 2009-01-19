/*
Copyright (c) 2008 Renaun Erickson (http://renaun.com)

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

package olympics
{
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.getTimer;

import mx.containers.Canvas;

public class Pool extends Canvas
{
	public function Pool(laneSize:int)
	{
		super();
		
		/* STEP 3: Set lane size property 
		this.laneSize = laneSize;
		lanes = new Array();
		width = 600;
		height = laneSize * laneHeight;
		setStyle("backgroundColor", 0xFFFFFF);
		setStyle("backgroundAlpha", 0.7);
		horizontalScrollPolicy = "off";
		*/
		
		/* STEP 2: Create Pool and create laneSize
		SLog.test(Pool, "createPool", 
					{laneSize: this.laneSize});
		*/
	}
	
	/* STEP 2: Create Pool and create laneSize 
	protected var laneSize:int;
	protected var lanes:Array;
	*/
	
	/* STEP 3: Setup properties 
	public var laneHeight:int = 100;
	*/
	
	public function addSwimmer(swimmer:Swimmer):void
	{
		var lane:int = -1;
		/* STEP 5: Add swimmer	
		if (lanes.length < laneSize)
		{	
			lane = lanes.length;
			lanes.push(swimmer);
			swimmer.y = (curIndex * laneHeight) + (laneHeight-swimmer.height)/2;
			if (!contains(swimmer))
				addChild(swimmer);				
		}
		*/
		// STEP 4: Add addSwimmer and TestPoint
		SLog.test(Pool, "addSwimmer", 
			{swimmer: swimmer.swimmerName, lane: lane});	
	}	
	
	
	/* STEP 6: Racing code
	
	protected var winners:Array;
	private var startTime:Number;
	private var raceTimer:Timer;
	public function startRace():void
	{
		winners = new Array();
		startTime = getTimer();
		if (!raceTimer)
		{
			raceTimer = new Timer(500,0);
			raceTimer.addEventListener(TimerEvent.TIMER, actionTimerHandler);
		}
		raceTimer.start();
	}
	
	public function actionTimerHandler(event:Event):void
	{
		for each (var swimmer:Swimmer in lanes)
		{
			// Still Swimming
			if (swimmer.x + swimmer.width < width)
			{
				var delta:int = Math.min(((Math.random() * 0xffffff) % 34) + 23, 
												width - swimmer.x - swimmer.width);
				swimmer.x += delta;
			}
			else if (!swimmer.isFinished)
			{
				swimmer.isFinished = true;
				winners.push(swimmer);
				swimmer.x = 0;
				var time:Number = (int((getTimer() - startTime) * 100))/100;
				
				SLog.test(Pool, "winner", 
					{swimmer: swimmer.swimmerName, place: winners.length});
				swimmer.text += " #" + winners.length + " in " + time + "s";
			}
		}
		if (winners.length >= lanes.length)
			raceTimer.stop();
	}
	*/
}
}