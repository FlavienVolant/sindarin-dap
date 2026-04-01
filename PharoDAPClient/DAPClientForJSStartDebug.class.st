Class {
	#name : 'DAPClientForJSStartDebug',
	#superclass : 'DAPClientForJS',
	#instVars : [
		'attachOtherArguments'
	],
	#category : 'PharoDAPClient-examples',
	#package : 'PharoDAPClient',
	#tag : 'examples'
}

{ #category : 'initialization' }
DAPClientForJSStartDebug >> attachArguments [

	| dict |
	dict := super attachArguments.
	attachOtherArguments addAll: dict.

	^ attachOtherArguments
]

{ #category : 'accessing' }
DAPClientForJSStartDebug >> attachOtherArguments [

	^ attachOtherArguments
]

{ #category : 'accessing' }
DAPClientForJSStartDebug >> attachOtherArguments: anAttachArguments [

	attachOtherArguments := anAttachArguments
]

{ #category : 'handle request' }
DAPClientForJSStartDebug >> handleStartDebuggingRequest: aStartDebuggingRequest [

	"stop"
]
