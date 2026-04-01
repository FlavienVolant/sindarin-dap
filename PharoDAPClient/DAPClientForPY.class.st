Class {
	#name : 'DAPClientForPY',
	#superclass : 'DAPClient',
	#category : 'PharoDAPClient-examples',
	#package : 'PharoDAPClient',
	#tag : 'examples'
}

{ #category : 'initialization' }
DAPClientForPY >> attachArguments [

	^ {
		  ('name' -> 'Attach to Python').
		  ('type' -> 'python').
		  ('connect' -> {
			   ('host' -> 'localhost').
			   ('port' -> 5678) } asDictionary).
		  ('redirectOutput' -> true).
		  ('showReturnValue' -> true) } asDictionary
]

{ #category : 'initialization' }
DAPClientForPY >> initialize [

	| host port scriptPath args|
	super initialize.

	host := 'localhost'.
	port := 5678.
	scriptPath := '/Users/flavienvolant/Documents/sindarin-dap/py/script.py'.

	self connectTo: host port: port.
	self startListening.
	self initialize: self initializeArguments.
	
	args := DAPSetBreakpointsArguments new
		        source: (DAPSource new path: scriptPath);
		        breakpoints: (Array with: (DAPSourceBreakpoint new line: 1)).

	self setBreakpoints: args.

	args := DAPSetFunctionBreakpointsArguments new breakpoints: {
			        (DAPFunctionBreakpoint new
				         name: 'bar';
				         condition: 'isinstance(self, Foo)').
			        (DAPFunctionBreakpoint new name: 'toto') }.

	self setFunctionBreakpoints: args.
	
	self configurationDone.
	self attach: self attachArguments
]

{ #category : 'initialization' }
DAPClientForPY >> initializeArguments [

	^ DAPInitializeRequestArguments new
		        clientID: 'my-dap-client';
		        clientName: 'Pharo dap client';
		        adapterID: 'python';
		        pathFormat: 'path';
		        linesStartAt1: true;
		        columnsStartAt1: true;
		        supportsProgressReporting: true;
		        supportsMemoryReferences: true;
		        supportsInvalidatedEvent: true;
		        supportsRunInTerminalRequest: true;
		        supportsVariableType: true;
		        supportsArgsCanBeInterpretedByShell: true;
		        supportsMemoryEvent: true;
		        supportsStartDebuggingRequest: true;
		        locale: 'en'.
]
