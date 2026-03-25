Class {
	#name : 'ClientDAPPresenter',
	#superclass : 'SpPresenter',
	#traits : 'DAPObserver',
	#classTraits : 'DAPObserver classTrait',
	#instVars : [
		'commandBarPresenter',
		'requestPresenter',
		'responsePresenter',
		'clientDAP',
		'messageListPresenter',
		'statePresenter'
	],
	#category : 'PharoDAPClient-Presenters',
	#package : 'PharoDAPClient',
	#tag : 'Presenters'
}

{ #category : 'helpers' }
ClientDAPPresenter >> addCommand: label iconName: iconName ask: question do: selector [

	commandBarPresenter addItem: (self newToolbarButton
			 label: label;
			 icon: (self iconNamed: iconName);
			 action: [
					 self
						 askInteger: question
						 do: [ :val | self perform: selector with: val ] ];
			 yourself)
]

{ #category : 'helpers' }
ClientDAPPresenter >> addCommand: label iconName: iconName do: selector [

	commandBarPresenter addItem: (self newToolbarButton
			 label: label;
			 icon: (self iconNamed: iconName);
			 action: [ self perform: selector ];
			 yourself)
]

{ #category : 'helpers' }
ClientDAPPresenter >> askInteger: aLabel do: aBlock [

	| input value |
	input := UIManager default request: aLabel.

	input ifNil: [ ^ self ].

	value := [ input asInteger ]
		         on: Error
		         do: [ ^ self ].

	value ifNotNil: [ aBlock value: value ]
]

{ #category : 'protocol' }
ClientDAPPresenter >> closeConnection [

	clientDAP stateChangedCallBack: [ :state |  ].
	clientDAP closeConnection
]

{ #category : 'helpers' }
ClientDAPPresenter >> colorForMessage: messageAsDict [

	| type |
	type := messageAsDict at: #type.

	type = 'request' ifTrue: [ ^ Color lightBlue ].
	type = 'response' ifTrue: [
			(messageAsDict at: #success) ifTrue: [ ^ Color lightGreen ].
			^ Color red ].
	type = 'event' ifTrue: [ ^ Color lightOrange ].

	^ Color white
]

{ #category : 'protocol' }
ClientDAPPresenter >> continue [

	self continue: 1
]

{ #category : 'protocol' }
ClientDAPPresenter >> continue: aThreadId [

	| args |
	args := DAPContinueArguments new threadId: aThreadId.
	clientDAP continue: args
]

{ #category : 'layout' }
ClientDAPPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: (SpBoxLayout newLeftToRight
				   add: #commandBarPresenter;
				   add: #statePresenter width: 100;
				   yourself)
		  height: 40;
		  add: (SpPanedLayout newLeftToRight
				   add: #messageListPresenter;
				   add: (SpPanedLayout newTopToBottom
						    add: #requestPresenter;
						    add: #responsePresenter;
						    yourself);
				   positionOfSlider: 300;
				   yourself);
		  yourself
]

{ #category : 'update' }
ClientDAPPresenter >> displayEvent: aDAPEvent [

	aDAPEvent ifNil: [ ^ self ].
	responsePresenter text:
		(STONJSON toStringPretty: aDAPEvent asDAPJSON).
	requestPresenter text: ''
]

{ #category : 'update' }
ClientDAPPresenter >> displayMessage: messageAsDict [

	| type |
	messageAsDict ifNil: [ ^ self ].
	type := messageAsDict at: 'type'.
	type = #request ifTrue: [ self displayRequest: messageAsDict ].
	type = #event ifTrue: [ self displayEvent: messageAsDict ].
	type = #response ifTrue: [ self displayResponse: messageAsDict ]
]

{ #category : 'update' }
ClientDAPPresenter >> displayRequest: aDAPRequest [

	| response |
	aDAPRequest ifNil: [ ^ self ].

	requestPresenter text: (STONJSON toStringPretty: aDAPRequest asDAPJSON ).

	response := clientDAP dapHistory responseForRequest: (aDAPRequest at: #seq).

	responsePresenter text: (response
			 ifNil: [ '' ]
			 ifNotNil: [ STONJSON toStringPretty: response asDAPJSON ])
]

{ #category : 'update' }
ClientDAPPresenter >> displayResponse: responseAsDict [

	| request |
	responseAsDict ifNil: [ ^ self ].
	
	responsePresenter text: (STONJSON toStringPretty: responseAsDict asDAPJSON ).

	request := clientDAP dapHistory request: (responseAsDict at: #request_seq).

	requestPresenter text: (request
			 ifNil: [ '' ]
			 ifNotNil: [ STONJSON toStringPretty: request asDAPJSON ])
]

{ #category : 'protocol' }
ClientDAPPresenter >> evaluate: frameId [

	| args |
	args := DAPEvaluateArguments new
		        context: 'repl';
		        frameId: frameId;
		        expression: '__pydevd_ret_val_dict["Foo.bar"]'.
	
	clientDAP evaluate: args 
]

{ #category : 'initialization' }
ClientDAPPresenter >> initialize [

	self uglyInitialzeForClient.
	super initialize
]

{ #category : 'initialization' }
ClientDAPPresenter >> initializeCommandBar [
	
	commandBarPresenter := self newToolbar.
	
	self addCommand: 'Threads' iconName: #trait do: #threads. 
	self addCommand: 'Stack Trace' iconName: #browse do: #stackTrace.
	self addCommand: 'Scopes' iconName: #folder ask: 'Frame Id ?' do: #scopes:.
	self addCommand: 'Variables' iconName: #table ask: 'Variables Reference ?' do: #variables:.
	self addCommand: 'Continue' iconName: #go do: #continue. 
	self addCommand: 'Next' iconName: #right do: #next.
	self addCommand: 'Step In' iconName: #into do: #stepInDAP.
	self addCommand: 'Step Out' iconName: #over do: #stepOut.
	self addCommand: 'Evaluate' iconName: #browse ask: 'Frame Id ?' do: #evaluate:.
	self addCommand: 'Set Expression' iconName: #edit  ask: 'Frame Id ?' do: #setExpression:. 
	self addCommand: 'Disconnect' iconName: #close do: #closeConnection
]

{ #category : 'initialization' }
ClientDAPPresenter >> initializeMessageList [

	messageListPresenter := self newTable.

	messageListPresenter
		addColumn: ((SpStringTableColumn
				  title: 'Seq'
				  evaluated: [ :item | item at: 'seq' ifAbsent: [ '' ] ]) width:
					 40);
		addColumn: ((SpStringTableColumn
				  title: 'Type'
				  evaluated: [ :item | item at: 'type' ifAbsent: [ '' ] ])
				 width: 80;
				 displayColor: [ :item | self colorForMessage: item ]);
		addColumn: (SpStringTableColumn title: 'Name' evaluated: [ :item |
				 item
					 at: 'event'
					 ifAbsent: [ item at: 'command' ifAbsent: [ '' ] ] ]);
		whenSelectionChangedDo: [ :selection |
		self displayMessage: selection selectedItem ]
]

{ #category : 'initialization' }
ClientDAPPresenter >> initializePresenters [

	self initializeCommandBar.
	self initializeMessageList.
	self initializeRequest.
	self initializeResponse.
	self initializeState.
	
	clientDAP stateChangedCallBack: [ :state | self onStateChanged: state ].
	clientDAP dapHistory addObserver: self.

	self updateMessageList
]

{ #category : 'initialization' }
ClientDAPPresenter >> initializeRequest [

	requestPresenter := self newText.
	requestPresenter beNotEditable
]

{ #category : 'initialization' }
ClientDAPPresenter >> initializeResponse [

	responsePresenter := self newText.
	responsePresenter beNotEditable
]

{ #category : 'initialization' }
ClientDAPPresenter >> initializeState [

	statePresenter := self newLabel.
	statePresenter label: clientDAP state asString
]

{ #category : 'initialization' }
ClientDAPPresenter >> initializeWindow: aWindowPresenter [
	
	super initializeWindow: aWindowPresenter.
	aWindowPresenter 
		title: 'Client DAP';
		initialExtent: 800@400
]

{ #category : 'protocol' }
ClientDAPPresenter >> next [

	self next: 1
]

{ #category : 'protocol' }
ClientDAPPresenter >> next: aThreadId [

	| args |
	args := DAPNextArguments new threadId: aThreadId.
	clientDAP next: args
]

{ #category : 'event handling' }
ClientDAPPresenter >> onStateChanged: aState [
	
	statePresenter label: aState 
]

{ #category : 'initialization' }
ClientDAPPresenter >> open [

	| window |
	window := super open.
	window whenClosedDo: [ self closeConnection ]
]

{ #category : 'protocol' }
ClientDAPPresenter >> scopes: aFrameId [

	| args |
	args := DAPScopesArguments new frameId: aFrameId.
	clientDAP scopes: args
]

{ #category : 'protocol' }
ClientDAPPresenter >> setExpression: aFramedId [

	| args |
	args := DAPSetExpressionArguments new
		        expression: 'Bar.toto';
		        value: 'lambda self: bar.toto()';
		        frameId: aFramedId.

	clientDAP setExpression: args
]

{ #category : 'protocol' }
ClientDAPPresenter >> stackTrace [

	self stackTrace: 1
]

{ #category : 'protocol' }
ClientDAPPresenter >> stackTrace: aThreadId [

	| args |
	args := DAPStackTraceArguments new
		        threadId: aThreadId;
		        format: {
				        (#parameters -> true).
				        (#parameterTypes -> true).
				        (#parameterNames -> true).
				        (#parameterValues -> true).
				        (#line -> true).
				        (#module -> true).
				        (#includeAll -> true) } asDictionary;
		        yourself.

	clientDAP stackTrace: args
]

{ #category : 'protocol' }
ClientDAPPresenter >> stepInDAP [

	self stepInDAP: 1
]

{ #category : 'protocol' }
ClientDAPPresenter >> stepInDAP: aThreadId [

	| args |
	args := DAPStepInArguments new threadId: aThreadId.
	clientDAP stepIn: args
]

{ #category : 'protocol' }
ClientDAPPresenter >> stepOut [
	
	self stepOut: 1
]

{ #category : 'protocol' }
ClientDAPPresenter >> stepOut: aThreadId [

	| args |
	args := DAPStepOutArguments new threadId: aThreadId.
	clientDAP stepOut: args
]

{ #category : 'protocol' }
ClientDAPPresenter >> threads [

	clientDAP threads
]

{ #category : 'initialization' }
ClientDAPPresenter >> uglyInitialzeForClient [

	| host port scriptPath args cwdPath |
	host := 'localhost'.
	port := 5678.
	scriptPath := '/Users/flavienvolant/Documents/sindarin-dap/py/script.py'.
	cwdPath := '/Users/flavienvolant/Documents/sindarin-dap/py'.

	clientDAP := DAPClient new.

	clientDAP connectTo: host port: port.

	clientDAP startListening.

	args := DAPInitializeRequestArguments new
		        clientID: 'my-dap-client';
		        clientName: 'Pharo dap client';
		        adapterID: 'python';
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
		        locale: 'en'.

	clientDAP initialize: args.

	args := DAPSetBreakpointsArguments new
		        source: (DAPSource new path: scriptPath);
		        breakpoints: (Array
				         with: (DAPSourceBreakpoint new line: 1)
				         with: (DAPSourceBreakpoint new line: 5)).

	clientDAP setBreakpoints: args.
	clientDAP configurationDone.

	args := {
		        ('name' -> 'Attach to Python').
		        ('type' -> 'python').
		        ('connect' -> {
			         ('host' -> host).
			         ('port' -> port) } asDictionary).
		        ('redirectOutput' -> true).
		        ('showReturnValue' -> true) } asDictionary.

	clientDAP attach: args
]

{ #category : 'update' }
ClientDAPPresenter >> updateMessageList [

	messageListPresenter items:
		clientDAP dapHistory messages.
	messageListPresenter refresh
]

{ #category : 'event handling' }
ClientDAPPresenter >> updateWithEvent: aDAPEvent [

	self updateMessageList 
]

{ #category : 'event handling' }
ClientDAPPresenter >> updateWithRequest: aDAPRequest [
	
	self updateMessageList 
]

{ #category : 'event handling' }
ClientDAPPresenter >> updateWithResponse: aDAPResponse [

	self updateMessageList
]

{ #category : 'protocol' }
ClientDAPPresenter >> variables: aVariablesReference [

	| args |
	args := DAPVariablesArguments new variablesReference:
		        aVariablesReference.
	clientDAP variables: args
]
