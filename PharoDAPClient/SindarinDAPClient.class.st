Class {
	#name : 'SindarinDAPClient',
	#superclass : 'DAPClient',
	#category : 'PharoDAPClient-Model',
	#package : 'PharoDAPClient',
	#tag : 'Model'
}

{ #category : 'stack access' }
SindarinDAPClient >> currentFrame [

	^ (self
		   handleAsyncResponse: [ :response |
				   self
					   stackTrace: (DAPStackTraceArguments new
							    threadId: self mainThreadId;
							    levels: 1)
					   onResponse: response ]
		   returning: 'stackFrames') first
]

{ #category : 'stack access' }
SindarinDAPClient >> currentFrameId [

	^ self currentFrame at: 'id'
]

{ #category : 'stack access' }
SindarinDAPClient >> currentStackFrame: threadId [

	^ (self stackFrames: threadId) first
]

{ #category : 'registry' }
SindarinDAPClient >> dapRegistryAt: keyAsString put: valueAsString [

	^ self subclassResponsibility
]

{ #category : 'private' }
SindarinDAPClient >> delayForResponse [
	^ Delay forMilliseconds: 200
]

{ #category : 'evaluating' }
SindarinDAPClient >> evaluate: aString frameId: aNumber [

	^ self
		  handleAsyncResponse: [ :onResponse |
				  self
					  evaluate: (DAPEvaluateArguments new
							   context: 'repl';
							   frameId: aNumber;
							   expression: aString)
					  onResponse: onResponse ]
		  returning: 'result'
]

{ #category : 'breakpoints' }
SindarinDAPClient >> halt: objName on: aString [
	"Require supportDataBreakpoints.
	aString is write | read | readWrite"

	| frameId objRef objVars dataBreakpoints |
	self flag: 'Set replace breakpoints'.

	frameId := self currentFrameId.
	objRef := self variableReferenceFor: objName inStackFrame: frameId.
	objVars := self variablesForObject: objName inStackFrame: frameId.

	dataBreakpoints := objVars collect: [ :variable |
			                   | dataId |
			                   dataId := self
				                             handleAsyncResponse: [ :response |
						                             self
							                             dataBreakpointInfo:
								                             (DAPDataBreakpointInfoArguments
									                              new
									                              variablesReference: objRef;
									                              frameId: frameId;
									                              name: (variable at: 'name'))
							                             onResponse: response ]
				                             returning: 'dataId'.

			                   DAPDataBeakpoint new
				                   dataId: dataId;
										condition: 'true'; "TODO"
				                   accessType: aString ].

	self setDataBreakPoints:
		(DAPSetDataBreakpointsArguments new breakpoints: dataBreakpoints )
]

{ #category : 'breakpoints' }
SindarinDAPClient >> haltOnRead: objName [

	self halt: objName on: 'read'
]

{ #category : 'breakpoints' }
SindarinDAPClient >> haltOnWrite: objName [

	self halt: objName on: 'write'
]

{ #category : 'private' }
SindarinDAPClient >> handleAsyncResponse: anAction returning: key [
	"anAction is a block that takes a single argument, a block to receive the response.
    This method waits for the response, checks for errors, and returns the value at 'key' 
    inside the response body."

	| response |
	response := nil.

	anAction value: [ :resp | response := resp ].
	self delayForResponse wait.

	response ifNil: [
		^ Error new signal: 'Response timeout !' ].

	(response at: 'success') ifFalse: [
		^ Error new signal: 'Request failed !' ].

	^ (response at: 'body') at: key
]

{ #category : 'registry' }
SindarinDAPClient >> initializeDapRegistry [

	^ self subclassResponsibility
]

{ #category : 'stack access' }
SindarinDAPClient >> isExecutionFinished [

	^ (dapHistory eventsOfType: 'terminated') isNotEmpty
]

{ #category : 'stack access' }
SindarinDAPClient >> mainThreadId [
	^ 1
]

{ #category : 'stack access' }
SindarinDAPClient >> scopesForFrame: aFrameId [
	"take a valid frame id and return a collection of DAPScope"

	^ self
		  handleAsyncResponse: [ :onResponse |
				  self
					  scopes: (DAPScopesArguments new frameId: aFrameId)
					  onResponse: onResponse ]
		  returning: 'scopes'
]

{ #category : 'stack access' }
SindarinDAPClient >> stackFrames: threadId [

	^ self
		  handleAsyncResponse: [ :onResponse |
				  self
					  stackTrace: (DAPStackTraceArguments new threadId: threadId)
					  onResponse: onResponse ]
		  returning: 'stackFrames'
]

{ #category : 'stepping - steps' }
SindarinDAPClient >> stepUntil: aPredicate [
	"aPredicate is expected to be a ByteString or a BlockClosure"

	aPredicate stepUntilOn: self
]

{ #category : 'stepping - steps' }
SindarinDAPClient >> stepUntilBlock: aBlock [

	self flag: 'TODO'
]

{ #category : 'stepping - steps' }
SindarinDAPClient >> stepUntilString: aString [

	| threadId frameId bool |
	threadId := 1.
	bool := false.

	[ bool ] whileFalse: [
			frameId := (self currentStackFrame: threadId) at: 'id'.
			bool := (self evaluate: aString frameId: frameId) asLowercase
			        = 'true'.

			bool ifFalse: [
					self stepIn: (DAPStepInArguments new threadId: threadId).
					self delayForResponse wait ] ]
]

{ #category : 'stack access' }
SindarinDAPClient >> variableReferenceFor: aVariableName inStackFrame: frameId [

	| varRefScopeLocal variablesLocal |
	varRefScopeLocal := (self scopesForFrame: frameId) first at:
		                    'variablesReference'.
	variablesLocal := self variablesForReference: varRefScopeLocal.
	^ (variablesLocal detect: [ :var | (var at: 'name') = aVariableName ])
		  at: 'variablesReference'
]

{ #category : 'stack access' }
SindarinDAPClient >> variablesForObject: aVariableName inStackFrame: frameId [
	"Assumes DAP hierarchy: scopes -> variables -> variables.
	Expands locals, then the target variable, to access its attributes.
	You may need to override this method if the debug adapter introduces
	intermediate nodes or uses a different variable hierarchy."

	| varRefObject |
	varRefObject := self
		                variableReferenceFor: aVariableName
		                inStackFrame: frameId.

	^ self variablesForReference: (varRefObject)
]

{ #category : 'stack access' }
SindarinDAPClient >> variablesForReference: aVarRef [

	"take a valid variable reference and return a collection of DAPVariables"

	^ self
		  handleAsyncResponse: [ :onResponse |
				  self
					  variables:
					  (DAPVariablesArguments new variablesReference: aVarRef)
					  onResponse: onResponse ]
		  returning: 'variables'
]
