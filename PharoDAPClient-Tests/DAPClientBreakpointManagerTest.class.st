Class {
	#name : 'DAPClientBreakpointManagerTest',
	#superclass : 'TestCase',
	#category : 'PharoDAPClient-Tests',
	#package : 'PharoDAPClient-Tests'
}

{ #category : 'tests' }
DAPClientBreakpointManagerTest >> testShouldBreakForFunctionBreakpointFromDebugJAVA [

	| bpManger frame |
	bpManger := DAPClientBreakpointManager new.
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

	self assert: (bpManger shouldBreakFor: frame)
]

{ #category : 'tests' }
DAPClientBreakpointManagerTest >> testShouldBreakForFunctionBreakpointFromDebugJS [

	| bpManger frame |
	bpManger := DAPClientBreakpointManager new.
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

	self assert: (bpManger shouldBreakFor: frame)
]

{ #category : 'tests' }
DAPClientBreakpointManagerTest >> testShouldBreakForFunctionBreakpointFromDebugPY [

	| bpManger frame |
	bpManger := DAPClientBreakpointManager new.
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

	self assert: (bpManger shouldBreakFor: frame)
]

{ #category : 'tests' }
DAPClientBreakpointManagerTest >> testShouldBreakWhenAtLeastOneFunctionBreakpointMatches [

	| bpManger frame |
	bpManger := DAPClientBreakpointManager new.
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

	self assert: (bpManger shouldBreakFor: frame)
]

{ #category : 'tests' }
DAPClientBreakpointManagerTest >> testShouldBreakWhenFunctionbreakpointConditionIsTrue [

	| bpManger evaluator frame |
	bpManger := DAPClientBreakpointManager new.
	bpManger addFunctionBreakpoint: (DAPFunctionBreakpoint new
			 name: 'toto';
			 condition: 'true').

	evaluator := Mock new.
	(evaluator stub evaluate: Any frameId: Any) willReturn: true.

	frame := {
		         ('source' -> {
			          ('path' -> 'path/to/python/file.py').
			          ('sourceReference' -> 0) } asDictionary).
		         ('line' -> 3).
		         ('column' -> 1).
		         ('name' -> 'bar.toto').
		         ('id' -> 4) } asDictionary.

	self assert: (bpManger shouldBreakFor: frame evaluator: evaluator)
]

{ #category : 'tests' }
DAPClientBreakpointManagerTest >> testShouldNotBreakWhenFunctionNameDoesNotMatchBreakpoint [

	| bpManger frame |
	bpManger := DAPClientBreakpointManager new.
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

	self deny: (bpManger shouldBreakFor: frame)
]

{ #category : 'tests' }
DAPClientBreakpointManagerTest >> testShouldNotBreakWhenFunctionbreakpointConditionIsFalse [

	| bpManger evaluator frame |
	bpManger := DAPClientBreakpointManager new.
	bpManger addFunctionBreakpoint: (DAPFunctionBreakpoint new
			 name: 'toto';
			 condition: 'false').

	evaluator := Mock new.
	(evaluator stub evaluate: Any frameId: Any) willReturn: false.

	frame := {
		         ('source' -> {
			          ('path' -> 'path/to/python/file.py').
			          ('sourceReference' -> 0) } asDictionary).
		         ('line' -> 3).
		         ('column' -> 1).
		         ('name' -> 'bar.toto').
		         ('id' -> 4) } asDictionary.

	self deny: (bpManger shouldBreakFor: frame evaluator: evaluator)
]

{ #category : 'tests' }
DAPClientBreakpointManagerTest >> testShouldNotMatchPartialFunctionNameToBreakpoint [

	| bpManger frame |
	bpManger := DAPClientBreakpointManager new.
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

	self deny: (bpManger shouldBreakFor: frame)
]
