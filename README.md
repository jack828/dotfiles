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


```
$ ./bin/setup
```

## Statusline

This assumes the following files are available and match the format expected:

| File | Use |
|------|-----|
| /sys/class/power_supply/AC/online | `'1'` if AC is connected |
| /sys/class/power_supply/BAT0/capacity | Battery % |
| /sys/class/hwmon/hwmon1/temp1_input | CPU Temp (one core is good enough) |
| /proc/loadavg | Load averages, only 1 min is used |
| /proc/meminfo | Memory usage - expects Total mem on line 1, available on line 3 |
| /proc/acpi/ibm/fan | Fan info, RPM on line 2 |
| /proc/net/dev_snmp6/wg0 | Used to infer VPN status, using WireGuard |


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
| `prefix + ` | todo... |
