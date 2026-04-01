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
DAPClientForJS >> startSession [
	
	DAPClientBuilder new
		client: self;
		adapterID: 'node';
		port: 5678;
		attachArguments: self attachArguments;
		startClientSession 
]
