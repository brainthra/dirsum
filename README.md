# dirsum

`dirsum` is a small bash command-line utility that summarises the contents of a directory.

> `dirsum` counts regular files and subdirectories directly inside the target directory.
> > The summary is non-recursive; entries contained within subdirectories are not included.
> >
> > Hidden files and directories are included in the counts.

## Installation

Install `dirsum` for the current user by copying the executable to `~/.local/bin`:

```bash
mkdir -p ~/.local/bin
cp bin/dirsum ~/.local/bin/dirsum
```

Ensure that `~/.local/bin` is in your `PATH`.

Verify that the installation was successful by running:

```bash
command -v dirsum
dirsum --version
```

To uninstall, simply remove the executable:

```bash
rm ~/.local/bin/dirsum
```


## Usage

Run `dirsum` with no arguments to summarise the current directory:

```bash
dirsum
```

Or provide a directory as the first argument:

```bash
dirsum /path/to/directory
```

### Help

Show command usage:

```bash
dirsum --help
```

### Version

Show the current version:

```bash
dirsum --version
```

## Error behaviour

Invalid arguments or paths are reported to standard error and return a non-zero exit status.

Examples of invalid input include:

- a path that does not exist;
- a path that is not a directory;
- an unknown option;
- more than one argument.

## Development

### Testing

Run the tests with:

```bash
./tests/test_dirsum.sh
```

### Continuous integration

GitHub Actions runs the project's verification checks for pull requests and updates to `main`.

The workflow runs:

```bash
shellcheck bin/dirsum tests/test_dirsum.sh
./tests/test_dirsum.sh
```
