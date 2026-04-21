Class {
	#name : 'DAPBackendPY',
	#superclass : 'DAPBackend',
	#category : 'PharoDAPClient-Examples',
	#package : 'PharoDAPClient',
	#tag : 'Examples'
}

{ #category : 'accessing' }
DAPBackendPY >> equalityExpressionLeft: leftExpr right: rightExpr [

	^ leftExpr , ' == ' , rightExpr 
]

{ #category : 'accessing' }
DAPBackendPY >> idExpressionFor: objExpr [

	^ objExpr 
]

{ #category : 'initialization' }
DAPBackendPY >> initializeRegistry [

	clientDAP
		stackTrace:
		(DAPStackTraceArguments new threadId: clientDAP mainThreadId)
		onResponse: [ :resp |
				clientDAP evaluate: (DAPEvaluateArguments new
						 expression:
							 '__import__("builtins").__dict__.setdefault("__dap_registry__", {})';
						 frameId: (((resp at: 'body') at: 'stackFrames') first at: 'id')) ]
]

{ #category : 'accessing' }
DAPBackendPY >> instanceName [

	^ 'self'
]

{ #category : 'accessing' }
DAPBackendPY >> readExpressionForKey: aString [
	"return ... aString is the key"

	^ '__import__("builtins").__dap_registry__.get("' , aString , '")'
]

{ #category : 'accessing' }
DAPBackendPY >> store: aString forExpression: objExpr [

	clientDAP
		stackTrace:
		(DAPStackTraceArguments new threadId: clientDAP mainThreadId)
		onResponse: [ :resp |
				clientDAP setExpression: (DAPSetExpressionArguments new
						 expression:
							 '__import__("builtins").__dap_registry__["' , aString , '"]';
						 value: objExpr;
						 frameId: (((resp at: 'body') at: 'stackFrames') first at: 'id')) ]
]
