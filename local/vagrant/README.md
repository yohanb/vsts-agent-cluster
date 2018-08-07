## Installing Vagrant

- Start an admin shell
- Install [Chocolatey](https://chocolatey.org/)
- Install VirtualBox `choco install virtualbox` (make sure Hyper-V isn't installed concurrently.)
- Intall Vagrant `choco install vagrant`

## Misc

- The VM name can be added to all the vagrant commands to limit its scope to a specific VM. For example `vagrant up mongodb` or `vagrant halt eventstore`
- To reset the eventstore database run the script `eventstore-clear-db.cmd` from the Vagrant directory 