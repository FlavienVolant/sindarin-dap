Class {
	#name : 'SindarinDAPClient',
	#superclass : 'DAPClient',
	#category : 'PharoDAPClient-Model',
	#package : 'PharoDAPClient',
	#tag : 'Model'
}

{ #category : 'accessing' }
SindarinDAPClient >> currentStackFrame: threadId [

	^ (self stackFrames: threadId) first
]

{ #category : 'private' }
SindarinDAPClient >> delayForResponse [
	^ Delay forMilliseconds: 100
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
		^ Error new signal: 'StackTrace response timeout !' ].

	(response at: 'success') ifFalse: [
		^ Error new signal: 'StackTrace request failed !' ].

	^ (response at: 'body') at: key
]

{ #category : 'accessing' }
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

	| threadId frameId bool |
	threadId := 1.
	bool := false.

	[ bool ] whileFalse: [
			frameId := (self currentStackFrame: threadId) at: 'id'.
			bool := (self evaluate: aPredicate frameId: frameId) asLowercase
			        = 'true'.

			bool ifFalse: [
					self stepIn: (DAPStepInArguments new threadId: threadId).
					self delayForResponse wait ] ]
]
