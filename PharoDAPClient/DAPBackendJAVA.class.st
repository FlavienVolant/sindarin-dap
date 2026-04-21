Class {
	#name : 'DAPBackendJAVA',
	#superclass : 'DAPBackend',
	#category : 'PharoDAPClient-Examples',
	#package : 'PharoDAPClient',
	#tag : 'Examples'
}

{ #category : 'accessing' }
DAPBackendJAVA >> equalityExpressionLeft: leftExpr right: rightExpr [

	^ leftExpr , '.equals(' , rightExpr , ')'
]

{ #category : 'accessing' }
DAPBackendJAVA >> idExpressionFor: expr [

	^ 'Integer.toString(System.identityHashCode(' , expr , '))'
]

{ #category : 'initialization' }
DAPBackendJAVA >> initializeRegistry [
	" In Java, there is no need to initialize a global registry.
	The java.lang.System object already exists and is globally accessible in the JVM.

	We use it as a simple key/value store via System.setProperty / System.getProperty.

	Because this storage is already built into the runtime, there is nothing to create or inject. "

	
]

{ #category : 'accessing' }
DAPBackendJAVA >> instanceName [

	^ 'this'
]

{ #category : 'accessing' }
DAPBackendJAVA >> readExpressionForKey: aString [
	"return ... aString is the key"

	^ 'System.getProperty("' , aString , '")'
]

{ #category : 'accessing' }
DAPBackendJAVA >> store: aString forExpression: objExpr [

	clientDAP
		stackTrace:
		(DAPStackTraceArguments new threadId: clientDAP mainThreadId)
		onResponse: [ :resp |
				clientDAP evaluate: (DAPEvaluateArguments new
						 expression:
							 'System.setProperty("' , aString , '", '
							 , (self idExpressionFor: objExpr) , ')';
						 frameId: (((resp at: 'body') at: 'stackFrames') first at: 'id')) ]
]
