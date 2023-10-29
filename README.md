# edit-list.nvim

## Introduction

The edit-list.nvim is a plugin that helps you keep track of all the locations where you have made changes in a project. It provides an easy way to navigate to these locations, making it simple to resume your work exactly where you left off.

This README.md will guide you through the installation, usage, and customization of this plugin.

## Features

- Track and maintain a list of all locations with changes in your project.
- Navigate to these locations with ease.
- Supports multiple projects, allowing you to manage changes in various codebases efficiently.

## Installation

* Installation using Lazy
```
    {
        "Sharonex/edit-list.nvim",
        config = function()
            require("edit-list").setup()
        end,
    },
```

## Usage

### Basic Usage

1. Open Neovim in your project directory.

2. As you make changes in your codebase, the plugin will automatically track the locations.

3. To see the list of tracked locations, use:

```vim
:EditList
```

4. You can navigate to a tracked location by selecting it from the list and hitting Enter.

### Customization

You can customize the plugin's behavior by setting various options in your Neovim configuration. For example:

```vim
" Define a custom keybinding to list tracked locations.
nnoremap <leader>ll :EditList<CR>
```
