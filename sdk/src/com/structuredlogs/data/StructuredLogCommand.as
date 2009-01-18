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

package com.structuredlogs.data
{
/**
 * 	The class holds constant values determined by Structured Log Testing to
 *  be common command strings for tools to standarized around.
 * 
 * 	This command values should be set as the TestPoint name (tpname) of a SLog statment.
 */
public class StructuredLogCommand
{
	//--------------------------------------------------------------------------
	//
	//  Constants
	//
	//--------------------------------------------------------------------------	
	
	/**
	 * 	Reset any scripts.  Possible data payloads:
	 * 	{ scriptNames: "scriptName1,scriptName2" }
	 * 
	 *  The scriptNames property hold a comma delimited list of script names to reset.
	 */
	public static const SLOG_RESET_SCRIPTS:String = "slog_Reset_Scripts";
	
	/**
	 * 	Load a script as a url or local file.
	 * 	{ fileType: "url" | null,
	 * 	  fileName: "path/to/file" }
	 * 
	 */
	public static const SLOG_LOAD_SCRIPT:String = "slog_Load_Script";

}
}