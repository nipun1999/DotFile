# General Dotfiles

A collection of dotfiles inspired by [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles), focused on aliases and Cursor extensions.

## Features

- **Aliases**: Useful command shortcuts for common tasks
- **Cursor Extensions**: Automated installation of essential Cursor extensions
- **Modular Structure**: Easy to maintain and extend

## Installation

### Using the bootstrap script

Clone the repository and run the bootstrap script:

```bash
git clone <your-repo-url> && cd general_dotfile && source bootstrap.sh
```

### Manual installation

1. **Install aliases**: Add to your shell configuration file (`.bashrc`, `.zshrc`, etc.):
   ```bash
   source ~/path/to/dotfiles/.aliases
   ```

2. **Install Cursor extensions**: Run the extensions installer:
   ```bash
   source ~/path/to/dotfiles/init/cursor-extensions.sh
   ```

## Structure

```
general_dotfile/
├── bootstrap.sh              # Main bootstrap script
├── .aliases                  # Shell aliases
├── init/
│   └── cursor-extensions.sh  # Cursor extensions installer
└── README.md
```

## Aliases

The `.aliases` file includes useful shortcuts for:

- **Navigation**: `..`, `...`, `~`, etc.
- **Git**: `g`, `ga`, `gc`, `gco`, etc.
- **Docker**: `d`, `dc`, `dps`, etc.
- **Development**: `py`, `pip`, `node`, etc.
- **System**: `c`, `h`, `l`, etc.
- **macOS specific**: `showfiles`, `hidefiles`, `flushdns`, etc.

## Cursor Extensions

The following extensions are automatically installed:

- `esbenp.prettier-vscode` - Code formatter
- `formulahendry.docker-explorer` - Docker explorer
- `formulahendry.docker-extension-pack` - Docker extension pack
- `golang.go` - Go language support
- `ms-python.python` - Python language support
- `ms-python.debugpy` - Python debugger
- `ms-python.vscode-pylance` - Python language server
- `nextfaze.json-parse-stringify` - JSON utilities
- `waderyan.gitblame` - Git blame information

## Usage

After installation, you can use the aliases directly in your terminal. For Cursor extensions, they will be automatically available in Cursor.

### Updating extensions

```bash
cursor --update-extensions
```

### Manual extension installation

```bash
source ~/path/to/dotfiles/init/cursor-extensions.sh
```

## Customization

You can customize the aliases by editing the `.aliases` file, or add new extensions by modifying the `EXTENSIONS` array in `init/cursor-extensions.sh`.

## Requirements

- Bash or Zsh
- Cursor (for extensions)
- Git (for installation)

## License

MIT License - feel free to use and modify as needed. 