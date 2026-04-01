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
		'requestHandlers',
		'dapHistory'
	],
	#category : 'PharoDAPClient-Model',
	#package : 'PharoDAPClient',
	#tag : 'Model'
}

{ #category : 'requests' }
DAPClient >> attach: attachArguments [

	self attach: attachArguments onResponse: [ :resp | ]
]

{ #category : 'requests' }
DAPClient >> attach: attachArguments onResponse: aBlock [

	| request |
	request := DAPAttachRequest withArguments: attachArguments.
	self sendRequest: request onResponse: aBlock 
]

{ #category : 'connection open/close' }
DAPClient >> closeConnection [

	self flag: 'Send DisconnectRequest'.

	listenerProcess ifNotNil: [
			listenerProcess terminate.
			listenerProcess := nil ].

	socket ifNotNil: [
			socket close.
			socket := nil ].

	eventHandlers keysAndValuesRemove: [ :key :value | true ].
	responseHandlers keysAndValuesRemove: [ :key :value | true ].
	requestHandlers keysAndValuesRemove: [ :key :value | true ]
]

{ #category : 'requests' }
DAPClient >> configurationDone [

	| request |
	request := DAPConfigurationDoneRequest new.
	self sendRequest: request
]

{ #category : 'connection open/close' }
DAPClient >> connectTo: aHostName port: aPort [

	socket := SocketStream
		          openConnectionToHostNamed: aHostName
		          port: aPort.
	socket noTimeout
]

{ #category : 'requests' }
DAPClient >> continue: continueArguments [

	self continue: continueArguments onResponse: [ :resp |  ]
]

{ #category : 'requests' }
DAPClient >> continue: continueArguments onResponse: aBlock [

	| request |
	request := DAPContinueRequest withArguments: continueArguments.
	self sendRequest: request onResponse: aBlock 
]

{ #category : 'accessing' }
DAPClient >> dapHistory [

	^ dapHistory
]

{ #category : 'requests' }
DAPClient >> evaluate: evaluateArguments [

	self evaluate: evaluateArguments onResponse: [ :resp |  ]
]

{ #category : 'requests' }
DAPClient >> evaluate: evaluateArguments onResponse: aBlock [

	| req |
	req := DAPEvaluateRequest withArguments: evaluateArguments.
	self sendRequest: req onResponse: aBlock 
]

{ #category : 'requests' }
DAPClient >> goto: gotoArguments [

	self goto: gotoArguments onResponse: [ :resp |  ]
]

{ #category : 'requests' }
DAPClient >> goto: gotoArguments onResponse: aBlock [

	| req |
	req := DAPGotoRequest withArguments: gotoArguments.
	self sendRequest: req onResponse: aBlock 
]

{ #category : 'requests' }
DAPClient >> gotoTarget: gotoTargetArguments [

	self gotoTarget: gotoTargetArguments onResponse: [ :resp |  ]
]

{ #category : 'requests' }
DAPClient >> gotoTarget: gotoTargetArguments onResponse: aBlock [

	| req |
	req := DAPGotoTargetsRequest withArguments: gotoTargetArguments.
	self sendRequest: req onResponse: aBlock 
]

{ #category : 'communication' }
DAPClient >> handleEvent: eventAsDict [

	| eventType handler |
	Transcript showCr: eventAsDict.
	dapHistory addEvent: eventAsDict.

	eventType := eventAsDict at: 'event'.
	handler := eventHandlers at: eventType ifAbsent: [ ^ self ].
	handler value: eventAsDict
]

{ #category : 'communication' }
DAPClient >> handleRequest: requestAsDict [

	| request_seq request_command callback |
	self flag: 'ugly'.

	dapHistory addRequest: requestAsDict.
	request_seq := requestAsDict at: 'seq'.
	request_command := requestAsDict at: 'command'.

	(requestHandlers includesKey: request_command) ifFalse: [
			| json bytes header |
			json := {
				        ('seq' -> self newSeq).
				        ('type' -> 'response').
				        ('request_seq' -> request_seq).
				        ('command' -> request_command).
				        ('success' -> false).
				        ('message' -> (request_command , ' is not supported')) }
				        asDictionary.

			bytes := (STONJSON toString: json) utf8Encoded.

			header := 'Content-Length: ' , bytes size printString , String crlf
			          , String crlf.

			Transcript showCr: (STONJSON toStringPretty: json).

			socket nextPutAll: header asByteArray.
			socket nextPutAll: bytes.
			socket flush.
			dapHistory addResponse: json.
			^ self ].

	callback := requestHandlers at: request_command.
	requestHandlers removeKey: request_command.
	callback value: requestAsDict
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
	requestHandlers := Dictionary new.
	dapHistory := DAPHistory new
]

{ #category : 'requests' }
DAPClient >> initialize: initializeArguments [

	self initialize: initializeArguments onResponse: [ :resp | ]
]

{ #category : 'requests' }
DAPClient >> initialize: initializeArguments onResponse: aBlock [

	"aBlock take the response as argument"

	| request |
	request := DAPInitializeRequest withArguments: initializeArguments.
	self sendRequest: request onResponse: aBlock.
]

{ #category : 'requests' }
DAPClient >> launch: launchArguments [

	self launch: launchArguments onResponse: [ :resp | ]
]

{ #category : 'requests' }
DAPClient >> launch: launchArguments onResponse: aBlock [

	| request |
	request := DAPLaunchRequest withArguments: launchArguments.
	self sendRequest: request onResponse: aBlock 
]

{ #category : 'accessing' }
DAPClient >> newSeq [

	| requestSeq |
	requestSeq := seq.
	seq := seq + 1.
	^ requestSeq
]

{ #category : 'requests' }
DAPClient >> next: nextArguments [

	self next: nextArguments onResponse: [ :resp | ]
]

{ #category : 'requests' }
DAPClient >> next: nextArguments onResponse: aBlock [

	| request |
	request := DAPNextRequest withArguments: nextArguments.
	self sendRequest: request onResponse: aBlock 
]

{ #category : 'communication' }
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

	self scopes: scopesArguments onResponse: [ :resp | ]
]

{ #category : 'requests' }
DAPClient >> scopes: scopesArguments onResponse: aBlock [

	| request |
	request := DAPScopesRequest withArguments: scopesArguments.
	self sendRequest: request onResponse: aBlock 
]

{ #category : 'communication' }
DAPClient >> sendRequest: aDAPRequest [

	self sendRequest: aDAPRequest onResponse: [ :response | ]
]

{ #category : 'communication' }
DAPClient >> sendRequest: aDAPRequest onResponse: callBackBlock [

	| json bytes header requestSeq |
	requestSeq := self newSeq.

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

	self setBreakpoints: setBreakPointsArguments onResponse: [ :resp | ]
]

{ #category : 'requests' }
DAPClient >> setBreakpoints: setBreakPointsArguments onResponse: aBlock [

	| request |
	request := DAPSetBreakpointsRequest withArguments:
		           setBreakPointsArguments.
	self sendRequest: request onResponse: aBlock 
]

{ #category : 'requests' }
DAPClient >> setExpression: setExpressionArguments [

	self setExpression: setExpressionArguments onResponse: [ :resp | ]
]

{ #category : 'requests' }
DAPClient >> setExpression: setExpressionArguments onResponse: aBlock [

	| request |
	request := DAPSetExpressionRequest withArguments:
		           setExpressionArguments.
	self sendRequest: request onResponse: aBlock 
]

{ #category : 'requests' }
DAPClient >> setFunctionBreakpoints: setFunctionBreakpointsArguments [

	self setFunctionBreakpoints: setFunctionBreakpointsArguments onResponse: [ :resp | ]
]

{ #category : 'requests' }
DAPClient >> setFunctionBreakpoints: setFunctionBreakpointsArguments onResponse: aBlock [

	| request |
	request := DAPSetFunctionBreakpointsRequest withArguments:
		           setFunctionBreakpointsArguments.
	self sendRequest: request onResponse: aBlock 
]

{ #category : 'requests' }
DAPClient >> stackTrace: stackTraceArguments [

	self stackTrace: stackTraceArguments onResponse: [ :resp | ]
]

{ #category : 'requests' }
DAPClient >> stackTrace: stackTraceArguments onResponse: aBlock [

	| request |
	request := DAPStackTraceRequest withArguments: stackTraceArguments.
	self sendRequest: request onResponse: aBlock 
]

{ #category : 'communication' }
DAPClient >> startListening [

	listenerProcess := [
		[
			| json |
			json := self readMessageAsDict.
			
			(json at: #type) = 'event' ifTrue: [ self handleEvent: json ].
			(json at: #type) = 'response' ifTrue: [ self handleResponse: json ].
			(json at: #type) = 'request' ifTrue: [ self handleRequest: json ].

		] repeat 
	] fork
]

{ #category : 'requests' }
DAPClient >> stepIn: stepInArguments [

	self stepIn: stepInArguments onResponse: [ :resp | ]
]

{ #category : 'requests' }
DAPClient >> stepIn: stepInArguments onResponse: aBlock [

	| request |
	request := DAPStepInRequest withArguments: stepInArguments.
	self sendRequest: request onResponse: aBlock 
]

{ #category : 'requests' }
DAPClient >> stepInTargets: stepInTargetsArguments [

	self stepInTargets: stepInTargetsArguments onResponse: [ :resp |  ]
]

{ #category : 'requests' }
DAPClient >> stepInTargets: stepInTargetsArguments onResponse: aBlock [

	| request |
	request := DAPStepInTargetsRequest withArguments:
		           stepInTargetsArguments.
	self sendRequest: request onResponse: aBlock 
]

{ #category : 'requests' }
DAPClient >> stepOut: stepOutArguments [

	self stepOut: stepOutArguments onResponse: [ :resp | ]
]

{ #category : 'requests' }
DAPClient >> stepOut: stepOutArguments onResponse: aBlock [

	| request |
	request := DAPStepOutRequest withArguments: stepOutArguments.
	self sendRequest: request onResponse: aBlock
]

{ #category : 'requests' }
DAPClient >> threads [ 
	
	self threadsOnResponse: [ :resp | ]
]

{ #category : 'requests' }
DAPClient >> threadsOnResponse: aBlock [
	
	| request |
	request := DAPThreadsRequest new.
	self sendRequest: request onResponse: aBlock 
]

{ #category : 'requests' }
DAPClient >> variables: variablesArguments [

	| request |
	request := DAPVariablesRequest withArguments: variablesArguments.
	self sendRequest: request
]

{ #category : 'requests' }
DAPClient >> variables: variablesArguments onResponse: aBlock [

	| request |
	request := DAPVariablesRequest withArguments: variablesArguments.
	self sendRequest: request onResponse: aBlock 
]
