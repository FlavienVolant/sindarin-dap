Class {
	#name : 'PendingRequest',
	#superclass : 'Object',
	#instVars : [
		'requestSymbole',
		'arguments',
		'requiredSate',
		'executed'
	],
	#category : 'PharoDAPClient-Model',
	#package : 'PharoDAPClient',
	#tag : 'Model'
}

{ #category : 'initialization' }
PendingRequest class >> request: symbole arguments: args requiredState: state [

	^ self new
		  requestSymbole: symbole;
		  arguments: args;
		  requiredSate: state;
		  yourself
]

{ #category : 'accessing' }
PendingRequest >> arguments [

	^ arguments
]

{ #category : 'accessing' }
PendingRequest >> arguments: anObject [

	arguments := anObject
]

{ #category : 'testing' }
PendingRequest >> canExecute: clientState [

	^ requiredSate = clientState & executed not
]

{ #category : 'executing' }
PendingRequest >> execute [
	
]

{ #category : 'executing' }
PendingRequest >> execute: dapClient [

	executed := true.
	arguments
		ifNil: [ dapClient perform: requestSymbole ]
		ifNotNil: [
		dapClient perform: requestSymbole withArguments: { arguments } ]
]

{ #category : 'initialization' }
PendingRequest >> initialize [

	executed := false
]

{ #category : 'accessing' }
PendingRequest >> requestSymbole [

	^ requestSymbole
]

{ #category : 'accessing' }
PendingRequest >> requestSymbole: anObject [

	requestSymbole := anObject
]

{ #category : 'accessing' }
PendingRequest >> requiredSate [

	^ requiredSate
]

{ #category : 'accessing' }
PendingRequest >> requiredSate: anObject [

	requiredSate := anObject
]
