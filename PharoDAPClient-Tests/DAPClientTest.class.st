Class {
	#name : 'DAPClientTest',
	#superclass : 'TestCase',
	#instVars : [
		'client',
		'server',
		'port'
	],
	#category : 'PharoDAPClient-Tests',
	#package : 'PharoDAPClient-Tests'
}

{ #category : 'running' }
DAPClientTest >> handleClientOn: stream [

	| message |
	message := self readDAPMessageFrom: stream.

	"vérifie que c'est initialize"
	self assert: (message includesSubstring: 'initialize').

	self sendInitializeResponseOn: stream
]

{ #category : 'running' }
DAPClientTest >> setUp [
	
	super setUp.
	client := DAPClient new.
	port := 5678.
	server := Socket newTCP.
	server listenOn: port
]

{ #category : 'running' }
DAPClientTest >> startMockServer [

	[ |socket stream|
		socket := server accept.
		stream := SocketStream on: socket.
		
		self handleClientOn: stream
	 ] fork
]

{ #category : 'running' }
DAPClientTest >> startSession [

	DAPClientBuilder new
		client: client;
		port: port;
		adapterID: 'Mock';
		startClientSession
]

{ #category : 'tests' }
DAPClientTest >> testOnConnectionClientSendInitializeRequestAndWaitForResponse [

	self fail
]
