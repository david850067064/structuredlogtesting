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
package com.structuredlogs.targets
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.formatters.DateFormatter;
	

/**
 *  Provides the ability to save out a history of log statements to a file.
 * 
 *  <p>The file output directory is defined by the <code>outputDirectory</code property.
 *  The actually log output file name is created by prefix + timestamp + "." + extension.
 *  You can also just override <code>getFilename()</code> method to full customized names.</p>
 */
public class FileTarget extends LogHistoryTarget
{

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function FileTarget() 
	{
		super();
    }
    
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

    /**
     *  The directory where to store log files.  If left blank the 
     *  default is to use <code>File.documentsDirectory.resolvePath("logs")</code>.
     *  
     *  @default null
     */
    public var outputDirectory:File;
    
    /**
     *	The log file prefix.
     *  @default "log_" 
     */
	public var prefix:String = "log_";
	
	/**
	 * 	The log save file extension.
	 * 
	 * 	@default "txt"
	 */
	public var extension:String = "txt";
	
	/**
	 * 	The log save file name part that defines a timestamp.
	 * 
	 * 	@default ""
	 */
	public var timestampFormater:DateFormatter;
    
    /**
     * 	Timestamp value is set when the value is "", which typically is once
     * 	per instance of the target.
     */
    protected var timestamp:String;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *	Save the logs to file and then clear the log buffer.
	 */
	public function saveToFile():void
	{
		try
		{
			if (timestamp == "" || !timestamp)
			{
				if (!timestampFormater)
				{
					timestampFormater = new DateFormatter();
					timestampFormater.formatString = "YYYYMMDD_HHNNSS";
					timestamp = timestampFormater.format(new Date());
				}
			}
			if (!outputDirectory)
				outputDirectory = File.documentsDirectory.resolvePath("logs");			
			var logFile:File = outputDirectory.resolvePath(getFilename());
			var stream:FileStream = new FileStream();
			stream.open(logFile, FileMode.APPEND);
			for each(var msg:String in logHistory)
				stream.writeUTFBytes(msg+separator);
			stream.close();
			clearHistory();
		}
		catch(error:Error)
		{
			throw error;
		}
	}
	
	/**
	 * 	Returns the log file name to use when saving log data.
	 */
	public function getFilename():String
	{
		return prefix + timestamp + "." + extension;
	}
	
	/**
	 *  Force the target to use a new filename to store log data. 	
	 */
	public function startNewFile():void
	{
		timestamp = "";
	}
  
}
}