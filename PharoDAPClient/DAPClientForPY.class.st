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
		stackTrace: (DAPStackTraceArguments new threadId: 1)
		onResponse: [ :resp |
				self setExpression: (DAPSetExpressionArguments new
						 expression:
							 '__import__("builtins").__dap_registry__["id_' , keyAsString
							 , '"]';
						 value: 'id(' , valueAsString , ')';
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
		line: 8;
		functionBreakpoint: 'toto'
		condition: 'id(self) == __import__("builtins").__dap_registry__.get("id_instance_to_follow_1")';
		startClientSession
]

{ #category : 'registry' }
DAPClientForPY >> initializeDapRegistry [

	self
		stackTrace: (DAPStackTraceArguments new threadId: 1)
		onResponse: [ :resp |
				self evaluate: (DAPEvaluateArguments new
						 expression:
							 '__import__("builtins").__dict__.setdefault("__dap_registry__", {})';
						 frameId: (((resp at: 'body') at: 'stackFrames') first at: 'id')) ]
]
