Class {
	#name : 'DAPClientBreakpointManagerTest',
	#superclass : 'TestCase',
	#instVars : [
		'bpManger',
		'evaluatorTrue',
		'evaluatorFalse'
	],
	#category : 'PharoDAPClient-Tests',
	#package : 'PharoDAPClient-Tests'
}

{ #category : 'running' }
DAPClientBreakpointManagerTest >> setUp [

	super setUp.

	bpManger := DAPClientBreakpointManager new.

	evaluatorTrue := Mock new.
	(evaluatorTrue stub evaluate: Any frameId: Any) willReturn: true.

	evaluatorFalse := Mock new.
	(evaluatorFalse stub evaluate: Any frameId: Any) willReturn: false
]

{ #category : 'tests' }
DAPClientBreakpointManagerTest >> testShouldBreakForFunctionBreakpointFromDebugJAVA [

	| frame |
	bpManger addFunctionBreakpoint:
		(DAPFunctionBreakpoint new name: 'setStr').

	frame := {
		         ('source' -> {
			          ('name' -> 'Bar.java').
			          ('path' -> 'path/to/java/file.java').
			          ('sourceReference' -> 0) } asDictionary).
		         ('line' -> 23).
		         ('column' -> 1).
		         ('name' -> 'Bar.setStr(String)').
		         ('id' -> 1) } asDictionary.

	self assert:
		(bpManger shouldBreakFor: frame evaluator: evaluatorTrue)
]

{ #category : 'tests' }
DAPClientBreakpointManagerTest >> testShouldBreakForFunctionBreakpointFromDebugJS [

	| frame |
	bpManger addFunctionBreakpoint:
		(DAPFunctionBreakpoint new name: 'toto').

	frame := {
		         ('source' -> {
			          ('name' -> 'path/to/js/file.js').
			          ('path' -> 'path/to/js/file.js').
			          ('sourceReference' -> 0) } asDictionary).
		         ('presentationHint' -> 'normal').
		         ('line' -> 7).
		         ('column' -> 9).
		         ('name'
		          ->
		          'Bar.toto [/Users/flavienvolant/Documents/sindarin-dap/js/script.js]').
		         ('id' -> 61) } asDictionary.

	self assert:
		(bpManger shouldBreakFor: frame evaluator: evaluatorTrue)
]

{ #category : 'tests' }
DAPClientBreakpointManagerTest >> testShouldBreakForFunctionBreakpointFromDebugPY [

	| frame |
	bpManger addFunctionBreakpoint:
		(DAPFunctionBreakpoint new name: 'setStr').
	
	frame := {
		         ('source' -> {
			          ('path' -> 'path/to/python/file.py').
			          ('sourceReference' -> 0) } asDictionary).
		         ('line' -> 3).
		         ('column' -> 1).
		         ('name' -> 'bar.setStr').
		         ('id' -> 4) } asDictionary.

	self assert: (bpManger shouldBreakFor: frame evaluator: evaluatorTrue )
]

{ #category : 'tests' }
DAPClientBreakpointManagerTest >> testShouldBreakWhenAtLeastOneFunctionBreakpointMatches [

	| frame |
	bpManger addFunctionBreakpoint:
		(DAPFunctionBreakpoint new name: 'toto').
	bpManger addFunctionBreakpoint:
		(DAPFunctionBreakpoint new name: 'thisIsNottoto').

	frame := {
		         ('source' -> {
			          ('path' -> 'path/to/python/file.py').
			          ('sourceReference' -> 0) } asDictionary).
		         ('line' -> 3).
		         ('column' -> 1).
		         ('name' -> 'bar.thisIsNottoto').
		         ('id' -> 4) } asDictionary.

	self assert:
		(bpManger shouldBreakFor: frame evaluator: evaluatorTrue)
]

{ #category : 'tests' }
DAPClientBreakpointManagerTest >> testShouldBreakWhenFunctionbreakpointConditionIsTrue [

	| frame |
	bpManger addFunctionBreakpoint: (DAPFunctionBreakpoint new
			 name: 'toto';
			 condition: 'true').

	frame := {
		         ('source' -> {
			          ('path' -> 'path/to/python/file.py').
			          ('sourceReference' -> 0) } asDictionary).
		         ('line' -> 3).
		         ('column' -> 1).
		         ('name' -> 'bar.toto').
		         ('id' -> 4) } asDictionary.

	self assert:
		(bpManger shouldBreakFor: frame evaluator: evaluatorTrue)
]

{ #category : 'tests' }
DAPClientBreakpointManagerTest >> testShouldNotBreakWhenFunctionNameDoesNotMatchBreakpoint [

	| frame |
	bpManger addFunctionBreakpoint:
		(DAPFunctionBreakpoint new name: 'toto').
	bpManger addFunctionBreakpoint:
		(DAPFunctionBreakpoint new name: 'tata').

	frame := {
		         ('source' -> {
			          ('path' -> 'path/to/python/file.py').
			          ('sourceReference' -> 0) } asDictionary).
		         ('line' -> 3).
		         ('column' -> 1).
		         ('name' -> 'bar.setStr').
		         ('id' -> 4) } asDictionary.

	self deny: (bpManger shouldBreakFor: frame evaluator: evaluatorTrue)
]

{ #category : 'tests' }
DAPClientBreakpointManagerTest >> testShouldNotBreakWhenFunctionbreakpointConditionIsFalse [

	| frame |
	bpManger := DAPClientBreakpointManager new.
	bpManger addFunctionBreakpoint: (DAPFunctionBreakpoint new
			 name: 'toto';
			 condition: 'false').

	frame := {
		         ('source' -> {
			          ('path' -> 'path/to/python/file.py').
			          ('sourceReference' -> 0) } asDictionary).
		         ('line' -> 3).
		         ('column' -> 1).
		         ('name' -> 'bar.toto').
		         ('id' -> 4) } asDictionary.

	self deny: (bpManger shouldBreakFor: frame evaluator: evaluatorFalse)
]

{ #category : 'tests' }
DAPClientBreakpointManagerTest >> testShouldNotMatchPartialFunctionNameToBreakpoint [

	| frame |
	bpManger addFunctionBreakpoint:
		(DAPFunctionBreakpoint new name: 'toto').

	frame := {
		         ('source' -> {
			          ('path' -> 'path/to/python/file.py').
			          ('sourceReference' -> 0) } asDictionary).
		         ('line' -> 3).
		         ('column' -> 1).
		         ('name' -> 'bar.thisIsNottoto').
		         ('id' -> 4) } asDictionary.

	self deny: (bpManger shouldBreakFor: frame evaluator: evaluatorTrue)
]
