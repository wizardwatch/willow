#!/bin/sh
nix build -v .#homeManagerConfigurations.wyatt.activationPackage
./result/activate
