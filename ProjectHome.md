## Overview ##

The Structured Log Testing approach to testing makes use of structured log statements and visually advanced/dynamic tools.  The structured log statements contain test points that a tool takes and puts together in to a Structured Log File (.slf) that can be used as a test script or simply be a log file.  The Structured Log Testing approach allows for an easy to learn and flexible method of implementing test driven development (TDD).

More information about Structured Log Testing can be found at:
http://structuredlogs.com/about/

The purpose of these API's are to provide code to capture, read, and write the Structured Log Testing statements and put them into to a SLF file.

## Project Code Breakdown ##

/trunk/sdk - The StructuredLogTestingSDK

/trunk/toolingsdk - The StructuredLogTestingToolingSDK

/trunk/examples/BasicSLogViewerAIR - An example AIR application that shows how to receive messages from the StructuredLogTarget.

/trunk/examples/BasicTargetUsageAS - Shows the basic usage of SLog class with the targets like TraceTarget and LogHistoryTarget.

/trunk/examples/StructuredLogTestingExample1 - Example using SLog.test() and StructuredLogTarget to view TestPoint messages in BasicSLogViewerAIR application.


