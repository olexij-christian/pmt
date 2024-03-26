# PMT (Package Manager Translator)

PMT is a lightweight command-line tool designed to facilitate the translation of package names between different package managers on Linux distributions, such as apt or dnf. Whether you're migrating projects or managing dependencies across different Linux distributions, PMT aims to simplify the process.

## Features

- **Package Manager Compatibility**: Translate package names between different package managers on Linux distributions seamlessly.
- **Simple Command-Line Interface**: Just install as you would with any distribution.
- **Minimal Dependencies**: Lightweight and efficient, PMT aims to keep dependencies to a minimum.

## Dependencies

- curl
- [pup](https://github.com/ericchiang/pup)
- [gum](https://github.com/charmbracelet/gum)
- [watcher](https://github.com/sethigeet/watcher)(optional, only for development)

Instalation with golang package manager.

```
go install github.com/ericchiang/pup@latest
go install github.com/charmbracelet/gum@latest
```
```
go install github.com/sethigeet/watcher@latest
```

## Build

To build and install PMT, you can use the `make` tool. Use the following commands:

```bash
make
make install # Install globally
make install USR=$HOME/.local # Install only for the current user
```

The `make` command will automatically compile PMT, and the `make install` command will install it according to the specified options.

## Installation

**TODO**

## Usage

### Basic Usage

To translate package names, use the `translate` command followed by the source and target package managers.

```bash
pmt <package-manager> <install-command> <packages...>
```

For example:

```bash
pmt apt install i3-wm bash
```

### Available Package Managers

PMT currently supports the following package managers on Linux distributions:

- [X] apt-get (Debian, Devuan)
- [X] dnf (Fedora)

Package managers for future:

- [ ] apt (Ubuntu repositories)
- [ ] pacman (Arch, Manjaro)
- [ ] apk (Alpine)
- [ ] brew (macOS or Linux)
- [ ] xbps (Void)
- [ ] zypper (zypper)
- [ ] nix-env (Nix)
- [ ] eopkg (Solus)

### Additional Options

- `-h`, `--help`: Display help message and exit.
- `-v`, `--version`: Display version information.
- `-n`, `--dry-run`: Translate without installing.
- `-y`, `--yes`: Enable automatic yes to prompts.

## Examples

**TODO**

## Contribution

Given that the project is under development, expect some translation mistakes. Your contribution to improving PMT is welcome! If you encounter any issues, have feature requests, or wish to contribute enhancements, please don't hesitate to submit an issue or pull request.

## Acknowledgments

I thank Jesus Christ that I have a laptop, time and opportunities to work on this project. And also to everyone who supports or is interested in this project.

---

Thank you for using PMT! If you have any questions or feedback, feel free to reach out. Happy translating! 🚀
