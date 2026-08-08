# dirsum

`dirsum` is a small bash command-line utility that summarises the contents of a directory.

## Usage

Run `dirsum` with no arguments to summarise the current directory:

```bash
./bin/dirsum
```

Or provide a directory as the first argument:

```bash
./bin/dirsum /path/to/directory
```

### Help

Show command usage:

```bash
./bin/dirsum --help
```

### Version

Show the current version:

```bash
./bin/dirsum --version
```

## Error behaviour

Invalid arguments or paths are reported to standard error and return a non-zero exit status.

Examples of invalid input include:

- a path that does not exist;
- a path that is not a directory;
- an unknown option;
- more than one argument.