Class {
	#name : 'DAPBackendJAVA',
	#superclass : 'DAPBackend',
	#category : 'PharoDAPClient-Examples',
	#package : 'PharoDAPClient',
	#tag : 'Examples'
}

{ #category : 'accessing' }
DAPBackendJAVA >> constructorsOf: classExpr [
	"Return a collection of string corresponding to the full name of the constructors of classExpr. 
	Names are send to function breakpoint name"

	^ { ('example.' , classExpr , '#<init>') }
]

{ #category : 'accessing' }
DAPBackendJAVA >> equalityExpressionLeft: leftExpr right: rightExpr [

	^ leftExpr , '.equals(' , rightExpr , ')'
]

{ #category : 'accessing' }
DAPBackendJAVA >> expressionKey: varExpr instanceOf: classExpr [

	^ varExpr , ' instanceof ' , classExpr
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
DAPBackendJAVA >> methodsOf: objExpr [
	"Return a collection of string corresponding to the full name of the methods of objExpr. 
	Names are send to function breakpoint name"

	| evalResp |
	evalResp := clientDAP
		            evaluate:
			            'java.util.Arrays.stream(bar.getClass().getMethods())
    .map(m -> bar.getClass().getPackage().getName() + "." + bar.getClass().getSimpleName() + "#" + m.getName())
    .toList()'
		            frameId: clientDAP currentFrameId.

	^ (clientDAP variablesForReference:
		   (evalResp at: 'variablesReference')) collect: [ :dapVar |
		  dapVar at: 'value' ]
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
