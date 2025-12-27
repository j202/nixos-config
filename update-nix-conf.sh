#!/usr/bin/env bash

mkdir -p ~/.config/nix
chmod 755 ~/.config/nix

cp ~/nixos-config/nix.conf ~/.config/nix/nix.conf
chmod 744 ~/.config/nix/nix.conf

sudo cp ~/nixos-config/nix.conf /etc/nixos/nix.conf
sudo chown root:root /etc/nixos/nix.conf
sudo chmod 644 /etc/nixos/nix.conf

sudo systemctl restart nix-daemon
