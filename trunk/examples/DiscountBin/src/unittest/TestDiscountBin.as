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

package unittest
{
import classes.Discounter;

import com.structuredlogs.runners.SLogTestRunner;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

import org.flexunit.Assert;
import org.flexunit.async.Async;
	

[RunWith("com.structuredlogs.runners.SLogTestRunner")]
public class TestDiscountBin
{	
	private var runner:SLogTestRunner;
	
	[SLF]
	public static var promo1:String = "unittest/scripts/test2.slf";
	
	//[SLF]
	//public static var price2:String = "unittest/scripts/price2.slf";
	
	[TestDriver]
	public function goneShopping():void
	{	    
		
		SLog.testActivateScript("test2", true);
		var discount:Discounter = new Discounter(80.00);
		discount.applyPromo("DIS10");
		discount.calculatePrice();
		SLog.testActivateScript("test2", false);
	}
	
}

}