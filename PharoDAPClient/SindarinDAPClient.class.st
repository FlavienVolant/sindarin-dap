Class {
	#name : 'SindarinDAPClient',
	#superclass : 'DAPClient',
	#instVars : [
		'backend',
		'breakpointManager'
	],
	#category : 'PharoDAPClient-Model',
	#package : 'PharoDAPClient',
	#tag : 'Model'
}

{ #category : 'accessing' }
SindarinDAPClient >> backend [

	^ backend
]

{ #category : 'accessing' }
SindarinDAPClient >> backend: aDAPBackend [

	backend := aDAPBackend.
	backend clientDAP: self
]

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
]

{ #category : 'breakpoints' }
SindarinDAPClient >> haltOn: objName message: msgName [

	breakpointManager addFunctionBreakpoint: (DAPFunctionBreakpoint new
			 name: msgName;
			 condition: (backend buildInstanceCondition: objName)).

	breakpointManager setFunctionBreakPointsFor: self
]

{ #category : 'breakpoints' }
SindarinDAPClient >> haltOnCalls: objName [

	(backend methodsOf: objName) do: [ :methodName |
			breakpointManager addFunctionBreakpoint:
				(DAPFunctionBreakpoint new
					 name: methodName withoutQuoting;
					 condition: (backend buildInstanceCondition: objName)) ].

	breakpointManager setFunctionBreakPointsFor: self
]

{ #category : 'breakpoints' }
SindarinDAPClient >> haltOnCreation: className [

	(backend constructorsOf: className) do: [ :constructorName |
			breakpointManager addFunctionBreakpoint:
				(DAPFunctionBreakpoint new
					 name: constructorName withoutQuoting;
					 condition:
						 (backend
							  expressionKey: backend instanceName
							  instanceOf: className)) ].

	breakpointManager setFunctionBreakPointsFor: self
]

{ #category : 'breakpoints' }
SindarinDAPClient >> haltOnRead: objName [

	self setBreakOnAllAttributesOf: objName mode: 'read'
]

{ #category : 'breakpoints' }
SindarinDAPClient >> haltOnRead: objName attribute: attrName [

	self setBreakOn: objName attribute: attrName mode: 'read'
]

{ #category : 'breakpoints' }
SindarinDAPClient >> haltOnWrite: objName [

	self setBreakOnAllAttributesOf: objName mode: 'write'
]

{ #category : 'breakpoints' }
SindarinDAPClient >> haltOnWrite: objName attribute: attrName [

	self setBreakOn: objName attribute: attrName mode: 'write'
]

{ #category : 'private' }
SindarinDAPClient >> handleAsyncResponse: anAction [
	"anAction is a block that takes a single argument, a block to receive the response.
    This method waits for the response, checks for errors, and returns the response body."

	| response |
	response := nil.

	anAction value: [ :resp | response := resp ].
	self delayForResponse wait.

	response ifNil: [ ^ Error new signal: 'Response timeout !' ].

	(response at: 'success') ifFalse: [
		^ Error new signal: 'Request failed !' ].

	^ response at: 'body'
]

{ #category : 'private' }
SindarinDAPClient >> handleAsyncResponse: anAction returning: key [
	"anAction is a block that takes a single argument, a block to receive the response.
    This method waits for the response, checks for errors, and returns the value at 'key' 
    inside the response body."

	^ (self handleAsyncResponse: anAction) at: key
]

{ #category : 'initialization' }
SindarinDAPClient >> initialize [

	super initialize.
	breakpointManager := DAPClientBreakpointManager new
]

{ #category : 'initialization' }
SindarinDAPClient >> initializeDapRegistry [

	backend initializeRegistry
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

{ #category : 'breakpoints' }
SindarinDAPClient >> setBreakOn: objName attribute: attrName mode: aString [
	"Require supportDataBreakpoints.
	aString is write | read | readWrite"

	| frameId objRef dataBreakpoints dataId |
	self flag: 'Set replace breakpoints'.

	frameId := self currentFrameId.
	objRef := self variableReferenceFor: objName inStackFrame: frameId.

	dataId := self
		          handleAsyncResponse: [ :response |
				          self
					          dataBreakpointInfo:
						          (DAPDataBreakpointInfoArguments new
							           variablesReference: objRef;
							           frameId: frameId;
							           name: attrName)
					          onResponse: response ]
		          returning: 'dataId'.

	dataBreakpoints := { (DAPDataBreakpoint new
		                    dataId: dataId;
		                    condition:
			                    (self backend buildInstanceCondition: objName);
		                    accessType: aString) }.

	self setDataBreakPoints:
		(DAPSetDataBreakpointsArguments new breakpoints: dataBreakpoints)
]

{ #category : 'breakpoints' }
SindarinDAPClient >> setBreakOnAllAttributesOf: objName mode: aString [
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

			                   DAPDataBreakpoint new
				                   dataId: dataId;
				                   condition:
					                   (self backend buildInstanceCondition: objName);
				                   accessType: aString ].

	self setDataBreakPoints:
		(DAPSetDataBreakpointsArguments new breakpoints: dataBreakpoints)
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
			bool := ((self evaluate: aString frameId: frameId) at: 'result')
				        asLowercase = 'true'.

			bool ifFalse: [
					self stepIn: (DAPStepInArguments new threadId: threadId).
					self delayForResponse wait ] ]
]

{ #category : 'stack access' }
SindarinDAPClient >> variableReferenceFor: aVariableName inStackFrame: frameId [

	"return the dap variable reference for aVariableName in the frameId stack frame"

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
	intermediate nodes or uses a different variable hierarchy.
	
	Return a collection of DAPVariables
	"

	| varRefObject |
	varRefObject := self
		                variableReferenceFor: aVariableName
		                inStackFrame: frameId.

	^ self variablesForReference: varRefObject
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
