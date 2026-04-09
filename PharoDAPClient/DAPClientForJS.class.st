Class {
	#name : 'DAPClientForJS',
	#superclass : 'SindarinDAPClient',
	#instVars : [
		'child'
	],
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

{ #category : 'accessing' }
DAPClientForJS >> child [

	^ child
]

{ #category : 'handle request' }
DAPClientForJS >> handleStartDebuggingRequest: aStartDebuggingRequest [

	child := DAPClientForJSStartDebug new attachOtherArguments:
		               (aStartDebuggingRequest
			                at: 'arguments'
			                at: 'configuration').
	child startSession.

	(ClientDAPPresenter newWithClient: child) open
]

{ #category : 'initialization' }
DAPClientForJS >> initialize [

	super initialize.

	requestHandlers
		at: 'startDebugging'
		put: [ :req | self handleStartDebuggingRequest: req ]
]

{ #category : 'initialization' }
DAPClientForJS >> startSession [
	
	DAPClientBuilder new
		client: self;
		adapterID: 'node';
		port: 5678;
		attachArguments: self attachArguments;
		breakpoint: '/Users/flavienvolant/Documents/sindarin-dap/js/script_parser.js' line: 1;
		startClientSession 
]
