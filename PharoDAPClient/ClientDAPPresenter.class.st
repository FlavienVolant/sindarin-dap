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
		'messageListPresenter'
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

	| args request |
	args := DAPContinueArguments new threadId: aThreadId.
	request := DAPContinueRequest withArguments: args.

	clientDAP sendRequest: request
]

{ #category : 'layout' }
ClientDAPPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: #commandBarPresenter height: 40;
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

{ #category : 'initialization' }
ClientDAPPresenter >> initialize [

	self uglyInitialzeForClient.
	super initialize
]

{ #category : 'initialization' }
ClientDAPPresenter >> initializeCommandBar [
	
	commandBarPresenter := self newToolbar.

	self addCommand: 'Stack Trace' iconName: #browse do: #stackTrace.
	self addCommand: 'Scopes' iconName: #folder ask: 'Frame Id ?' do: #scopes:.
	self addCommand: 'Variables' iconName: #table ask: 'Variables Reference ?' do: #variables:.
	self addCommand: 'Continue' iconName: #go do: #continue. 
	self addCommand: 'Next' iconName: #right do: #next.
	self addCommand: 'Step In' iconName: #into do: #stepInDAP.
	self addCommand: 'Step Out' iconName: #over do: #stepOut.
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

	| args request |
	args := DAPNextArguments new threadId: aThreadId.
	request := DAPNextRequest withArguments: args.

	clientDAP sendRequest: request
]

{ #category : 'initialization' }
ClientDAPPresenter >> open [

	| window |
	window := super open.
	window whenClosedDo: [ self closeConnection ]
]

{ #category : 'protocol' }
ClientDAPPresenter >> scopes: aFrameId [

	| args request |
	args := DAPScopesArguments new frameId: aFrameId.
	request := DAPScopesRequest withArguments: args.

	clientDAP sendRequest: request
]

{ #category : 'protocol' }
ClientDAPPresenter >> stackTrace [

	self stackTrace: 1
]

{ #category : 'protocol' }
ClientDAPPresenter >> stackTrace: aThreadId [

	| args request |
	args := DAPStackTraceArguments new threadId: aThreadId.
	request := DAPStackTraceRequest withArguments: args.

	clientDAP sendRequest: request
]

{ #category : 'protocol' }
ClientDAPPresenter >> stepInDAP [

	self stepInDAP: 1
]

{ #category : 'protocol' }
ClientDAPPresenter >> stepInDAP: aThreadId [

	| args request |
	args := DAPStepInArguments new threadId: aThreadId.
	request := DAPStepInRequest withArguments: args.

	clientDAP sendRequest: request
]

{ #category : 'protocol' }
ClientDAPPresenter >> stepOut [
	
	self stepOut: 1
]

{ #category : 'protocol' }
ClientDAPPresenter >> stepOut: aThreadId [

	| args request |
	args := DAPStepOutArguments new threadId: aThreadId.
	request := DAPStepOutRequest withArguments: args.

	clientDAP sendRequest: request
]

{ #category : 'initialization' }
ClientDAPPresenter >> uglyInitialzeForClient [

	| host port scriptPath args message |
	host := 'localhost'.
	port := 5678.
	scriptPath := '/Users/flavienvolant/Documents/sindarin-dap/script.py'.

	clientDAP := DAPClient new.
	clientDAP connectTo: host port: port.

	clientDAP startListening.

	args := DAPInitializeRequestArguments new
		        clientID: 'my-dap-client';
		        adapterID: 'python';
		        pathFormat: 'path';
		        linesStartAt1: true;
		        columnsStartAt1: true;
		        supportsProgressReporting: true;
		        supportsMemoryReferences: true;
		        supportsInvalidatedEvent: true;
		        supportsRunInTerminalRequest: true;
		        supportsVariableType: true.
	message := DAPInitializeRequest withArguments: args.
	clientDAP sendRequest: message.

	args := DAPDebugPyAttachRequestArguments host: 'localhost' port: port.

	message := DAPAttachRequest withArguments: args.
	clientDAP sendRequest: message.

	args := DAPSetBreakpointsArguments new
		        source: (DAPSource new path: scriptPath);
		        breakpoints: (Array with: (DAPSourceBreakpoint new line: 5)).

	message := DAPSetBreakpointsRequest withArguments: args.

	clientDAP sendRequest: message.

	message := DAPConfigurationDoneRequest new.
	clientDAP sendRequest: message
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

	| args request |
	args := DAPVariablesArguments new variablesReference:
		        aVariablesReference.
	request := DAPVariablesRequest withArguments: args.

	clientDAP sendRequest: request
]
