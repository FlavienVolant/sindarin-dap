Class {
	#name : 'DAPClient',
	#superclass : 'Object',
	#instVars : [
		'socket',
		'host',
		'port',
		'seq',
		'buffer',
		'listenerProcess',
		'eventHandlers',
		'responseHandlers',
		'dapHistory'
	],
	#category : 'PharoDAPClient-Model',
	#package : 'PharoDAPClient',
	#tag : 'Model'
}

{ #category : 'connection open/close' }
DAPClient >> closeConnection [

	listenerProcess ifNotNil: [
			listenerProcess terminate.
			listenerProcess := nil ].

	socket ifNotNil: [
			socket close.
			socket := nil ]
]

{ #category : 'connection open/close' }
DAPClient >> connectTo: aHostName port: aPort [

	host := aHostName.
	port := aPort.
	socket := SocketStream
		          openConnectionToHostNamed: aHostName
		          port: aPort.
	socket noTimeout
]

{ #category : 'accessing' }
DAPClient >> dapHistory [

	^ dapHistory
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
]

{ #category : 'initialization' }
DAPClient >> onEvent: eventName do: block [
	eventHandlers at: eventName put: block 
]

{ #category : 'communication' }
DAPClient >> readHeadersAsDict [

	| dict line |
	Transcript showCr: '--- READING HEADER ---'.

	dict := Dictionary new.

	[
		| key value |
		line := socket nextLineCrLf.
		line ifNil: [ ^ nil ].

		line isEmpty ifTrue: [
				Transcript showCr: '--- END HEADER ---'.
				^ dict ].
		Transcript showCr: line asString.
		
		key := (line asString copyUpTo: $:) asLowercase.
		value := (line asString copyAfter: $:) trimBoth.
		dict at: key put: value 
	] repeat
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

	Transcript showCr: '>>> Start Send'.
	Transcript showCr:
		header , (STONJSON toStringPretty: aDAPRequest asDAPJSON).
	Transcript showCr: '>>> End Send'.

	socket nextPutAll: header asByteArray.
	socket nextPutAll: bytes.
	socket flush
]

{ #category : 'communication' }
DAPClient >> startListening [

	listenerProcess := [
		[
			| json |
			json := self readMessageAsDict.
			Transcript showCr: (STONJSON toStringPretty: json).
			
			(json at: #type) = 'event' ifTrue: [ self handleEvent: json ].
			(json at: #type) = 'response' ifTrue: [ self handleResponse: json ].

		] repeat 
	] fork
]
