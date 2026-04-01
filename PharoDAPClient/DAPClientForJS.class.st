Class {
	#name : 'DAPClientForJS',
	#superclass : 'DAPClient',
	#category : 'PharoDAPClient-Examples',
	#package : 'PharoDAPClient',
	#tag : 'Examples'
}

{ #category : 'initialization' }
DAPClientForJS >> attachArguments [
	
	^ {
		  ('name' -> 'attach pharo script.js').
		  ('type' -> 'pwa-node').
		  ('request' -> 'attach').
		  ('address' -> 'localhost').
		  ('port' -> '9229').
		  ('continueOnAttach' -> true) } asDictionary
]

{ #category : 'handle request' }
DAPClientForJS >> handleStartDebuggingRequest: aStartDebuggingRequest [

	| childClient |
	self halt.

	childClient := DAPClientForJSStartDebug new attachOtherArguments:
		               (aStartDebuggingRequest
			                at: 'arguments'
			                at: 'configuration').
	childClient startSession.

	(ClientDAPPresenter newWithClient: childClient) open
]

{ #category : 'initialization' }
DAPClientForJS >> initialize [

	super initialize.

	requestHandlers
		at: 'startDebugging'
		put: [ :req | self handleStartDebuggingRequest: req ]
]

{ #category : 'initialization' }
DAPClientForJS >> initializeArguments [

	^ DAPInitializeRequestArguments new
		  clientID: 'my-dap-client';
		  clientName: 'Pharo dap client';
		  adapterID: 'node';
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
		  locale: 'en'
]

{ #category : 'initialization' }
DAPClientForJS >> startSession [

	| host port scriptPath |
	host := 'localhost'.
	port := 5678.
	scriptPath := '/Users/flavienvolant/Documents/sindarin-dap/js/script.js'.

	self connectTo: host port: port.
	self startListening.
	self initialize: self initializeArguments.
	self configurationDone.
	self attach: self attachArguments
]
