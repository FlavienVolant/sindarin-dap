Class {
	#name : 'DAPClientForJAVA',
	#superclass : 'SindarinDAPClient',
	#category : 'PharoDAPClient-Examples',
	#package : 'PharoDAPClient',
	#tag : 'Examples'
}

{ #category : 'initialization' }
DAPClientForJAVA >> attachArguments [

	^ {
		  ('name' -> 'Attach to Java').
		  ('type' -> 'server').
		  ('hostName' -> 'localhost').
		  ('port' -> 5005).
		  ('projectName' -> 'java') } asDictionary
]

{ #category : 'initialization' }
DAPClientForJAVA >> initialize [

	super initialize.

	DAPClientBuilder new
		client: self;
		port: 64894;
		adapterID: 'java';
		attachArguments: self attachArguments;
		breakpoint:
			'/Users/flavienvolant/Documents/sindarin-dap/java/src/main/java/example/Main.java'
		line: 9;
		backend: DAPBackendJAVA new;
		startClientSession
]
