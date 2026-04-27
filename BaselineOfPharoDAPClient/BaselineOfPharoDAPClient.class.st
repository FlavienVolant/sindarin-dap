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
	spec package: 'PharoDAPClient'.
	spec package: 'PharoDAPClient-Tests'.
]

{ #category : 'accessing' }
BaselineOfPharoDAPClient >> projectClass [
	^ MetacelloCypressBaselineProject
]
