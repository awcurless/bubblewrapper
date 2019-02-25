# bubblewrapper #
A collection of wrapper scripts for bubblewrap to facilitate installing
software in sandboxed environments.
* Separate /usr, /var, /home directorys.
* No sharing of host OS files
* No sharing of host devices by default (A limited set such as /dev/null are
available).
* Separate ipc and cgroup namespaces.

## Installation ##
1. Install dependencies: `bubblewrap fakeroot fakechroot`
1. Add bubblewrapper to your `$PATH`
1. Create a namespace `bubblewrapper setup <namespace>`

## Configuration ##
No configuration is required for pacman based distros. Otherwise each of the following
environment variables must be set:
* `BUBBLEWRAPPER_BASE_PACKAGES`: Packages Bubblewrapper will install into each new
sandbox. The names specified here must be valid packages according to your package
manager.
* `BUBBLEWRAPPER_PACKAGER_CMD`: The command to invoke your disto's package manager.
"pacman" for Arch, "dnf" for Fedora, etc.
* `BUBBLEWRAPPER_UPDATE_ARGS`: Arguments and flags for a full system update, used to
update sandboxes.
* `BUBBLEWRAPPER_UNINSTALL_ARGS`: Arguments and flags required by the package manager
to remove a package.
* `BUBBLEWRAPPER_SANDBOX_DIRECTORY`: Directory to create sandboxes in. Defaults to
"~/.sandboxes".

## Usage ##
| Command | Description |
| ------- | ------ |
| `bubblewrapper setup <namespace>` | Creates a new namspace with the given name. |
| `bubblewrapper start <namespace>` | Launches a shell in the namespace, if it exists. |
|`bubblewrapper update <namespace>` | Update all packages in the namespace. If no namespace is specified, update all. |
| `bubblewrapper install <namespace> <packages...>` |  Installs the packages into the given namespace. |
| `bubblewrapper delete <namespace>` | Deletes the specified namespace.
| `bubblewrapper uninstall <namespace> <package>` | Uninstall the given package from the given namespace. |
