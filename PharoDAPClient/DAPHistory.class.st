Class {
	#name : 'DAPHistory',
	#superclass : 'Object',
	#instVars : [
		'requests',
		'responses',
		'events',
		'observers'
	],
	#category : 'PharoDAPClient-Model',
	#package : 'PharoDAPClient',
	#tag : 'Model'
}

{ #category : 'accessing' }
DAPHistory >> addEvent: eventAsDict [
	
	eventAsDict at: #timestamp put: DateAndTime now.
	events add: eventAsDict.
	self notifyObserversEvent: eventAsDict
]

{ #category : 'observers' }
DAPHistory >> addObserver: aDAPObserver [
	"Observer are expected to implement the DAPObserver trait"

	observers add: aDAPObserver
]

{ #category : 'accessing' }
DAPHistory >> addRequest: requestAsDict [

	requestAsDict at: #timestamp put: DateAndTime now.
	requests add: requestAsDict.
	self notifyObserversRequest: requestAsDict
]

{ #category : 'accessing' }
DAPHistory >> addResponse: responseAsDict [
	
	responseAsDict at: #timestamp put: DateAndTime now.
	responses add: responseAsDict.
	self notifyObserversResponse: responseAsDict
]

{ #category : 'accessing' }
DAPHistory >> events [
	^ events 
]

{ #category : 'initialization' }
DAPHistory >> initialize [

	requests := OrderedCollection new.
	responses := OrderedCollection new.
	events := OrderedCollection new.
	
	observers := OrderedCollection new.
]

{ #category : 'accessing' }
DAPHistory >> messages [

	| all |
	all := requests , events , responses.

	^ all sort: [ :a :b |
			  | tA tB |
			  tA := a at: #timestamp ifAbsent: [ DateAndTime now ].
			  tB := b at: #timestamp ifAbsent: [ DateAndTime now ].
			  tA <= tB ]
]

{ #category : 'observers' }
DAPHistory >> notifyObserversEvent: aDAPEvent [
	observers do: [ :obs | obs updateWithEvent: aDAPEvent ]
]

{ #category : 'observers' }
DAPHistory >> notifyObserversRequest: aDAPRequest [

	observers do: [ :obs | obs updateWithRequest: aDAPRequest ]
]

{ #category : 'observers' }
DAPHistory >> notifyObserversResponse: aDAPResponse [

	observers do: [ :obs | obs updateWithResponse: aDAPResponse ]
]

{ #category : 'observers' }
DAPHistory >> removeObserver: anObserver [

	observers remove: anObserver
]

{ #category : 'accessing' }
DAPHistory >> request: requestSeq [

	^ requests
		  detect: [ :each | (each at: #seq) = requestSeq ]
		  ifNone: [ nil ]
]

{ #category : 'accessing' }
DAPHistory >> requests [
	^ requests 
]

{ #category : 'accessing' }
DAPHistory >> responseForRequest: requestSeq [

	^ responses
		  detect: [ :each | (each at: #request_seq) = requestSeq ]
		  ifNone: [ nil ]
]

{ #category : 'accessing' }
DAPHistory >> responses [
	^ responses 
]
