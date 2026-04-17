Extension { #name : 'ByteString' }

{ #category : '*PharoDAPClient' }
ByteString >> stepUntilOn: aSindarinDAPClient [

	aSindarinDAPClient stepUntilString: self
]
