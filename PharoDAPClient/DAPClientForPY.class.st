Class {
	#name : 'DAPClientForPY',
	#superclass : 'DAPClient',
	#category : 'PharoDAPClient-Examples',
	#package : 'PharoDAPClient',
	#tag : 'Examples'
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

	super initialize.

	DAPClientBuilder new
		client: self;
		port: 5678;
		adapterID: 'python';
		attachArguments: self attachArguments;
		breakpoint:
			'/Users/flavienvolant/Documents/sindarin-dap/py/script.py'
		line: 1;
		functionBreakpoint: 'bar' condition: 'isinstance(self, Foo)';
		functionBreakpoint: 'toto';
		startClientSession
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
