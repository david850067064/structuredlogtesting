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
import com.structuredlogs.events.SLogEventLevel;

import mx.core.IMXMLObject;
import mx.logging.ILogger;
import mx.logging.ILoggingTarget;

/**
 *  This class provides the basic functionality required by the logging framework 
 *  for a target implementation.
 *  It handles the validation of filter expressions and provides a default level 
 *  property.
 *  No implementation of the <code>logEvent()</code> method is provided.
 * 
 * 	This class comes from mx.logging.AbstractTarget but has been modified to work 
 * 	with the Flex Framework or just ActionScript 3.0 projects.
 */
public class BaseTarget implements ILoggingTarget, IMXMLObject
{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function BaseTarget()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Count of the number of loggers this target is listening to. When this
     *  value is zero changes to the filters property shouldn't do anything
     */
    private var _loggerCount:uint = 0;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  filters
    //----------------------------------

    /**
     *  @private
     *  Storage for the filters property.
     */
    private var _filters:Array = [ "*" ];

    [Inspectable(category="General", arrayType="String")]
    /**
     *  In addition to the <code>level</code> setting, filters are used to
     *  provide a psuedo-hierarchical mapping for processing only those events
     *  for a given category.
     *  <p>
     *  Each logger belongs to a category.
     *  By convention these categories map to the fully-qualified class name in
     *  which the logger is used.
     *  For example, a logger that is logging messages for the
     *  <code>mx.rpc.soap.WebService</code> class, uses 
     *  "mx.rpc.soap.WebService" as the parameter to the 
     *  <code>Log.getLogger()</code> method call.
     *  When messages are sent under this category only those targets that have
     *  a filter which matches that category receive notification of those
     *  events.
     *  Filter expressions can include a wildcard match, indicated with an
     *  asterisk.
     *  The wildcard must be the right-most character in the expression.
     *  For example: rpc~~, mx.~~, or ~~.
     *  If an invalid expression is specified, a <code>InvalidFilterError</code>
     *  is thrown.
     *  If <code>null</code> or [] is specified, the filters are set to the
     *  default of ["~~"].
     *  </p>
     *  <p>For example:
     *     <pre>
     *           var traceLogger:ILoggingTarget = new TraceTarget();
     *           traceLogger.filters = ["mx.rpc.~~", "mx.messaging.~~"];
     *           Log.addTarget(traceLogger);
     *     </pre>
     *  </p>
     */
    public function get filters():Array
    {
        return _filters;
    }

    /**
     *  @private
     *  This method will make sure that all of the filter expressions specified
     *  are valid, and will throw <code>InvalidFilterError</code> if any are not.
     */
    public function set filters(value:Array):void
    {
        if (value && value.length > 0)
        {
            // a valid filter value will be fully qualified or have a wildcard
            // in it.  the wild card can only be located at the end of the
            // expression.  valid examples  xx*, xx.*,  *
            var filter:String;
            var index:int;
            var message:String;
            for (var i:uint = 0; i<value.length; i++)
            {
                filter = value[i];
                  // check for invalid characters
                if (SLog.hasIllegalCharacters(filter))
                {
                    throw new Error("Filter has illegal characters.");
                }

                index = filter.indexOf("*");
                if ((index >= 0) && (index != (filter.length -1)))
                {
                    throw new Error("Wild card has to be at the end.");
                }
            } // for
        }
        else
        {
            // if null was specified then default to all
            value = ["*"];
        }

        if (_loggerCount > 0)
        {
            SLog.removeTarget(this);
            _filters = value;
            SLog.addTarget(this);
        }
        else
        {
            _filters = value;
        }
    }

    //----------------------------------
    //  id
    //----------------------------------

    /**
     *  @prviate
     *  Storage for the id property.
     */
    private var _id:String;

    [Inspectable(category="General")]
    
     /**
      *  Provides access to the id of this target.
      *  The id is assigned at runtime by the mxml compiler if used as an mxml 
      *  tag, or internally if used within a script block
      */
     public function get id():String
     {
         return _id;
     }
    
    //----------------------------------
    //  level
    //----------------------------------

    /**
     *  @private
     *  Storage for the level property.
     */
    private var _level:int = SLogEventLevel.ALL;

    /**
     *  Provides access to the level this target is currently set at.
     *  Value values are:
     *    <ul>
     *    	<li><code>SSLogEventLevel.STRUCTURED</code> designates events that are 
     *    	structured to work with Structured Log Testing tools.</li>
     * 
     *      <li><code>SSLogEventLevel.FATAL (1000)</code> designates events that are very
     *      harmful and will eventually lead to application failure</li>
     *
     *      <li><code>SSLogEventLevel.ERROR (8)</code> designates error events that might
     *      still allow the application to continue running.</li>
     *
     *      <li><code>SSLogEventLevel.WARN (6)</code> designates events that could be
     *      harmful to the application operation</li>
     *
     *      <li><code>SSLogEventLevel.INFO (4)</code> designates informational messages
     *      that highlight the progress of the application at
     *      coarse-grained level.</li>
     *
     *      <li><code>SSLogEventLevel.DEBUG (2)</code> designates informational
     *      level messages that are fine grained and most helpful when
     *      debugging an application.</li>
     *
     *      <li><code>SSLogEventLevel.ALL (0)</code> intended to force a target to
     *      process all messages.</li>
     *    </ul>
     */
    public function get level():int
    {
        return _level;
    }

    /**
     *  @private
     */
    public function set level(value:int):void
    {
        // A change of level may impact the target level for Log.
        SLog.removeTarget(this);
        _level = value;
        SLog.addTarget(this);        
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Sets up this target with the specified logger.
     *  This allows this target to receive log events from the specified logger.
     *
     *  @param logger The ILogger that this target should listen to.
     */
    public function addLogger(logger:ILogger):void
    {
        if (logger
        	&& !logger.hasEventListener(SLogEvent.LOG))
        {
            _loggerCount++;
            logger.addEventListener(SLogEvent.LOG, logHandler);
        }
    }

    /**
     *  Stops this target from receiving events from the specified logger.
     *
     *  @param logger The ILogger that this target should ignore.
     */
    public function removeLogger(logger:ILogger):void
    {
        if (logger)
        {
            _loggerCount--;
            logger.removeEventListener(SLogEvent.LOG, logHandler);
        }
    }

    /**
     *  Called after the implementing object has been created
     *  and all properties specified on the tag have been assigned.
     *
     *  @param document MXML document that created this object.
     *
     *  @param id Used by the document to refer to this object.
     *  If the object is a deep property on the document, id is null.
     */
    public function initialized(document:Object, id:String):void
    {
        _id = id;
        SLog.addTarget(this);
    }

    /**
     *  This method handles a <code>SLogEvent</code> from an associated logger.
     *  A target uses this method to translate the event into the appropriate
     *  format for transmission, storage, or display.
     *  This method will be called only if the event's level is in range of the
     *  target's level.
     *
     *  <p><b><i>NOTE: Descendants must override this method to make it useful.</i></b></p>
     *  
     *  @param event An event from an associated logger.
     */
    public function logEvent(event:SLogEvent):void
    {
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  This method will call the <code>logEvent</code> method if the level of the
     *  event is appropriate for the current level.
     */
    private function logHandler(event:SLogEvent):void
    {
        if (event.level >= level)
            logEvent(event);
    }
}

}
