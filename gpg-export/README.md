# GPG Key Transfer

This folder is for temporarily storing GPG keys to transfer between machines.

**IMPORTANT:** The `.key` files are gitignored and should NEVER be committed.

## Transfer Keys to Mac

### Option 1: USB Drive
1. Copy `public.key` and `private.key` to a USB drive
2. Transfer to Mac
3. Delete from USB after import

### Option 2: Secure Copy (if both machines are on same network)
```bash
# From Mac, copy from WSL:
scp user@wsl-ip:~/dotfiles/gpg-export/*.key ~/dotfiles/gpg-export/
```

### Option 3: Temporary cloud storage
1. Upload to a secure, private location
2. Download on Mac
3. Delete from cloud immediately after

## Import Keys on Mac

```bash
# Import public key
gpg --import ~/dotfiles/gpg-export/public.key

# Import private key (requires passphrase)
gpg --import ~/dotfiles/gpg-export/private.key

# Trust the key
gpg --edit-key E68B63B4
# Type: trust
# Select: 5 (ultimate trust)
# Type: quit

# Verify
gpg --list-keys
```

## After Import

Delete the key files from both machines:
```bash
rm ~/dotfiles/gpg-export/*.key
```
