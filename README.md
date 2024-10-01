# github-cli

Command-line tool for managing GitHub

## Install （mac & liunx）

```shell
curl -S https://raw.githubusercontent.com/Groos-dev/github-cli/refs/heads/main/gh-cli-installer.sh | bash
```

## How to use

### Create a repo

- create a public repository named repo001

```shell
gh-cli create repo001 -d "This is a description text." 
```

- create a private repository named repo001

```shell
gh-cli create repo001 -d "This is a description text." 
```

### Delete a repo

```shell
gh-cli delete repo001 
```

### update gh-cli

```shell
gh-cli update-cli
```

### Other operations

todo ...

Usage:
  gh-cli --help
  gh-cli create <repo_name> [-d <discription>] [-s <public|private>]
  gh-cli delete <repo_name>
  gh-cli update-cli

                      Create a remote repository named <repo_name>install a <version>. Uses .nvmrc if available and version is omitted.
   The following optional arguments, if provided, must appear directly after `nvm install`:
    -s                                        Skip binary download, install from source only.
    -b                                        Skip source download, install from binary only.
    --reinstall-packages-from=<version>       When installing, reinstall packages installed in <node|iojs|node version number>
    --lts                                     When installing, only select from LTS (long-term support) versions
    --lts=<LTS name>                          When installing, only select from versions for a specific LTS line
    --skip-default-packages                   When installing, skip the default-packages file if it exists
    --latest-npm                              After installing, attempt to upgrade to the latest working npm on the given node version
    --no-progress                             Disable the progress bar on any downloads
    --alias=<name>                            After installing, set the alias specified to the version specified. (same as: nvm alias <name> <version>)
    --default                                 After installing, set default alias to the version specified. (same as: nvm alias default <version>)
  nvm uninstall <version>                     Uninstall a version
  nvm uninstall --lts
