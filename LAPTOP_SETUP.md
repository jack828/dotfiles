# Laptop Setup

For when I get a new laptop and have no idea how to set anything I wanted up again

 - Swap FN and CONTROL in BIOS
 - Swap CONTROL and ALT in gnome-tweak - `Keyboard & Mouse` -> `Ctrl position` -> `Swap Left Alt with Left Ctrl`
 - Remap CAPSLOCK to ESCAPE in gnome-tweak - `Keyboard & Mouse` -> `Caps Lock behaviour` -> `Make Caps Lock an additional Esc` **REBOOT AFTER THIS**
 - Install kitty https://sw.kovidgoyal.net/kitty/binary/ and do the **Desktop Integration on Linux** instructions
 - Copy SSH key across (I know this is bad practice shhhh) - entire ~/.ssh folder
 - copy updatesshconfig command
 - Copy GPG files across - entire ~/.gnupg folder
 - Install tmux and set it up (see dotfiles) - copy over sessions ~/.tmux/resurrect
 - Clone and setup dotfiles repo
 - setup nave - `wget http://github.com/isaacs/nave/raw/main/nave.sh chmod +x ./nave.sh && mv nave.sh ~/.local/bin/nave`
 - purge inactive search entries in chrome (cos they're useless) https://superuser.com/a/1154955/1744868
 - Setup mongo version manager `wget https://raw.githubusercontent.com/aheckmann/m/master/bin/m && chmod +x ./m && mv ./m ~/.local/bin`

## APT packages

 - tmux
 - gnome-tweak
 - git
 -
