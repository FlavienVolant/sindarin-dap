Extension { #name : 'BlockClosure' }

{ #category : '*PharoDAPClient' }
BlockClosure >> stepUntilOn: aSindarinDAPClient [

	aSindarinDAPClient stepUntilBlock: self
]
