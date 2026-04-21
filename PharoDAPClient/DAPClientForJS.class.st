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
		  ('port' -> '5005').
		  ('continueOnAttach' -> true) } asDictionary
]

{ #category : 'accessing' }
DAPClientForJS >> child [

	^ child
]

{ #category : 'registry' }
DAPClientForJS >> dapRegistryAt: keyAsString put: valueAsString [

	self
		stackTrace: (DAPStackTraceArguments new threadId: self mainThreadId)
		onResponse: [ :resp |
				self setExpression: (DAPSetExpressionArguments new
						 expression:
							 'globalThis.__dap_registry__["' , keyAsString , '"]';
						 value: valueAsString;
						 frameId: (((resp at: 'body') at: 'stackFrames') first at: 'id')) ]
]

{ #category : 'handle request' }
DAPClientForJS >> handleStartDebuggingRequest: aStartDebuggingRequest [

	child := DAPClientForJSStartDebug new attachOtherArguments:
		         (aStartDebuggingRequest at: 'arguments' at: 'configuration').
	child startSession.

	(ClientDAPPresenter newWithClient: child) open.

	self closeConnection
]

{ #category : 'initialization' }
DAPClientForJS >> initialize [

	super initialize.

	requestHandlers
		at: 'startDebugging'
		put: [ :req | self handleStartDebuggingRequest: req ]
]

{ #category : 'registry' }
DAPClientForJS >> initializeDapRegistry [

	self
		stackTrace: (DAPStackTraceArguments new threadId: self mainThreadId)
		onResponse: [ :resp |
				self setExpression: (DAPSetExpressionArguments new
						 expression: 'globalThis.__dap_registry__';
						 value: '{}';
						 frameId: (((resp at: 'body') at: 'stackFrames') first at: 'id')) ]
]

{ #category : 'initialization' }
DAPClientForJS >> startSession [
	
	DAPClientBuilder new
		client: self;
		adapterID: 'node';
		port: 5678;
		attachArguments: self attachArguments;
		breakpoint: '/Users/flavienvolant/Documents/sindarin-dap/js/script.js' line: 1;
		startClientSession 
]
