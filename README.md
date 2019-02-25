# bubblewrapper #
A collection of wrapper scripts for bubblewrap to facilitate installing
software in sandboxed filesystems.
## Usage ##
| Command | Description |
| ------- | ------ |
| `bubblewrapper setup <namespace>` | Creates a new namspace with the given name. |
| `bubblewrapper start <namespace>` | Launches a shell in the namespace, if it exists. |
|`bubblewrapper update <namespace>` | Update all packages in the namespace. If no namespace is specified, update all. |
| `bubblewrapper install <namespace> <packages...>` |  Installs the packages into the given namespace. |
| `bubblewrapper delete <namespace>` | Deletes the specified namespace.
