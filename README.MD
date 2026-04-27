# sindarin-dap

`sindarin-dap` is an implementation of a Debug Adapter Protocol (DAP) client. It relies on the structures and types provided by [Pharo-LanguageServer](https://github.com/FlavienVolant/Pharo-LanguageServer/tree/v5).

The main goal of this project is to map Sindarin commands to their DAP equivalents, allowing the debugger to be controlled through Sindarin scripts.

The client currently works exclusively over socket connections.

## Installation
``` smalltalk
Metacello new
	baseline: 'PharoDAPClient';
	repository: 'github://FlavienVolant/sindarin-dap:main';
	load
```

## Architecture

### `DAPClient`

`DAPClient` is the base class responsible for:
- Managing the connection to the DAP server
- Sending messages on the main thread
- Receiving responses on a separate thread

It also implements a callback mechanism to handle:
- Responses to specific requests
- Incoming requests and events from the DAP server


### `SindarinDAPClient`

`SindarinDAPClient` is the main entry point of the project.

It extends `DAPClient` and provides an implementation of Sindarin commands as DAP messages.

Unlike `DAPClient`, this client is designed to behave synchronously by waiting for responses. See:
- `handleAsyncResponse: anAction returning: key`

Since the client may need to store data inside the debuggee, and this behavior depends on the target language, the following methods are left as subclass responsibilities:
- `dapRegistryAt: keyAsString put: valueAsString`
- `initializeDapRegistry`

These require DAP capabilities such as `supportSetExpressions` or `supportSetVariables`.


### `DAPClientBuilder`

`DAPClientBuilder` is the recommended way to configure and initialize a DAP client.

It handles:
- The handshake with the DAP server
- Sending initialization data at the correct time

See the `Examples` `initialize` methods for usage.


### `ClientDAPPresenter`

`ClientDAPPresenter` is a UI tool that displays all:
- Requests
- Responses
- Events

that go through the client.


## Supported Languages

The client currently supports:

- Python -> `DAPClientForPY`
- Java -> `DAPClientForJAVA`
- JavaScript -> `DAPClientForJS`

Refer to the corresponding help/documentation for each language to learn how to set up your environment and start debugging.


## Python

This client uses [`debugpy`](https://github.com/microsoft/debugpy) as the DAP adapter.

### Installation

Install `debugpy` using pip:

```bash
pip install debugpy
```

### Starting the DAP Adapter

Run your Python script with `debugpy` and wait for the client to attach:

```bash
python -m debugpy --listen 5678 --wait-for-client py/script.py
```

### Client Configuration (Pharo)
The DAP client is configured via `DAPClientForPY`.
You can adapt the following example to your setup:
``` smalltalk
	DAPClientBuilder new
		client: self;
		port: 5678;
		adapterID: 'python';
		attachArguments: self attachArguments;
		breakpoint: '/path/to/your/script.py' line: 8;
		functionBreakpoint: 'toto' condition: 'True';
		startClientSession

attachArguments
	^ {
		  ('name' -> 'Attach to Python').
		  ('type' -> 'python').
		  ('connect' -> {
			   ('host' -> 'localhost').
			   ('port' -> 5678) } asDictionary).
		  ('redirectOutput' -> true).
		  ('showReturnValue' -> true) } asDictionary
```

### Starting the Debugging Session

- Start the `debugpy` adapter (see above)
- In a Pharo Playground, run:
``` smalltalk
client := ClientDAPPresenter newWithClient: DAPClientForPY new.
client open.
```

## JavaScript (Node.js)

This client uses the Microsoft **vscode-js-debug** adapter.


### Requirements

- Node.js
- [`vscode-js-debug`](https://github.com/microsoft/vscode-js-debug) (tested with `v1.112.0`)


### Getting the JavaScript Debug Adapter

Download a release from:

https://github.com/microsoft/vscode-js-debug/releases

Extract it, then locate the DAP server entry point:
```
js-debug/src/dapDebugServer.js
```


### Starting the Target Script

Run your Node.js script in debug mode:

```bash
node --inspect-brk=0.0.0.0:9229 js/script.js
```

This starts Node with the inspector protocol enabled and waits for a debugger to attach.


### Starting the DAP Adapter

Launch the debug adapter server:
```
node js-debug/src/dapDebugServer.js 5678
```
The adapter will listen for DAP connections on port `5678`.


### Client Configuration (Pharo)

This adapter require the client to support `startDebuggingRequest`. Therefore, a second DAP client (`DAPClientForJSStartDebug`) is created with extended `attachArguments`.

``` smalltalk
initialize
	super initialize.

	requestHandlers
		at: 'startDebugging'
		put: [ :req | self handleStartDebuggingRequest: req ]


handleStartDebuggingRequest: aStartDebuggingRequest

	| childClient |

	childClient := DAPClientForJSStartDebug new
		attachOtherArguments:
			(aStartDebuggingRequest
				at: 'arguments'
				at: 'configuration').

	childClient startSession.

	(ClientDAPPresenter newWithClient: childClient) open
```

### Starting a Session

``` smalltalk
startSession
	
	DAPClientBuilder new
		client: self;
		adapterID: 'node';
		port: 5678;
		attachArguments: self attachArguments;
		startClientSession

attachArguments
	
	^ {
		('name' -> 'Attach Node.js script.js').
		('type' -> 'pwa-node').
		('request' -> 'attach').
		('address' -> 'localhost').
		('port' -> 9229).
		('continueOnAttach' -> true)
	} asDictionary
```

### Starting the Debugging Session

- Start your Node.js script with --inspect-brk
- Start the vscode-js-debug adapter
- In a Pharo Playground, run:
``` smalltalk
client := DAPClientForJS new startSession.
```

## Java

The Java client relies on the [java-debug](https://github.com/microsoft/java-debug) adapter from Microsoft.  
This adapter is designed to work as a plugin for the Java Language Server ([eclipse.jdt.ls](https://github.com/eclipse-jdtls/eclipse.jdt.ls)).


### Requirements

- `eclipse.jdt.ls` (Java Language Server)
- `java-debug` plugin


### Getting the Java Debug Adapter

One simple way to obtain the adapter is to install the VS Code extension:

- **Debugger for Java (Microsoft)**

After installation, you can find the required JAR in:
```
.vscode/extensions/vscjava.vscode-java-debug-<version>/server/
```

Look for a file like:
```
com.microsoft.java.debug.plugin-<version>.jar
```



### Starting the LSP Server with java-debug

To use `java-debug`, you must start `eclipse.jdt.ls` with the debug plugin included in the `bundles` initialization option:

```json
{
  "initializationOptions": {
    "bundles": [
      "path/to/com.microsoft.java.debug.plugin-<version>.jar"
    ]
  }
}
```

### Starting a Debug Session
Once eclipse.jdt.ls is running, send the following command via your LSP client:
``` json
{
  "command": "vscode.java.startDebugSession"
}
```
The server will respond with a port number where the DAP adapter is listening.

### Client Configuration (Pharo)
Use `DAPClientForJAVA` and configure it with the port returned by the LSP server:
``` smalltalk
	DAPClientBuilder new
		client: self;
		port: 63461; "Replace with the returned port"
		adapterID: 'java';
		attachArguments: self attachArguments;
		breakpoint:
			'/path/to/your/project/src/main/java/example/Main.java'
		line: 5;
		breakpoint:
			'/path/to/your/project/src/main/java/example/Main.java'
		line: 9;
		functionBreakpoint: 'example.Bar#toto'
		condition:
			'true';
		startClientSession
```

### Starting the Debugging Session
- Start `eclipse.jdt.ls` with the `java-debug` plugin
- Send the `vscode.java.startDebugSession` command via your LSP client
- Retrieve the port from the response
- In a Pharo Playground, run:
``` smalltalk
client := ClientDAPPresenter newWithClient: DAPClientForJAVA new.
client open.
```
