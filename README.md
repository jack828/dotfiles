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

```
