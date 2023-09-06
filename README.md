# dotfiles

Some stolen from:
 - [balaclark](https://github.com/balaclark/dotfiles)
 - [benjaminparnell](https://github.com/benjaminparnell/dotfiles)
 - [asheboy](https://github.com/Asheboy/dotfiles)
 - [Miguel M](https://git.parata.xyz/eot/dotfiles/) (top quality dotfiles)

Huge thank you's to the vim-ers and tmux-ers at [Clock Limited](https://github.com/clocklimited) for the support in getting my setup working smoothly.

## Setup

Compile the statusline binary: (you will need `gcc` and `strip`)

```
$ make
```

Deploy dotfiles

```
$ make deploy
```

## Updating dotfiles

After making a change in the repo, you can redeploy the changes simply with:

```
$ make deploy
```

### Tools/Package Managers

 - Font: Fira Code
 - go
 - rust (cargo)
 - exa - ls replacement [Installation](https://the.exa.website/install)
 - fzf [Installation](https://github.com/junegunn/fzf#installation) - NOTE neovim might install this for you in `~/.fzf` so check that first and `./install` from there

### Shell

 - ZSH - through your distribution's package manager
 - oh-my-zsh - [Installation](https://ohmyz.sh/#install)
 - Prompt: Spaceship - Follow the `oh-my-zsh` git clone instructions on [Spaceship - Getting Started](https://spaceship-prompt.sh/getting-started/)
 - Plugins: zsh-syntax-highlighting - [INSTALL.md](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md#oh-my-zsh)

### TMUX

This has only been tested on v2.6. (I'll upgrade to 3.x when you pay me to)

Install TPM

```
$ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Inside TMUX, run `prefix + I` to install plugins.

#### >3 Upgrade problems

```
/Users/jack/.tmux.conf:12: invalid option: status-attr
/Users/jack/.tmux.conf:16: invalid option: window-status-fg
/Users/jack/.tmux.conf:21: invalid option: window-status-current-fg
/Users/jack/.tmux.conf:26: invalid option: pane-border-fg
/Users/jack/.tmux.conf:27: invalid option: pane-active-border-fg
/Users/jack/.tmux.conf:30: invalid option: message-bg
/Users/jack/.tmux.conf:31: invalid option: message-fg
```

### NVIM

Install neovim nightly (>=0.8.1) and required packages
 - apt: silversearcher-ag
 - pip: neovim msgpack
 - github: bat@^0.18.0
 - snap: go

```
$ chmod u+x ./nvim.appimage
$ mv ./nvim.appimage ~/.local/bin/nvim
$ sudo apt install -y silversearcher-ag python3-pip
$ pip3 install neovim msgpack --upgrade
$ sudo snap install go --classic
$ <download and install github packages>
```

Once in vim, install the [language servers](https://github.com/kabouzeid/nvim-lspinstall#bundled-installers):

```
:LspInstall tsserver cssls yamlls clangd bashls html jsonls vimls arduino_language_server
...etc...

# This one is for linting
:LspInstall efm
```

#### LSP External Dependencies

A number of programs supplement LSP setup in either linting or formatting:
 - apt: shellshock
 - go: mvdan.cc/sh/v3/cmd/shfmt@latest

For `arduino_language_server`:
 - Set up the [arduino-cli](https://github.com/arduino/arduino-cli) - I set `BINDIR=~/.local/bin`
 - Add a [Makefile](https://github.com/jack828/esp32-logger/blob/arduino/Makefile) like this project
 - Run `make compile`, and it will use the output for LSP

#### NVIM 0.5 + Lua Issues

 - Prettier has a hissy fit when an IIFE is used and toggles formatting
 - Linting with `<leader>p` sometimes pastes in extra characters

#### LSP usage

`<CTRL>+<SPACE>` whilst in insert mode to show autocomplete.

Hover and press `K` to view definition

## Secrets

To use the `wp` function you'll need to copy `.secrets.tpl` to `.secrets` and edit accordingly.

## Statusline

This assumes the following files are available and match the format expected:

| File | Use |
|------|-----|
| /sys/class/power_supply/AC/online | `'1'` if AC is connected |
| /sys/class/power_supply/BAT0/capacity | Battery % |
| /sys/class/hwmon/hwmon5/temp1_input | CPU Temp (make sure this is the right one) |
| /proc/acpi/ibm/fan | Fan info, RPM on line 2 |
| /proc/net/dev_snmp6/wg0 | Used to infer VPN status, using WireGuard |

In addition to this you must be on Linux with:
  - a wireless driver compatible with:
    - ioctl `SIOCGIWESSID` to obtain ESSID
    - ioctl `SIOCGIWSTATS` to obtain signal level
  - A kernel that utilises `sys/sysinfo.h` correctly

If you want accurate sunrise/sunset clock colours, edit `LAT` and `LNG` in `statusline.c`.

## Cheatsheet

Awww sheet, you want to use my dotfiles?

### TMUX

`prefix` is set to `C-a`.

Plugins:
 - tmux-plugins/tpm (plugins)
 - tmux-plugins/tmux-sensible (sensible defaults)
 - tmux-plugins/tmux-resurrect (setup persistence pt 1)
 - tmux-plugins/tmux-continuum (setup persistence pt 2)
 - tmux-plugins/tmux-sessionist (session management)
 - tmux-plugins/tmux-pain-control (easy pane bindings)
 - christoomey/vim-tmux-navigator (vim & tmux navigation)

| Command | Action |
|---------|--------|
| `prefix + I` | Install plugins |
| `prefix + r` | Reload .tmux.conf |
| `prefix + g` | Switch session with fuzzy matcher |
| `prefix + s` | View session list |
| `prefix + S` | Swap to most recent session |
| `prefix + C` | Create new session |
| `prefix + c` | Create new window |
| `prefix + X` | Kill current session |
| `prefix + #` | Switch to window no. # (where # is a number) |
| `prefix + -` | Split window horizontally |
| `prefix + \|` | Split window vertically |
| `prefix + z` | Zoom/unzoom a pane |
| `prefix + C-s` | Save sessions |
| `prefix + C-r` | Restore sessions |
| `prefix + ` | todo... |
