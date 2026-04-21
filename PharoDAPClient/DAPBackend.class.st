Class {
	#name : 'DAPBackend',
	#superclass : 'Object',
	#instVars : [
		'clientDAP'
	],
	#category : 'PharoDAPClient-Model',
	#package : 'PharoDAPClient',
	#tag : 'Model'
}

{ #category : 'accessing' }
DAPBackend >> buildInstanceCondition: objExpr [

	| key leftExpr rightExpr |
	key := self generateKey.
	self store: key forExpression: objExpr.

	leftExpr := self idExpressionFor: self instanceName.
	rightExpr := self readExpressionForKey: key.

	^ self equalityExpressionLeft: leftExpr right: rightExpr
]

{ #category : 'accessing' }
DAPBackend >> clientDAP: aDAPClient [

	clientDAP := aDAPClient
]

{ #category : 'accessing' }
DAPBackend >> equalityExpressionLeft: leftExpr right: rightExpr [

	^ self subclassResponsibility 
]

{ #category : 'accessing' }
DAPBackend >> generateKey [

	^ 'instance_' , UUID new asString
]

{ #category : 'accessing' }
DAPBackend >> idExpressionFor: objExpr [
	"^ aString"

	^ self subclassResponsibility
]

{ #category : 'initialization' }
DAPBackend >> initializeRegistry [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
DAPBackend >> instanceName [
	"return this or self"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
DAPBackend >> readExpressionForKey: aString [
	"return ... aString is the key"

	^ self subclassResponsibility
]

{ #category : 'accessing' }
DAPBackend >> store: aString forExpression: objExpr [
	
	^ self subclassResponsibility 
]
