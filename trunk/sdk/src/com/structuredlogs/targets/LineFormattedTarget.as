////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
/*
MODIFICATIONS Under Any Previous Licenses
Modified (c) 2009 Renaun Erickson (http://renaun.com, http://structuredlogs.com)
*/

package com.structuredlogs.targets
{

import com.structuredlogs.events.SLogEvent;

import mx.logging.ILogger;

/**
 *  All logger target implementations that have a formatted line style output
 *  should extend this class.
 *  It provides default behavior for including date, time, category, and level
 *  within the output.
 * 
 * 	Needs to be used with the <code>SLog</code> and <code>SLogLogger</code> classes.
 *
 */
public class LineFormattedTarget extends BaseTarget
{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  <p>Constructs an instance of a logger target that will format
     *  the message data on a single line.</p>
     */
    public function LineFormattedTarget()
    {
        super();

        includeTime = false;
        includeDate = false;
        includeCategory = false;
        includeLevel = false;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  fieldSeparator
    //----------------------------------

    [Inspectable(category="General", defaultValue=" ")]
    
    /**
     *  The separator string to use between fields (the default is " ")
     */
    public var fieldSeparator:String = " ";

    //----------------------------------
    //  includeCategory
    //----------------------------------

    [Inspectable(category="General", defaultValue="false")]
    
    /**
     *  Indicates if the category for this target should added to the trace.
     */
    public var includeCategory:Boolean;

    //----------------------------------
    //  includeDate
    //----------------------------------

    [Inspectable(category="General", defaultValue="false")]
    
    /**
     *  Indicates if the date should be added to the trace.
     */
    public var includeDate:Boolean;

    //----------------------------------
    //  includeLevel
    //----------------------------------

    [Inspectable(category="General", defaultValue="false")]
    
    /**
     *  Indicates if the level for the event should added to the trace.
     */
    public var includeLevel:Boolean;

    //----------------------------------
    //  includeTime
    //----------------------------------

    [Inspectable(category="General", defaultValue="false")]
    
    /**
     *  Indicates if the time should be added to the trace.
     */
    public var includeTime:Boolean;

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  This method handles a <code>SLogEvent</code> from an associated logger.
     *  A target uses this method to translate the event into the appropriate
     *  format for transmission, storage, or display.
     *  This method is called only if the event's level is in range of the
     *  target's level.
     * 
     *  @param event The <code>SLogEvent</code> handled by this method.
     */
    override public function logEvent(event:SLogEvent):void
    {
        var date:String = ""
        if (includeDate || includeTime)
        {
            var d:Date = new Date();
            if (includeDate)
            {
                date = Number(d.getMonth() + 1).toString() + "/" +
                       d.getDate().toString() + "/" + 
                       d.getFullYear() + fieldSeparator;
            }   
            if (includeTime)
            {
                date += padTime(d.getHours()) + ":" +
                        padTime(d.getMinutes()) + ":" +
                        padTime(d.getSeconds()) + "." +
                        padTime(d.getMilliseconds(), true) + fieldSeparator;
            }
        }
        
        var level:String = "";
        if (includeLevel)
        {
            level = "[" + SLogEvent.getLevelString(event.level) +
                    "]" + fieldSeparator;
        }

        var category:String = includeCategory ?
                              ILogger(event.target).category + fieldSeparator :
                              "";

        internalLog(internalDisplay(date, level, category, event.message));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function padTime(num:Number, millis:Boolean = false):String
    {
        if (millis)
        {
            if (num < 10)
                return "00" + num.toString();
            else if (num < 100)
                return "0" + num.toString();
            else 
                return num.toString();
        }
        else
        {
            return num > 9 ? num.toString() : "0" + num.toString();
        }
    }

    /**
     *  Descendants of this class should override this method to format the 
     *  message to the desired output.
     *
     *  @param  message String containing preprocessed log message which may
     *              include time, date, category, etc. based on property settings,
     *              such as <code>includeDate</code>, <code>includeCategory</code>,
     *          etc.
     */
    public function internalDisplay(date:String, level:String, category:String, message:String):String
    {
        return date + level + category + message;
    }

    /**
     *  Descendants of this class should override this method to direct the 
     *  specified message to the desired output.
     *
     *  @param  message String containing preprocessed log message which may
     *              include time, date, category, etc. based on property settings,
     *              such as <code>includeDate</code>, <code>includeCategory</code>,
     *          etc.
     */
    public function internalLog(message:String):void
    {
        // override this method to perform the redirection to the desired output
    }
}

}
