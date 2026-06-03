# dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
├── zsh/          # .zshrc, .p10k.zsh
├── bash/         # .bashrc, .bash_logout, .profile
├── git/          # .gitconfig
├── ssh/          # .ssh/config (no private keys!)
├── npm/          # .npmrc
├── install.sh    # Bootstrap script
└── README.md
```

Each directory is a stow "package" — its contents mirror `$HOME`.

## Usage

### Fresh install

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
bash install.sh
```

### Add a new dotfile

```bash
# Move the file into the right package
mkdir -p ~/dotfiles/<package>/<subpath>
mv ~/.newconfig ~/dotfiles/<package>/.newconfig

# Re-stow to create the symlink
stow <package>

# Commit
git add -A && git commit -m "Add newconfig"
```

### Unlink a package

```bash
stow -D <package>   # remove symlinks, keep files in repo
```

### Re-link after pulling

```bash
bash install.sh
```

## Notes

- `stow --adopt` moves existing real files into the repo (adopted on first run)
- Private keys (e.g. `~/.ssh/id_ed25519`) are **never** committed
