Class {
	#name : 'DAPBackendJS',
	#superclass : 'DAPBackend',
	#category : 'PharoDAPClient-Examples',
	#package : 'PharoDAPClient',
	#tag : 'Examples'
}

{ #category : 'accessing' }
DAPBackendJS >> constructorsOf: classExpr [
	"Return a collection of string corresponding to the full name of the constructors of classExpr. 
	Names are send to function breakpoint name"

	^ { 'constructor' }
]

{ #category : 'accessing' }
DAPBackendJS >> equalityExpressionLeft: leftExpr right: rightExpr [

	^ leftExpr , ' === ' , rightExpr
]

{ #category : 'accessing' }
DAPBackendJS >> expressionKey: varExpr instanceOf: classExpr [

	^ varExpr , ' instanceof ' , classExpr
]

{ #category : 'accessing' }
DAPBackendJS >> idExpressionFor: objExpr [
	"^ aString"

	^ objExpr 
]

{ #category : 'initialization' }
DAPBackendJS >> initializeRegistry [

	clientDAP
		stackTrace:
		(DAPStackTraceArguments new threadId: clientDAP mainThreadId)
		onResponse: [ :resp |
				clientDAP setExpression: (DAPSetExpressionArguments new
						 expression: 'globalThis.__dap_registry__';
						 value: '{}';
						 frameId: (((resp at: 'body') at: 'stackFrames') first at: 'id')) ]
]

{ #category : 'accessing' }
DAPBackendJS >> instanceName [
	"return this or self"

	^ 'this'
]

{ #category : 'accessing' }
DAPBackendJS >> methodsOf: objExpr [
	"Return a collection of string corresponding to the full name of the methods of objExpr. 
	Names are send to function breakpoint name"

	^ {  }
]

{ #category : 'accessing' }
DAPBackendJS >> readExpressionForKey: aString [
	"return ... aString is the key"

	^ 'globalThis.__dap_registry__[' , aString , ']'
]

{ #category : 'accessing' }
DAPBackendJS >> store: aString forExpression: objExpr [

	clientDAP
		stackTrace:
		(DAPStackTraceArguments new threadId: clientDAP mainThreadId)
		onResponse: [ :resp |
				clientDAP setExpression: (DAPSetExpressionArguments new
						 expression: 'globalThis.__dap_registry__["' , aString , '"]';
						 value: objExpr;
						 frameId: (((resp at: 'body') at: 'stackFrames') first at: 'id')) ]
]
