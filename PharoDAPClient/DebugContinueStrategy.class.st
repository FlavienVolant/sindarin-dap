Class {
	#name : 'DebugContinueStrategy',
	#superclass : 'AbstractContinueStrategy',
	#category : 'PharoDAPClient-Model',
	#package : 'PharoDAPClient',
	#tag : 'Model'
}

{ #category : 'requests' }
DebugContinueStrategy >> continue: sindarinDAPClient [

	sindarinDAPClient continue:
		(DAPContinueArguments new threadId: sindarinDAPClient mainThreadId)
]
