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

package classes
{
	
/**
 * 	This class takes a total cost and applies any discounts.
 */
public class Discounter
{
	/**
	 * 	Constructor
	 * 
	 * 	@param originalPrice The original price to be discounted
	 */
	public function Discounter(originalPrice:Number)
	{
		/* STEP 1: Create class and originalPrice TestPoint */
		SLog.test(Discounter, "originalPrice", {price: originalPrice});
		this.originalPrice = originalPrice;
	}
	
	protected var originalPrice:Number;
	/* STEP 3: Create discount codes */
	protected var codes:Array = new Array();
	
	public function applyPromo(code:String):void
	{
		SLog.test(Discounter, "discountCode", {code: code});
		codes.push(code);
	}
	
	
	/* STEP 4: Setup subTotal price data points 
	*/
	public function calculatePrice():Number
	{
		var price:Number = originalPrice;
		for each (var code:String in codes)
		{
			if (code == "DIS10")
			{
				price -= 10;
			}
			else if (code == "360FLEX")
			{
				price = originalPrice * 0.80;
			}
			SLog.test(Discounter, "subTotal", {currentPrice: price, code: code});
		}
		return price;
	}

}
}