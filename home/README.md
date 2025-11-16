# Home Directory Structure

This directory mirrors the user's home directory structure for organization purposes.

## Purpose

The `home/` directory provides a logical separation for:
- Files that would be placed in the user's home directory
- Custom scripts or tools not managed by `.chezmoiexternal.yaml`
- Example configurations

## Current Structure

```
home/
└── .local/
    └── bin/          # Custom user scripts (if any)
```

## Usage

Files in this directory are **NOT** automatically applied by chezmoi (they're in `.chezmoiignore`). 
This directory serves as:
1. A reference location for manual installations
2. A staging area for custom tools
3. Documentation of home directory structure

## External Binaries

External binaries (kubectl, terraform, etc.) are managed by `.chezmoiexternal.yaml.tmpl` 
and are automatically installed to `~/.local/bin` by chezmoi.

See [EXTERNAL_TOOLS.md](../EXTERNAL_TOOLS.md) for more details.
