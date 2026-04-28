Class {
	#name : 'StepUntilStrategy',
	#superclass : 'AbstractContinueStrategy',
	#category : 'PharoDAPClient-Model',
	#package : 'PharoDAPClient',
	#tag : 'Model'
}

{ #category : 'requests' }
StepUntilStrategy >> continue: sindarinDAPClient [
	"work in progress for function bp only"

	sindarinDAPClient stepUntil: [
			sindarinDAPClient breakpointManager shouldBreakFor:
				sindarinDAPClient currentFrame ]
]
