Class {
	#name : 'DAPClientBuilder',
	#superclass : 'Object',
	#instVars : [
		'client',
		'host',
		'port',
		'adapterID',
		'breakpoints',
		'functionBreakpoints',
		'attachArguments'
	],
	#category : 'PharoDAPClient-Builders',
	#package : 'PharoDAPClient',
	#tag : 'Builders'
}

{ #category : 'accessing' }
DAPClientBuilder >> adapterID: aString [

	adapterID := aString
]

{ #category : 'accessing' }
DAPClientBuilder >> attachArguments: anAttachArguments [

	attachArguments := anAttachArguments
]

{ #category : 'private' }
DAPClientBuilder >> attachClient [

	client attach: attachArguments
]

{ #category : 'accessing' }
DAPClientBuilder >> breakpoint: scriptPath line: anNumber [

	breakpoints at: scriptPath ifAbsentPut: [ OrderedCollection new ].

	(breakpoints at: scriptPath) add:
		(DAPSourceBreakpoint new line: anNumber)
]

{ #category : 'private' }
DAPClientBuilder >> configurationDone [

	client configurationDone
]

{ #category : 'private' }
DAPClientBuilder >> connectClient [

	client connectTo: host port: port.
	client startListening.
	client initialize: self initializeArguments.
]

{ #category : 'private' }
DAPClientBuilder >> connectClient: aBlock [

	client connectTo: host port: port.
	client startListening.
	client initialize: (self initializeArguments) onResponse: aBlock.
]

{ #category : 'accessing' }
DAPClientBuilder >> functionBreakpoint: functionName [

	functionBreakpoints add:
		(DAPFunctionBreakpoint new name: functionName)
]

{ #category : 'accessing' }
DAPClientBuilder >> host: aString [

	host := aString
]

{ #category : 'initialization' }
DAPClientBuilder >> initialize [

	super initialize.
	host := 'localhost'.
	client := DAPClient new.
	breakpoints := Dictionary new.
	functionBreakpoints := OrderedCollection new
]

{ #category : 'private' }
DAPClientBuilder >> initializeArguments [

	^ DAPInitializeRequestArguments new
		  clientID: 'my-dap-client';
		  clientName: 'Pharo dap client';
		  adapterID: adapterID;
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
		  locale: 'en'
]

{ #category : 'accessing' }
DAPClientBuilder >> port: anNumber [

	port := anNumber
]

{ #category : 'private' }
DAPClientBuilder >> setBreakpoints [

	breakpoints keysAndValuesDo: [ :scriptPath :sourceBreakpoints |
			| args |
			args := DAPSetBreakpointsArguments new
				        source: (DAPSource new path: scriptPath);
				        breakpoints: sourceBreakpoints asArray.

			client setBreakpoints: args ]
]

{ #category : 'private' }
DAPClientBuilder >> setFunctionBreakpoints [

	| args |
	args := DAPSetFunctionBreakpointsArguments new breakpoints:
		        functionBreakpoints asArray.

	client setFunctionBreakpoints: args
]

{ #category : 'api' }
DAPClientBuilder >> startClientSession [

	port ifNil: [ ^ self ].
	adapterID ifNil: [ ^ self ].
	attachArguments ifNil: [ ^ self ].

	client onEvent: 'initialized' do: [ :event |
			self setBreakpoints.
			self setFunctionBreakpoints.
			self configurationDone ].

	self connectClient: [ :resp | self attachClient ].

	^ client
]
