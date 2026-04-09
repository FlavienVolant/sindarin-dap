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

{ #category : 'initialization' }
DAPClientForPY >> initialize [

	super initialize.

	DAPClientBuilder new
		client: self;
		port: 5678;
		adapterID: 'python';
		attachArguments: self attachArguments;
		breakpoint:
			'/Users/flavienvolant/Documents/sindarin-dap/py/script_parser.py'
		line: 1;
		functionBreakpoint: 'bar' condition: 'isinstance(self, Foo)';
		functionBreakpoint: 'toto';
		startClientSession
]
