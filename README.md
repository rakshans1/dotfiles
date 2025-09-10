# My Dotfiles

Include ZSH, oh-my-zsh and new ubuntu new system setup

![Shell ScreenShot](shell.png?raw=true "Shell")

## Installation

```
cd ~ && git clone https://github.com/rakshans1/dotfiles.git
git submodule init
git submodule update
```

To install my dotfiles as _your_

```
cd ~/dotfiles
./setup.sh
```

or to setup new machine

```
./setup-new-machine.sh
```

##### Update Submodules

```sh
git submodule foreach git pull origin master
```
