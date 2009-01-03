/*
Copyright (c) 2005 JSON.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The Software shall be used for Good, not Evil.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/*
Ported to Actionscript 2 May 2005 by Trannie Carter <tranniec@designvox.com>, wwww.designvox.com
Ported to Actionscript 3 2009 Renaun Erickson (http://renaun.com, http://structuredlogs.com)

USAGE:
	var json:JSON = new JSON();
    try {
        var o:Object = json.parse(jsonStr);
        var s:String = json.stringify(obj);
    } catch(error:Error) {
        trace(ex.name + ":" + ex.message + ":" + ex.at + ":" + ex.text);
    }
*/
package com.structuredlogs.utils
{


public class JSON 
{
	private var currentCharacter:String = "";
	private var currentIndex:Number = 0;
	private var decodeText:String;
	    
	/**
	 * 	The decode method
	 */
	public function decode(parseText:String):Object 
	{
		decodeText = parseText;
		currentIndex = 0;
		currentCharacter = " ";
		return value();
	}

	/**
	 * 	Encode into JSON object formated string. 
	 */
    public function encode(object:*):String 
    {
        var i:int = 0;
        var str:String = "";
        var tmp:String;

        switch (typeof object) 
        {
        	case "object":
	            if (object) {
	                if (object is Array) {
	                    for (i = 0; i < object.length; ++i) {
	                        tmp = encode(object[i]);
	                        if (str)
	                            str += ',';
	                        str += tmp;
	                    }
	                    return '[' + str + ']';
	                } else if (typeof object.toString != 'undefined') {
	                    for (var key:String in object) {
	                        var value:* = object[key];
	                        if (typeof value != 'undefined' && typeof value != 'function') {
	                            tmp = encode(value);
	                            if (str) {
	                                str += ',';
	                            }
	                            str += encode(key) + ':' + tmp;
	                        }
	                    }
	                    return '{' + str + '}';
	                }
	            }
            	return 'null';
            break;
        	case 'number':
				return isFinite(object) ? String(object) : 'null';
			break;
	        case 'string':
	            var len:int = object.length;
	            str = '"';
	            var char:String;
	            for (i = 0; i < len; i++) {
	                char = object.charAt(i);
	                if (char >= ' ') {
	                    if (char == '\\' || char == '"') {
	                        str += '\\';
	                    }
	                    str += char;
	                } else {
	                    switch (char) {
	                        case '\b':
	                            str += '\\b';
	                            break;
	                        case '\f':
	                            str += '\\f';
	                            break;
	                        case '\n':
	                            str += '\\n';
	                            break;
	                        case '\r':
	                            str += '\\r';
	                            break;
	                        case '\t':
	                            str += '\\t';
	                            break;
	                        default:
	                            var charCode:Number = char.charCodeAt();
	                            str += '\\u00' + Math.floor(charCode / 16).toString(16) +
	                                (charCode % 16).toString(16);
	                    }
	                }
	            }
	            return str + '"';
			break;
	        case 'boolean':
	            return String(object);
			break;
	        default:
	            return "null";
			break;
        }
        return "null";
    }
    
    /**
     *	Loop through whitespace 
     */
	private function white():void 
	{
        while (currentCharacter) 
        {
            if (currentCharacter <= " ") 
            {
                next();
            } 
            else if (currentCharacter == '/') 
            {
                switch (next()) 
                {
                    case "/":
                        while (next() && currentCharacter != '\n' && currentCharacter != '\r') {}
                        break;
                    case "*":
                        next();
                        for (;;) 
                        {
                            if (currentCharacter) 
                            {
                                if (currentCharacter == '*') 
                                {
                                    if (next() == '/') 
                                    {
                                        next();
                                        break;
                                    }
                                } 
                                else 
                                {
                                    next();
                                }
                            } 
                            else 
                            {
                                error("Unterminated comment");
                            }
                        }
                        break;
					default:
                        error("Syntax error");
					break;
                }
            } 
            else 
            {
                break;
            }
        }
    }

	/**
	 * 	@private
	 * 	Function to throw error message.
	 */
    private function error(msg:String):void 
    {
        throw new Error(msg + " \nindex: " + (currentIndex - 1) + " \ndecodeText: " + decodeText);
    }
    
    /**
	 * 	@private 
	 * 	Returns the look at next character object value.
	 */
    private function next():String 
    {
        currentCharacter = decodeText.charAt(currentIndex);
        currentIndex += 1;
        return currentCharacter;
    }
    
    /**
	 * 	@private 
	 * 	Returns the decoded string value.
	 */
    private function getString():String 
    {
        var str:String = "";
        var outer:Boolean = false;

        if (currentCharacter == '"') 
        {
            while (next()) 
            {
                if (currentCharacter == '"') 
                {
					next();
					return str;
                } 
                else if (currentCharacter == '\\') 
                {
                    switch (next()) 
                    {
                        case 'b':
                            str += '\b';
						break;
                        case 'f':
                            str += '\f';
						break;
                        case 'n':
                            str += '\n';
						break;
                        case 'r':
                            str += '\r';
						break;
                        case 't':
                            str += '\t';
						break;
                        case 'u':
                            var u:int = 0;
                            var t:int = 0;
                            for (var i:int = 0; i < 4; i++) {
                                t = parseInt(next(), 16);
                                if (!isFinite(t)) {
                                    outer = true;
                                    break;
                                }
                                u = u * 16 + t;
                            }
                            if(outer) {
                                outer = false;
                                break;
                            }
                            str += String.fromCharCode(u);
						break;
                        default:
                            str += currentCharacter;
						break;
						
                    }
                } else {
                    str += currentCharacter;
                }
            }
        }
        error("Bad string");
        return str;
    }

    
    
    /**
	 * 	@private 
	 * 	Returns the decoded array value.
	 */
    private function getArray():Array 
    {
        var array:Array = [];
        if (currentCharacter == '[') {
            next();
            white();
            if (currentCharacter == ']') {
                next();
                return array;
            }
            while (currentCharacter) {
                array.push(value());
                white();
                if (currentCharacter == ']') {
                    next();
                    return array;
                } else if (currentCharacter != ',') {
                    break;
                }
                next();
                white();
            }
        }
        error("Bad array");
        return array;
    }

    
    
    /**
	 * 	@private 
	 * 	Returns the decoded object value.
	 */
    private function getObject():Object 
    {
        var obj:Object = {};

        if (currentCharacter == '{') {
            next();
            white();
            if (currentCharacter == '}') {
                next();
                return obj;
            }
            while (currentCharacter) {
                var k:String = getString();
                white();
                if (currentCharacter != ':') {
                    break;
                }
                next();
                obj[k] = value();
                white();
                if (currentCharacter == '}') {
                    next();
                    return obj;
                } else if (currentCharacter != ',') {
                    break;
                }
                next();
                white();
            }
        }
        error("Bad object");
        return obj;
    }

    
    
    /**
	 * 	@private 
	 * 	Returns the decoded number value.
	 */
    private function getNumber():Number {
        var n:String = ''
        var ret:Number;

        if (currentCharacter == '-') {
            n = '-';
            next();
        }
        while (currentCharacter >= '0' && currentCharacter <= '9') {
            n += currentCharacter;
            next();
        }
        if (currentCharacter == '.') {
            n += '.';
            next();
            while (currentCharacter >= '0' && currentCharacter <= '9') {
                n += currentCharacter;
                next();
            }
        }
        if (currentCharacter == 'e' || currentCharacter == 'E') {
            n += currentCharacter;
            next();
            if (currentCharacter == '-' || currentCharacter == '+') {
                n += currentCharacter;
                next();
            }
            while (currentCharacter >= '0' && currentCharacter <= '9') {
                n += currentCharacter;
                next();
            }
        }
        ret = Number(n);
        if (!isFinite(ret)) 
        {
            error("Bad number");
        }
        return ret;
    }
	    
	/**
	 * 	@private
	 * 	Finds the value for the decoding
	 */
	private function value():Object 
	{
	    white();
	    switch (currentCharacter) 
	    {
	        case '{':
	            return getObject();
			break;
	        case '[':
	            return getArray();
			break;
	        case '"':
	            return getString();
			break;
	        case '-':
	        case '0':
	        case '1':
	        case '2':
	        case '3':
	        case '4':
	        case '5':
	        case '6':
	        case '7':
	        case '8':
	        case '9':
	            return getNumber();
			break;
	        case 't':
                if (next() == 'r' && next() == 'u' &&
                        next() == 'e') {
                    next();
                    return true;
                }	        
			break;
	        case 'f':
                if (next() == 'a' && next() == 'l' &&
                        next() == 's' && next() == 'e') {
                    next();
                    return false;
                }	        
			break;
	        default:
	            return null;
	    }
	    return null;
	}
}
}