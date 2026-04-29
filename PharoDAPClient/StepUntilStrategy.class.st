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
			| currentFrame oldStackSize newStackSize |
			oldStackSize := (sindarinDAPClient dapHistory
				                 lastResponseForCommand: 'stackTrace')
				                at: 'body'
				                at: 'totalFrames'.
			currentFrame := sindarinDAPClient currentFrame.
			newStackSize := (sindarinDAPClient dapHistory
				                 lastResponseForCommand: 'stackTrace')
				                at: 'body'
				                at: 'totalFrames'.

			oldStackSize < newStackSize and: [
					sindarinDAPClient breakpointManager
						shouldBreakFor: currentFrame
						evaluator: sindarinDAPClient ] ]
]
