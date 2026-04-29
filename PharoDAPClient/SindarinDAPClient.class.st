Class {
	#name : 'SindarinDAPClient',
	#superclass : 'DAPClient',
	#instVars : [
		'backend',
		'breakpointManager',
		'continueStrategy'
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

{ #category : 'accessing' }
SindarinDAPClient >> breakpointManager [

	^ breakpointManager
]

{ #category : 'stepping - steps' }
SindarinDAPClient >> continue [

	continueStrategy := StepUntilStrategy new.
	continueStrategy continue: self
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

{ #category : 'evaluating' }
SindarinDAPClient >> evaluateBoolean: aString frameId: aNumber [

	| resp |
	resp := self evaluate: aString frameId: aNumber.

	^ (resp at: 'result') asLowercase = 'true'
]

{ #category : 'api - breakpoints' }
SindarinDAPClient >> haltOn: objName message: msgName [

	self
		helperAddFunctionBreakpointName: msgName
		condition: (backend buildInstanceCondition: objName).

	breakpointManager setFunctionBreakPointsFor: self
]

{ #category : 'api - breakpoints' }
SindarinDAPClient >> haltOnCalls: objName [

	(backend methodsOf: objName) do: [ :methodName |
			self
				helperAddFunctionBreakpointName: methodName withoutQuoting
				condition: (backend buildInstanceCondition: objName) ].

	breakpointManager setFunctionBreakPointsFor: self
]

{ #category : 'api - breakpoints' }
SindarinDAPClient >> haltOnCreation: className [

	(backend constructorsOf: className) do: [ :constructorName |
			self
				helperAddFunctionBreakpointName: constructorName withoutQuoting
				condition:
				(backend expressionKey: backend instanceName instanceOf: className) ].

	breakpointManager setFunctionBreakPointsFor: self
]

{ #category : 'api - breakpoints' }
SindarinDAPClient >> haltOnRead: objName [

	self setBreakOnAllAttributesOf: objName mode: 'read'
]

{ #category : 'api - breakpoints' }
SindarinDAPClient >> haltOnRead: objName attribute: attrName [

	self setBreakOn: objName attribute: attrName mode: 'read'
]

{ #category : 'api - breakpoints' }
SindarinDAPClient >> haltOnWrite: objName [

	self setBreakOnAllAttributesOf: objName mode: 'write'
]

{ #category : 'api - breakpoints' }
SindarinDAPClient >> haltOnWrite: objName attribute: attrName [

	self setBreakOn: objName attribute: attrName mode: 'write'
]

{ #category : 'private' }
SindarinDAPClient >> handleAsyncRawResponse: anAction [
    | response |

    response := nil.

    anAction value: [ :resp | response := resp ].

    [ response ] whileNil: [ (Delay forMilliseconds: 10) wait ].

    ^ response
]

{ #category : 'private' }
SindarinDAPClient >> handleAsyncResponse: anAction [
	"anAction is a block that takes a single argument, a block to receive the response.
    This method waits for the response, checks for errors, and returns the response body."

	| response |
	response := self handleAsyncRawResponse: anAction.

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

{ #category : 'private - breakpoints' }
SindarinDAPClient >> helperAddDataBreakpointInfo: aDataBreakpointInfo breakpoint: aDataBreakpoint [
	"expect breakpointInfo to be setup and aDataBreakpoint setup without the dataId wich is return by breakpointInfo"

	aDataBreakpoint dataId: (self
			 handleAsyncResponse: [ :response |
				 self dataBreakpointInfo: aDataBreakpointInfo onResponse: response ]
			 returning: 'dataId').
	
	"give breakpoint info if dataId has a lifetime ?"
	"seems to work maybe it's adapter dependent"
	
	breakpointManager addDataBreakpoint: aDataBreakpoint
]

{ #category : 'private - breakpoints' }
SindarinDAPClient >> helperAddFunctionBreakpointName: functionName condition: aString [

	breakpointManager addFunctionBreakpoint: (DAPFunctionBreakpoint new
			 name: functionName;
			 condition: aString)
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

{ #category : 'private - breakpoints' }
SindarinDAPClient >> setBreakOn: objName attribute: attrName mode: aString [
	"aString is 'write' | 'read' | 'readWrite'"

	| frameId objRef |
	(self adapterSupport: 'supportsDataBreakpoints') ifFalse: [ ^ self ].

	frameId := self currentFrameId.
	objRef := self variableReferenceFor: objName inStackFrame: frameId.

	self
		helperAddDataBreakpointInfo: (DAPDataBreakpointInfoArguments new
				 variablesReference: objRef;
				 frameId: frameId;
				 name: attrName)
		breakpoint: (DAPDataBreakpoint new
				 condition: (self backend buildInstanceCondition: objName);
				 accessType: aString).

	breakpointManager setDataBreakPointsFor: self
]

{ #category : 'private - breakpoints' }
SindarinDAPClient >> setBreakOnAllAttributesOf: objName mode: aString [
	"aString is write | read | readWrite"

	| frameId objRef objVars |
	(self adapterSupport: 'supportsDataBreakpoints') ifFalse: [ ^ self ].

	frameId := self currentFrameId.
	objRef := self variableReferenceFor: objName inStackFrame: frameId.
	objVars := self variablesForObject: objName inStackFrame: frameId.

	objVars do: [ :variable |
			self
				helperAddDataBreakpointInfo: (DAPDataBreakpointInfoArguments new
						 variablesReference: objRef;
						 frameId: frameId;
						 name: (variable at: 'name'))
				breakpoint: (DAPDataBreakpoint new
						 condition: (self backend buildInstanceCondition: objName);
						 accessType: aString) ].

	breakpointManager setDataBreakPointsFor: self
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

	[ self isExecutionFinished or: [ aBlock value ] ] whileFalse: [
			self handleAsyncRawResponse: [ :resp |
					self
						stepIn: (DAPStepInArguments new
								 threadId: self mainThreadId;
								 yourself)
						onResponse: resp ] ]
]

{ #category : 'stepping - steps' }
SindarinDAPClient >> stepUntilString: aString [

	[
		self isExecutionFinished or: [
			self evaluateBoolean: aString frameId: self currentFrameId ] ]
		whileFalse: [
				self handleAsyncRawResponse: [ :resp |
						self
							stepIn: (DAPStepInArguments new
									 threadId: self mainThreadId;
									 yourself)
							onResponse: resp ] ]
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
