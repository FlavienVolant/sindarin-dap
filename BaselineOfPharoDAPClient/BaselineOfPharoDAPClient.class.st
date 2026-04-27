Class {
	#name : 'BaselineOfPharoDAPClient',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfPharoDAPClient',
	#package : 'BaselineOfPharoDAPClient'
}

{ #category : 'baselines' }
BaselineOfPharoDAPClient >> baseline: spec [

	<baseline>
	spec
		baseline: 'PharoLanguageServer'
		with: [
		spec repository: 'github://FlavienVolant/Pharo-LanguageServer:v5' ].
	spec for: #commom do: [ spec package: 'PharoDAPClient' ]
]

{ #category : 'accessing' }
BaselineOfPharoDAPClient >> projectClass [
	^ MetacelloCypressBaselineProject
]
