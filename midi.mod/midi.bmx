' Copyright (c) 2010-2022 Bruce A Henderson
' 
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
' 
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.
'
SuperStrict

Rem
bbdoc: Midi
End Rem
Module Audio.Midi

ModuleInfo "Version: 1.08"
ModuleInfo "License: MIT"
ModuleInfo "Copyright: RtMidi - 2003-2021 Gary P. Scavone"
ModuleInfo "Copyright: Wrapper - 2010-2022 Bruce A Henderson"

ModuleInfo "History: 1.08"
ModuleInfo "History: Update to RTMidi 5.0.0.806e18f"
ModuleInfo "History: Added setBufferSize() midi input method."
ModuleInfo "History: 1.07"
ModuleInfo "History: Update to RTMidi 4.0.0"
ModuleInfo "History: 1.06"
ModuleInfo "History: Update to RTMidi 3.0.0.81eabf2"
ModuleInfo "History: 1.05"
ModuleInfo "History: Update to RTMidi 3.0.0.9458def"
ModuleInfo "History: 1.04"
ModuleInfo "History: Update to RTMidi 2.1.1"
ModuleInfo "History: NG overload support."
ModuleInfo "History: 1.03"
ModuleInfo "History: Update to RTMidi 2.1.0.28321c051e"
ModuleInfo "History: Added isPortOpen() method."
ModuleInfo "History: Added getVersion() and getCompiledApi() functions."
ModuleInfo "History: 1.02"
ModuleInfo "History: Update to RTMidi 2.0.1"
ModuleInfo "History: Removed setQueueSizeLimit() method."
ModuleInfo "History: 1.01"
ModuleInfo "History: Update to RTMidi 1.0.14"
ModuleInfo "History: Fixed Windows unicode device name issue."
ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release. (RTMidi 1.0.11)"


ModuleInfo "CPP_OPTS: -fexceptions -std=c++11"
?macos
ModuleInfo "CC_OPTS: -D__MACOSX_CORE__"
?linux
ModuleInfo "CC_OPTS: -D__LINUX_ALSASEQ__"
?win32
ModuleInfo "CC_OPTS: -D__WINDOWS_MM__ -DUNICODE"
?

Import "common.bmx"

Type TMidi Abstract

	Field midiPtr:Byte Ptr

	Method openPort(portNumber:Int = 0, portName:String = "BlitzMax Midi") Abstract
	
	Method openVirtualPort(portName:String = "BlitzMax Midi") Abstract
	
	Method getPortCount:Int() Abstract
	
	Method getPortName:String(portNumber:Int = 0) Abstract
	
	Method closePort() Abstract
	
	Method isPortOpen:Int() Abstract

	Rem
	bbdoc: Determines the current RtMidi version.
	End Rem
	Function getVersion:String()
		Return bmx_midi_getVersion()
	End Function
	
	Rem
	bbdoc: Determines the available compiled MIDI APIs.
	End Rem
	Function getCompiledApi:Int[]()
		Return bmx_midi_getCompiledApi()
	End Function

End Type

Rem
bbdoc: A realtime MIDI input type.
about: This type provides a common, platform-independent API for
    realtime MIDI input.  It allows access to a single MIDI input
    port.  Incoming MIDI messages are saved to a queue for
    retrieval using the getMessage() method.
	Create multiple instances of
    this class to connect to more than one MIDI device at the same
    time.  With the OS-X and Linux ALSA MIDI APIs, it is also possible
    to open a virtual input port to which other MIDI software clients
    can connect.
End Rem
Type TMidiIn Extends TMidi

	Rem
	bbdoc: Creates a Midi In object with optional client name and queue size.
	End Rem
	Method Create:TMidiIn(clientName:String = "BlitzMax Midi Input Client", queueSizeLimit:Int = 100, api:Int = API_UNSPECIFIED)
		midiPtr = bmx_midi_in_create(clientName, queueSizeLimit, api)
		Return Self
	End Method

	Rem
	bbdoc: Open a MIDI input connection.
	about: An optional port number greater than 0 can be specified.
      Otherwise, the default or first port found is opened.
	End Rem
	Method openPort(portNumber:Int = 0, portName:String = "BlitzMax Midi Input") Override
		bmx_midi_in_openPort(midiPtr, portNumber, portName)
	End Method
	
	Rem
	bbdoc: Close an open MIDI connection (if one exists).
	End Rem
	Method closePort() Override
		bmx_midi_in_closePort(midiPtr)
	End Method
	
	Rem
	bbdoc: Create a virtual input port, with optional name, to allow software connections (OS X and ALSA only).
	about: This method creates a virtual MIDI input port to which other
      software applications can connect.  This type of functionality
      is currently only supported by the Macintosh OS-X and Linux ALSA
      APIs (the method does nothing for the other APIs).
	End Rem
	Method openVirtualPort(portName:String = "BlitzMax Midi Input") Override
		bmx_midi_in_openVirtualPort(midiPtr, portName)
	End Method
	
	Rem
	bbdoc: Return the number of available MIDI input ports.
	End Rem
	Method getPortCount:Int() Override
		Return bmx_midi_in_getPortCount(midiPtr)
	End Method
	
	Rem
	bbdoc: Return a string identifier for the specified MIDI input port number.
	about: An exception is thrown if an invalid port specifier is provided.
	End Rem
	Method getPortName:String(portNumber:Int = 0) Override
		Return bmx_midi_in_getPortName(midiPtr, portNumber)
	End Method
	
	Rem
	bbdoc: Specify whether certain MIDI message types should be queued or ignored during input.
	about: By default, MIDI timing and active sensing messages are ignored
      during message input because of their relative high data rates.
      MIDI sysex messages are ignored by default as well.  Variable
      values of "true" imply that the respective message type will be
      ignored.
	End Rem
	Method ignoreTypes(midiSysex:Int = True, midiTime:Int = True, midiSense:Int = True)
		bmx_midi_in_ignoreTypes(midiPtr, midiSysex, midiTime, midiSense)
	End Method
	
	Function _newByteArray:Byte[](size:Int)
		Return New Byte[size]
	End Function
	
	Rem
	bbdoc: Returns a Byte array of the data bytes for the next available MIDI message in the input queue and populates the event delta-timestamp in seconds.
	about: This method returns immediately whether a new message is
      available or not.  A valid message is indicated by a non-zero
      array size.  An exception is thrown if an error occurs during
      message retrieval or an input connection was not previously
      established.
	End Rem
	Method getMessage:Byte[](timestamp:Double Var)
		Return bmx_midi_in_getMessage(midiPtr, Varptr timestamp)
	End Method
	
	Rem
	bbdoc: Returns #True if the port is open and False if not.
	End Rem
	Method isPortOpen:Int() Override
		Return bmx_midi_in_isPortOpen(midiPtr)
	End Method

	Rem
	bbdoc: Sets maximum expected incoming message size.
	about: For APIs that require manual buffer management, it can be useful to set the buffer
    size and buffer count when expecting to receive large SysEx messages.  Note that
    currently this function has no effect when called after #openPort().  The default
    buffer size is 1024 with a count of 4 buffers, which should be sufficient for most
    cases; as mentioned, this does not affect all API backends, since most either support
    dynamically scalable buffers or take care of buffer handling themselves.  It is
    principally intended for users of the Windows MM backend who must support receiving
    especially large messages.
	End Rem
	Method setBufferSize(size:UInt, count:UInt)
		bmx_midi_in_setBufferSize(midiPtr, size, count)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method Free()
		If midiPtr Then
			bmx_midi_in_free(midiPtr)
			midiPtr = Null
		End If
	End Method
	
	Method Delete()
		Free()
	End Method
	
End Type

Rem
bbdoc: A realtime MIDI output type.
about: This type provides a common, platform-independent API for MIDI
    output.  It allows one to probe available MIDI output ports, to
    connect to one such port, and to send MIDI bytes immediately over
    the connection.  Create multiple instances of this type to
    connect to more than one MIDI device at the same time.
End Rem
Type TMidiOut Extends TMidi

	Rem
	bbdoc: Creates a Midi Out object with optional client name.
	End Rem
	Method Create:TMidiOut(clientName:String = "BlitzMax Midi Output Client", api:Int = API_UNSPECIFIED)
		midiPtr = bmx_midi_out_create(clientName, api)
		Return Self
	End Method
	
	Rem
	bbdoc: Open a MIDI output connection.
	about: An optional port number greater than 0 can be specified.
      Otherwise, the default or first port found is opened.  An
      exception is thrown if an error occurs while attempting to make
      the port connection.
	End Rem
	Method openPort(portNumber:Int = 0, portName:String = "BlitzMax Midi Output") Override
		bmx_midi_out_openPort(midiPtr, portNumber, portName)
	End Method
	
	Rem
	bbdoc: Close an open MIDI connection (if one exists).
	End Rem
	Method closePort() Override
		bmx_midi_out_closePort(midiPtr)
	End Method
	
	Rem
	bbdoc: Create a virtual output port, with optional name, to allow software connections (OS X and ALSA only).
	about: This method creates a virtual MIDI output port to which other
      software applications can connect.  This type of functionality
      is currently only supported by the Macintosh OS-X and Linux ALSA
      APIs (the function does nothing with the other APIs).  An
      exception is thrown if an error occurs while attempting to create
      the virtual port.

	End Rem
	Method openVirtualPort(portName:String = "BlitzMax Midi Output") Override
		bmx_midi_out_openVirtualPort(midiPtr, portName)
	End Method
	
	Rem
	bbdoc: Return the number of available MIDI output ports.
	End Rem
	Method getPortCount:Int() Override
		Return bmx_midi_out_getPortCount(midiPtr)
	End Method
	
	Rem
	bbdoc: Return a string identifier for the specified MIDI port type and number.
	about: An exception is thrown if an invalid port specifier is provided.
	End Rem
	Method getPortName:String(portNumber:Int = 0) Override
		Return bmx_midi_out_getPortName(midiPtr, portNumber)
	End Method
	
	Rem
	bbdoc: Immediately send a single message out an open MIDI output port.
	about: An exception is thrown if an error occurs during output or an
      output connection was not previously established.
	End Rem
	Method putMessage(message:Byte Ptr, length:Int)
		bmx_midi_out_sendMessage(midiPtr, message, length)
	End Method

	Rem
	bbdoc: Returns #True if the port is open and #False if not.
	End Rem
	Method isPortOpen:Int() Override
		Return bmx_midi_out_isPortOpen(midiPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method Free()
		If midiPtr Then
			bmx_midi_out_free(midiPtr)
			midiPtr = Null
		End If
	End Method
	
	Method Delete()
		Free()
	End Method
	
End Type

Rem
bbdoc: A Midi exception which can be thrown by various API methods.
End Rem
Type TMidiError Extends TRuntimeException
	Field message:String
	Field kind:Int

	Rem
	bbdoc:  A non-critical error.
	End Rem
	Const WARNING:Int = 0
	
	Rem
	bbdoc: A non-critical error which might be useful for debugging.
	End Rem
	Const DEBUG_WARNING:Int = 1
	
	Rem
	bbdoc: The default, unspecified error type.
	End Rem
	Const UNSPECIFIED:Int = 2
	
	Rem
	bbdoc: No devices found on system.
	End Rem
	Const NO_DEVICES_FOUND:Int = 3
	
	Rem
	bbdoc: An invalid device ID was specified.
	End Rem
	Const INVALID_DEVICE:Int = 4
	
	Rem
	bbdoc: An invalid stream ID was specified.
	End Rem
	Const INVALID_STREAM:Int = 5
	
	Rem
	bbdoc: An error occured during memory allocation.
	End Rem
	Const MEMORY_ERROR:Int = 6
	
	Rem
	bbdoc: An invalid parameter was specified to a function.
	End Rem
	Const INVALID_PARAMETER:Int = 7
	
	Rem
	bbdoc: A system driver error occured.
	End Rem
	Const DRIVER_ERROR:Int = 8
	
	Rem
	bbdoc: A system error occured.
	End Rem
	Const SYSTEM_ERROR:Int = 9
	
	Rem
	bbdoc:  A thread error occured.
	End Rem
	Const THREAD_ERROR:Int = 10

	Method New(message:String, kind:Int)
		Self.message = message
		Self.kind = kind
	End Method
	
	Function _create:TMidiError(message:String, kind:Int) { nomangle }
		Return New TMidiError(message, kind)
	End Function
	
	Method ToString:String()
		Return message
	End Method

End Type

