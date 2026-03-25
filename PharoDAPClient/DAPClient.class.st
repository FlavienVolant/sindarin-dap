Class {
	#name : 'DAPClient',
	#superclass : 'Object',
	#instVars : [
		'socket',
		'seq',
		'buffer',
		'listenerProcess',
		'eventHandlers',
		'responseHandlers',
		'dapHistory',
		'state',
		'pendingRequests',
		'stateChangedCallBack'
	],
	#category : 'PharoDAPClient-Model',
	#package : 'PharoDAPClient',
	#tag : 'Model'
}

{ #category : 'requests' }
DAPClient >> attach: attachArguments [

	| request |
	
	(self
		 verifyStateForRequest: #attach:
		 arguments: attachArguments
		 requiredState: #initializeResponse) ifFalse: [ ^ self ].
	
	request := DAPAttachRequest withArguments: attachArguments.

	self sendRequest: request onResponse: [ :rest |
			eventHandlers
				at: 'stopped' put: [ :event | self state: #stopped ];
				at: 'continued' put: [ :event | self state: #running ];
				at: 'exited' put: [ :event | self state: #disconnected ];
				at: 'terminated' put: [ :event | self state: #terminated ].
			self state: #running ].
	self state: #launching
]

{ #category : 'connection open/close' }
DAPClient >> closeConnection [

	listenerProcess ifNotNil: [
			listenerProcess terminate.
			listenerProcess := nil ].

	socket ifNotNil: [
			socket close.
			socket := nil ].

	eventHandlers keysAndValuesRemove: [ :key :value | true ].
	responseHandlers keysAndValuesRemove: [ :key :value | true ].
	self state: #disconnected
]

{ #category : 'requests' }
DAPClient >> configurationDone [

	| request |
	(self
		 verifyStateForRequest: #configurationDone
		 arguments: nil
		 requiredState: #initialized) ifFalse: [ ^ self ].

	request := DAPConfigurationDoneRequest new.
	self
		sendRequest: request
		onResponse: [ :resp | self state: #configured ]
]

{ #category : 'connection open/close' }
DAPClient >> connectTo: aHostName port: aPort [

	socket := SocketStream
		          openConnectionToHostNamed: aHostName
		          port: aPort.
	socket noTimeout.
	state := #connecting
]

{ #category : 'requests' }
DAPClient >> continue: continueArguments [

	| request |
	state = #stopped ifFalse: [ ^ self ].

	request := DAPContinueRequest withArguments: continueArguments.
	self sendRequest: request
]

{ #category : 'accessing' }
DAPClient >> dapHistory [

	^ dapHistory
]

{ #category : 'requests' }
DAPClient >> evaluate: evaluateArguments [

	| req |
	state = #stopped ifFalse: [ ^ self ].
	req := DAPEvaluateRequest withArguments: evaluateArguments.
	self sendRequest: req
]

{ #category : 'communication' }
DAPClient >> handleEvent: eventAsDict [

	| eventType handler |
	dapHistory addEvent: eventAsDict.

	eventType := eventAsDict at: 'event'.
	handler := eventHandlers at: eventType ifAbsent: [ ^ self ].
	handler value: eventAsDict
]

{ #category : 'communication' }
DAPClient >> handleResponse: responseAsDict [

	| request_seq callback |

	dapHistory addResponse: responseAsDict.

	request_seq := responseAsDict at: 'request_seq'.
	callback := responseHandlers at: request_seq.
	responseHandlers removeKey: request_seq.
	callback value: responseAsDict
]

{ #category : 'initialization' }
DAPClient >> initialize [

	super initialize.
	seq := 1.
	buffer := ByteArray new.
	responseHandlers := Dictionary new.
	eventHandlers := Dictionary new.
	dapHistory := DAPHistory new.
	pendingRequests := OrderedCollection new.
	self state: #disconnected
]

{ #category : 'requests' }
DAPClient >> initialize: initializeArguments [

	| request |
	(self
		 verifyStateForRequest: #initialize:
		 arguments: initializeArguments
		 requiredState: #connecting) ifFalse: [ ^ self ].

	request := DAPInitializeRequest withArguments: initializeArguments.
	self
		sendRequest: request
		onResponse: [ :resp | self state: #initializeResponse ].

	eventHandlers at: 'initialized' put: [ :event |
			self state: #initialized.
			eventHandlers removeKey: 'initialized' ifAbsent: [ ^ self ] ].
	self state: #initializing
]

{ #category : 'requests' }
DAPClient >> launch: launchArguments [

	| request |
	
	(self
		 verifyStateForRequest: #launch:
		 arguments: launchArguments
		 requiredState: #initializeResponse) ifFalse: [ ^ self ].
	
	request := DAPLaunchRequest withArguments: launchArguments.

	self sendRequest: request onResponse: [ :rest |
			eventHandlers
				at: 'stopped' put: [ :event | self state: #stopped ];
				at: 'continued' put: [ :event | self state: #running ];
				at: 'exited' put: [ :event | self state: #disconnected ];
				at: 'terminated' put: [ :event | self state: #terminated ].
			self state: #running ].
	self state: #launching
]

{ #category : 'requests' }
DAPClient >> next: nextArguments [

	| request |
	state = #stopped ifFalse: [ ^ self ].
	request := DAPNextRequest withArguments: nextArguments.
	self sendRequest: request
]

{ #category : 'initialization' }
DAPClient >> onEvent: eventName do: block [
	eventHandlers at: eventName put: block 
]

{ #category : 'communication' }
DAPClient >> readHeadersAsDict [

	| dict line |
	dict := Dictionary new.

	[
		| key value |
		line := socket nextLineCrLf.
		line ifNil: [ ^ nil ].

		line isEmpty ifTrue: [ ^ dict ].

		key := (line asString copyUpTo: $:) asLowercase.
		value := (line asString copyAfter: $:) trimBoth.
		dict at: key put: value ] repeat
]

{ #category : 'communication' }
DAPClient >> readMessageAsDict [

	| headers contentLength body |
	headers := self readHeadersAsDict.
	contentLength := (headers at: 'content-length' ifAbsent: [ 0 ])
		                 asNumber.
	body := socket next: contentLength.
	^ STONJSON fromString: body
]

{ #category : 'requests' }
DAPClient >> scopes: scopesArguments [

	| request |
	state = #stopped ifFalse: [ ^ self ].
	request := DAPScopesRequest withArguments: scopesArguments.
	self sendRequest: request
]

{ #category : 'communication' }
DAPClient >> sendRequest: aDAPRequest [

	self sendRequest: aDAPRequest onResponse: [ :response | ]
]

{ #category : 'communication' }
DAPClient >> sendRequest: aDAPRequest onResponse: callBackBlock [

	| json bytes header requestSeq |
	requestSeq := seq.
	seq := seq + 1.

	aDAPRequest seq: requestSeq.
	dapHistory addRequest: aDAPRequest asDAPJSON.
	responseHandlers at: requestSeq put: callBackBlock.

	json := STONJSON toString: aDAPRequest asDAPJSON.
	bytes := json utf8Encoded.

	header := 'Content-Length: ' , bytes size printString , String crlf
	          , String crlf.

	socket nextPutAll: header asByteArray.
	socket nextPutAll: bytes.
	socket flush
]

{ #category : 'requests' }
DAPClient >> setBreakpoints: setBreakPointsArguments [

	| request |
	(self
		 verifyStateForRequest: #setBreakpoints:
		 arguments: setBreakPointsArguments
		 requiredState: #initialized) ifFalse: [ ^ self ].

	request := DAPSetBreakpointsRequest withArguments:
		           setBreakPointsArguments.
	self sendRequest: request
]

{ #category : 'requests' }
DAPClient >> setExpression: setExpressionArguments [

	| request |
	state = #stopped ifFalse: [ ^ self ].
	request := DAPSetExpressionRequest withArguments: setExpressionArguments.
	self sendRequest: request
]

{ #category : 'requests' }
DAPClient >> setFunctionBreakpoints: setFunctionBreakpointsArguments [

	| request |
	(self
		 verifyStateForRequest: #setFunctionBreakpoints:
		 arguments: setFunctionBreakpointsArguments
		 requiredState: #initialized) ifFalse: [ ^ self ].

	request := DAPSetFunctionBreakpointsRequest withArguments:
		           setFunctionBreakpointsArguments.
	self sendRequest: request
]

{ #category : 'requests' }
DAPClient >> stackTrace: stackTraceArguments [

	| request |
	state = #stopped ifFalse: [ ^ self ].
	request := DAPStackTraceRequest withArguments: stackTraceArguments.
	self sendRequest: request
]

{ #category : 'communication' }
DAPClient >> startListening [

	listenerProcess := [
		[
			| json |
			json := self readMessageAsDict.
			
			(json at: #type) = 'event' ifTrue: [ self handleEvent: json ].
			(json at: #type) = 'response' ifTrue: [ self handleResponse: json ].

		] repeat 
	] fork
]

{ #category : 'accessing' }
DAPClient >> state [

	^ state
]

{ #category : 'states' }
DAPClient >> state: aState [

	state := aState.

	pendingRequests do: [ :req |
		(req canExecute: state) ifTrue: [ req execute: self ] ].

	stateChangedCallBack ifNotNil: [ stateChangedCallBack value: aState ]
]

{ #category : 'accessing' }
DAPClient >> stateChangedCallBack: aBlock [

	stateChangedCallBack := aBlock 
]

{ #category : 'requests' }
DAPClient >> stepIn: stepInArguments [

	| request |
	state = #stopped ifFalse: [ ^ self ].
	request := DAPStepInRequest withArguments: stepInArguments.
	self sendRequest: request
]

{ #category : 'requests' }
DAPClient >> stepOut: stepOutArguments [

	| request |
	state = #stopped ifFalse: [ ^ self ].
	request := DAPStepOutRequest withArguments: stepOutArguments.
	self sendRequest: request
]

{ #category : 'requests' }
DAPClient >> threads [ 
	
	| request |
	request := DAPThreadsRequest new.
	self sendRequest: request
]

{ #category : 'requests' }
DAPClient >> variables: variablesArguments [

	| request |
	state = #stopped ifFalse: [ ^ self ].
	request := DAPVariablesRequest withArguments: variablesArguments.
	self sendRequest: request
]

{ #category : 'states' }
DAPClient >> verifyStateForRequest: requestSymbole arguments: args requiredState: requiredState [

	state = requiredState ifFalse: [
			pendingRequests add: (PendingRequest
					 request: requestSymbole
					 arguments: args
					 requiredState: requiredState).
			^ false ].
	^ true
]
