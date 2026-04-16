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

{ #category : 'registry' }
DAPClientForJAVA >> dapRegistryAt: keyAsString put: valueAsString [

	self
		stackTrace: (DAPStackTraceArguments new threadId: 1)
		onResponse: [ :resp |
				self evaluate: (DAPEvaluateArguments new
						 expression: 'System.setProperty("id_' , keyAsString
							 , '", Integer.toString(System.identityHashCode('
							 , valueAsString , ')))';
						 frameId: (((resp at: 'body') at: 'stackFrames') first at: 'id')) ]
]

{ #category : 'initialization' }
DAPClientForJAVA >> initialize [

	super initialize.

	DAPClientBuilder new
		client: self;
		port: 63461;
		adapterID: 'java';
		attachArguments: self attachArguments;
		breakpoint:
			'/Users/flavienvolant/Documents/sindarin-dap/java/src/main/java/example/Main.java'
		line: 5;
		breakpoint:
			'/Users/flavienvolant/Documents/sindarin-dap/java/src/main/java/example/Main.java'
		line: 9;
		functionBreakpoint: 'example.Bar#toto'
		condition:
			'Integer.toString(System.identityHashCode(this)).equals(System.getProperty("id_instance_to_follow_1"))';
		startClientSession
]

{ #category : 'registry' }
DAPClientForJAVA >> initializeDapRegistry [
	" In Java, there is no need to initialize a global registry.
	The java.lang.System object already exists and is globally accessible in the JVM.

	We use it as a simple key/value store via System.setProperty / System.getProperty.

	Because this storage is already built into the runtime, there is nothing to create or inject. "

	
]
