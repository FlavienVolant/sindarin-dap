Class {
	#name : 'DAPClientBreakpointManager',
	#superclass : 'Object',
	#instVars : [
		'breakpoints',
		'functionBreakpoints',
		'dataBreakpoints'
	],
	#category : 'PharoDAPClient-Model',
	#package : 'PharoDAPClient',
	#tag : 'Model'
}

{ #category : 'adding' }
DAPClientBreakpointManager >> addBreakpoint: aDAPBreakpoint [

	breakpoints add: aDAPBreakpoint
]

{ #category : 'adding' }
DAPClientBreakpointManager >> addDataBreakpoint: aDAPDataBreakpoint [

	dataBreakpoints add: aDAPDataBreakpoint
]

{ #category : 'adding' }
DAPClientBreakpointManager >> addFunctionBreakpoint: aDAPFunctionBreakpoint [

	functionBreakpoints add: aDAPFunctionBreakpoint
]

{ #category : 'helpers' }
DAPClientBreakpointManager >> extractFunctionName: aString [

	^ (aString findTokens: '.') last
]

{ #category : 'initialization' }
DAPClientBreakpointManager >> initialize [

	super initialize.
	breakpoints := OrderedCollection new.
	functionBreakpoints := OrderedCollection new.
	dataBreakpoints := OrderedCollection new
]

{ #category : 'helpers' }
DAPClientBreakpointManager >> normalizeFrameName: aString [

	| cleaned index |
	cleaned := aString.

	"remove JS file suffix [file]"
	index := cleaned indexOf: $[.
	index > 0 ifTrue: [ cleaned := cleaned copyFrom: 1 to: index - 1 ].

	cleaned := cleaned trimmed.

	"remove Java params (type)"
	index := cleaned indexOf: $(.
	index > 0 ifTrue: [ cleaned := cleaned copyFrom: 1 to: index - 1 ].

	^ cleaned trimmed
]

{ #category : 'adding' }
DAPClientBreakpointManager >> setBreakPointsFor: aDAPClient [

	self flag: 'todo'
]

{ #category : 'adding' }
DAPClientBreakpointManager >> setDataBreakPointsFor: aDAPClient [

	aDAPClient setDataBreakPoints:
		(DAPSetDataBreakpointsArguments new breakpoints:
			 dataBreakpoints asArray)
]

{ #category : 'adding' }
DAPClientBreakpointManager >> setFunctionBreakPointsFor: aDAPClient [

	aDAPClient setFunctionBreakpoints:
		(DAPSetFunctionBreakpointsArguments new breakpoints:
			 functionBreakpoints asArray)
]

{ #category : 'asserting' }
DAPClientBreakpointManager >> shouldBreakFor: aDAPStackFrame [

	| functionName |
	self deprecated: 'Use shouldBreakFor:evaluator:'.

	functionName := self extractFunctionName:
		                (self normalizeFrameName:
			                 (aDAPStackFrame at: 'name')).

	^ functionBreakpoints anySatisfy: [ :breakpoint |
		  breakpoint name = functionName ]
]

{ #category : 'asserting' }
DAPClientBreakpointManager >> shouldBreakFor: aDAPStackFrame evaluator: clientDAP [

	| functionName |
	functionName := self extractFunctionName:
		                (self normalizeFrameName:
			                 (aDAPStackFrame at: 'name')).

	^ functionBreakpoints anySatisfy: [ :breakpoint |
			  breakpoint name = functionName and: [
					  clientDAP
						  evaluate: breakpoint condition
						  frameId: (aDAPStackFrame at: 'id') ] ]
]
