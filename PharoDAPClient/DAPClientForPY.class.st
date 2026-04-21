Class {
	#name : 'DAPClientForPY',
	#superclass : 'SindarinDAPClient',
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

{ #category : 'registry' }
DAPClientForPY >> dapRegistryAt: keyAsString put: valueAsString [

	self
		stackTrace: (DAPStackTraceArguments new threadId: self mainThreadId)
		onResponse: [ :resp |
				self setExpression: (DAPSetExpressionArguments new
						 expression:
							 '__import__("builtins").__dap_registry__["' , keyAsString
							 , '"]';
						 value: valueAsString;
						 frameId: (((resp at: 'body') at: 'stackFrames') first at: 'id')) ]
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
		line: 10;
		backend: DAPBackendPY new;
		startClientSession
]

{ #category : 'registry' }
DAPClientForPY >> initializeDapRegistry [

	self
		stackTrace: (DAPStackTraceArguments new threadId: self mainThreadId)
		onResponse: [ :resp |
				self evaluate: (DAPEvaluateArguments new
						 expression:
							 '__import__("builtins").__dict__.setdefault("__dap_registry__", {})';
						 frameId: (((resp at: 'body') at: 'stackFrames') first at: 'id')) ]
]

{ #category : 'stack access' }
DAPClientForPY >> variablesForObject: aVariableName inStackFrame: frameId [

	| specialVariablesReference |
	specialVariablesReference := (super
		                              variablesForObject: aVariableName
		                              inStackFrame: frameId) first at:
		                             'variablesReference'.
	^ self variablesForReference: specialVariablesReference
]
