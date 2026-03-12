Trait {
	#name : 'DAPObserver',
	#category : 'PharoDAPClient-Model',
	#package : 'PharoDAPClient',
	#tag : 'Model'
}

{ #category : 'event handling' }
DAPObserver >> updateWithEvent: aDAPRequest [
	^ self subclassResponsibility 
]

{ #category : 'event handling' }
DAPObserver >> updateWithRequest: aDAPRequest [
	^ self subclassResponsibility 
]

{ #category : 'event handling' }
DAPObserver >> updateWithResponse: aDAPResponse [
	^ self subclassResponsibility 
]
