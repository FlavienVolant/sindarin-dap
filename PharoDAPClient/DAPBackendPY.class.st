Class {
	#name : 'DAPBackendPY',
	#superclass : 'DAPBackend',
	#category : 'PharoDAPClient-Examples',
	#package : 'PharoDAPClient',
	#tag : 'Examples'
}

{ #category : 'accessing' }
DAPBackendPY >> constructorsOf: classExpr [
	"Return a collection of string corresponding to the full name of the constructors of classExpr. 
	Names are send to function breakpoint name"

	^ { '__init__' }
]

{ #category : 'accessing' }
DAPBackendPY >> equalityExpressionLeft: leftExpr right: rightExpr [

	^ leftExpr , ' == ' , rightExpr 
]

{ #category : 'accessing' }
DAPBackendPY >> expressionKey: expr instanceOf: classExpr [

	^ 'isinstance(' , expr , ',' , classExpr , ')'
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
DAPBackendPY >> methodsOf: objExpr [
	"Return a collection of string corresponding to the full name of the methods of objExpr. 
	Names are send to function breakpoint name"

	| evalResp |
	evalResp := clientDAP
		            evaluate:
		            '[m for m in dir(bar) if callable(getattr(bar, m)) and not m.startswith("__")]'
		            frameId: clientDAP currentFrameId.

	^ STONJSON fromString: (evalResp at: 'result')
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
