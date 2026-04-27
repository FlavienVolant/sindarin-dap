Class {
	#name : 'DAPHistoryTest',
	#superclass : 'TestCase',
	#category : 'PharoDAPClient-Tests',
	#package : 'PharoDAPClient-Tests'
}

{ #category : 'tests' }
DAPHistoryTest >> testEventsOfTypeReturnACollectionOfEventBasedOnTheirType [

	| history breakpoints stopped continued |
	history := DAPHistory new.

	1 to: 5 do: [ :i |
			history addEvent: DAPBreakpointEvent new asDAPJSON.
			history addEvent: DAPStoppedEvent new asDAPJSON.
			history addEvent: DAPContinuedEvent new asDAPJSON ].

	breakpoints := history eventsOfType: 'breakpoint'.
	stopped := history eventsOfType: 'stopped'.
	continued := history eventsOfType: 'continued'.

	"Vérifie le nombre"
	self assert: breakpoints size equals: 5.
	self assert: stopped size equals: 5.
	self assert: continued size equals: 5.

	"Vérifie le type"
	breakpoints do: [ :e |
		self assert: (e at: 'event') equals: 'breakpoint' ].

	stopped do: [ :e | self assert: (e at: 'event') equals: 'stopped' ].

	continued do: [ :e |
		self assert: (e at: 'event') equals: 'continued' ]
]

{ #category : 'tests' }
DAPHistoryTest >> testMessagesShouldReturnInReverseChronologicalOrder [

	| history seq |
	history := DAPHistory new.
	seq := 1.

	1 to: 5 do: [ :_ |
			history addRequest: (DAPStackTraceRequest new
					 seq: seq;
					 asDAPJSON).
			seq := seq + 1.

			history addEvent: (DAPAttachEvent new
					 seq: seq;
					 asDAPJSON).
			seq := seq + 1 ].

	history addResponse: (DAPErrorResponse new
			 seq: seq;
			 asDAPJSON).

	history messages withIndexDo: [ :msg :index |
			| expected |
			expected := history messages size - index + 1.
			self assert: (msg at: 'seq') equals: expected ]
]

{ #category : 'tests' }
DAPHistoryTest >> testResponseForRequestReturnNilIfNoCorrespondingResponseExist [

	| history request |
	history := DAPHistory new.
	request := DAPStackTraceRequest new
		           seq: 3;
		           asDAPJSON.
	history addRequest: request.

	self assert: (history responseForRequest: 3) identicalTo: nil
]

{ #category : 'tests' }
DAPHistoryTest >> testResponseForRequestReturnTheCorrespondingResponseToARequestSequence [

	| history request response |
	history := DAPHistory new.
	request := DAPStackTraceRequest new
		           seq: 3;
		           asDAPJSON.
	response := DAPStackTraceResponse new
		            request_seq: 3;
		            asDAPJSON.
	history addRequest: request.
	history addResponse: response.

	self assert: (history responseForRequest: 3) identicalTo: response
]
