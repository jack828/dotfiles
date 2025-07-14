# dotfiles

Some stolen from:
 - [balaclark](https://github.com/balaclark/dotfiles)
 - [benjaminparnell](https://github.com/benjaminparnell/dotfiles)
 - [asheboy](https://github.com/Asheboy/dotfiles)

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

 - Font: FiraCode Nerd Font [Nerd Fonts](https://www.nerdfonts.com/) - put files in `~/.local/share/fonts`
 - go (apt is probably good enough)
 - rust (for cargo) - [Installation](https://rustup.rs/)
 - eza - ls replacement [Installation](https://eza.rocks/) (exa is unmaintained ~~exa - ls replacement [Installation](https://the.exa.website/install)~~)
 - fzf [Installation](https://github.com/junegunn/fzf#installation) - NOTE neovim might install this for you in `~/.fzf` so check that first and `./install` from there
 - pip `sudo apt install python3-pip`

### Shell

 - ZSH - through your distribution's package manager
 - oh-my-zsh - [Installation](https://ohmyz.sh/#install)
 - Prompt: Spaceship - Follow the `oh-my-zsh` git clone instructions on [Spaceship - Getting Started](https://spaceship-prompt.sh/getting-started/)
 - Plugins: zsh-syntax-highlighting - [INSTALL.md](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md#oh-my-zsh)
 - tmux - >=3.4 - apt is fine

### Programs

 - Kitty - [Installation](https://sw.kovidgoyal.net/kitty/binary/#binary-install), then follow the [Desktop Integration for Linux](https://sw.kovidgoyal.net/kitty/binary/#desktop-integration-on-linux)
 - gnome-tweaks (apt install) - Keyboard -> Additional Layout Options
   - -> Caps Lock Behaviour -> Make Caps Lock an additional Esc
   - -> Ctrl Position -> Swap Left Alt with Left Ctrl
   - -> Key sequence to kill the X server -> untick
 - If using budgie, make it so workspaces are across all monitors `gsettings set org.gnome.mutter workspaces-only-on-primary false`
 - Lazygit [Installation](https://github.com/jesseduffield/lazygit#installation) (use "pull from github releases" if below 25.04)
 - Docker [Use the script](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script)
 - VLC - apt install
 - Obsidian [Installation](https://help.obsidian.md/install) - flatpack was used last time
 - Mullvad VPN [Installation](https://mullvad.net/en/download/vpn/linux)
 - Flameshot [Download](https://flameshot.org/#download)
   - Download appimage, chmod, move to `~/.local/bin/flameshot`
   - Disable screenshot keyboard shortcuts
   - Add custom shortcut `/home/jack/.local/bin/flameshot gui`
 - xclip
 - Android SDK
   - Download the [command line tools](https://developer.android.com/studio#command-line-tools-only)
   - Extract to `/home/jack/android-sdk`, so that the structure is like `/home/jack/android-sdk/cmdline-tools/latest/bin/sdkmanager`
   - Run `$ANDROID_HOME/cmdline-tools/bin/sdkmanager --licenses`
   - Run `$ANDROID_HOME/cmdline-tools/bin/sdkmanager "platform-tools" "platforms;android-33" "build-tools;30.0.3"`
 - yarn [Installation](https://classic.yarnpkg.com/lang/en/docs/install/#debian-stable), make sure to use `--no-install-recommends` to prevent nodejs package installed - handled with nave
 - Java 18
   - download OpenJDK 18 from the archive <https://jdk.java.net/archive/>
 `wget https://download.java.net/java/GA/jdk18.0.2/f6ad4b4450fd4d298113270ec84f30ee/9/GPL/openjdk-18.0.2_linux-x64_bin.tar.gz`
   - `tar xvf openjdk-18.0.2_linux-x64_bin.tar.gz`
   - `sudo mv jdk-18.0.2 /usr/lib/jvm/java-18-openjdk-amd64`


### TMUX

Now with >=3.4 support! When transferring, do **NOT** copy `~/.tmux/plugins`, only the `~/.tmux/resurrect` directory!

Install TPM

```
$ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Inside TMUX, run `prefix + I` to install plugins.

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

Once in vim, the language servers should be installed automatically. If not, refer to `lsp.lua`, and manually install using:

```
:LspInstall tsserver cssls yamlls clangd bashls html jsonls vimls arduino_language_server
...etc...

# This one is for linting
:LspInstall efm
```

#### LSP External Dependencies

A number of programs supplement LSP setup in either linting or formatting:
 - apt: shellcheck
 - go: mvdan.cc/sh/v3/cmd/shfmt@latest

For `arduino_language_server`:
 - Set up the [arduino-cli](https://github.com/arduino/arduino-cli) - I set `BINDIR=~/.local/bin`
 - Add a [Makefile](https://github.com/jack828/esp32-logger/blob/arduino/Makefile) like this project
 - Run `make compile`, and it will use the output for LSP

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
| `prefix + [` | Swap split right |
| `prefix + ]` | Swap split left |
| `prefix + ` | todo... |
