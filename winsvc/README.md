# Windows Service Wrapper

## Download

Latest release and pre-release WinSW binaries are available on [GitHub Releases](https://github.com/winsw/winsw/releases).

## Get started

### Use WinSW as a global tool

1. Take *WinSW.exe* or *WinSW.zip* from the distribution.
1. Write *myapp.xml* (see the [XML config file specification](docs/xml-config-file.md) and [samples](samples) for more details).
1. Run [`winsw install myapp.xml [options]`](docs/cli-commands.md#install-command) to install the service.
1. Run [`winsw start myapp.xml`](docs/cli-commands.md#start-command) to start the service.
1. Run [`winsw status myapp.xml`](docs/cli-commands.md#status-command) to see if your service is up and running.

### Use WinSW as a bundled tool

1. Take *WinSW.exe* or *WinSW.zip* from the distribution, and rename the *.exe* to your taste (such as *myapp.exe*).
1. Write *myapp.xml* (see the [XML config file specification](docs/xml-config-file.md) and [samples](samples) for more details).
1. Place those two files side by side, because that's how WinSW discovers its co-related configuration.
1. Run [`myapp.exe install [options]`](docs/cli-commands.md#install-command) to install the service.
1. Run [`myapp.exe start`](docs/cli-commands.md#start-command) to start the service.

### Sample configuration file

You write the configuration file that defines your service.
The example below is a primitive example being used in the Jenkins project:

```xml
<service>
  <id>jenkins</id>
  <name>Jenkins</name>
  <description>This service runs Jenkins continuous integration system.</description>
  <env name="JENKINS_HOME" value="%BASE%"/>
  <executable>java</executable>
  <arguments>-Xrs -Xmx256m -jar "%BASE%\jenkins.war" --httpPort=8080</arguments>
  <log mode="roll"></log>
</service>
```

The full specification of the configuration file is available [here](docs/xml-config-file.md).
You can find more samples [here](samples).

## Usage

WinSW is being managed by the [XML configuration file](docs/xml-config-file.md).

Your renamed *WinSW.exe* binary also accepts the following commands:

| Command                                             | Description |
| -------                                             | ----------- |
| [install](docs/cli-commands.md#install-command)     | Installs the service. |
| [uninstall](docs/cli-commands.md#uninstall-command) | Uninstalls the service. |
| [start](docs/cli-commands.md#start-command)         | Starts the service. |
| [stop](docs/cli-commands.md#stop-command)           | Stops the service. |
| [restart](docs/cli-commands.md#restart-command)     | Stops and then starts the service. |
| [status](docs/cli-commands.md#status-command)       | Checks the status of the service. |
| [refresh](docs/cli-commands.md#refresh-command)     | Refreshes the service properties without reinstallation. |
| [customize](docs/cli-commands.md#customize-command) | Customizes the wrapper executable. |
| dev                                                 | Experimental commands. |


## Documentation

[GitHub Home page](https://github.com/winsw/winsw)