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

{ #category : 'initialization' }
DAPClientBreakpointManager >> initialize [

	super initialize.
	breakpoints := OrderedCollection new.
	functionBreakpoints := OrderedCollection new.
	dataBreakpoints := OrderedCollection new
]

{ #category : 'adding' }
DAPClientBreakpointManager >> setBreakPointsFor: aDAPClient [

	self flag: 'todo'
]

{ #category : 'adding' }
DAPClientBreakpointManager >> setDataBreakPointsFor: aDAPClient [

	self flag: 'todo'
]

{ #category : 'adding' }
DAPClientBreakpointManager >> setFunctionBreakPointsFor: aDAPClient [

	aDAPClient setFunctionBreakpoints:
		(DAPSetFunctionBreakpointsArguments new breakpoints:
			 functionBreakpoints asArray)
]
