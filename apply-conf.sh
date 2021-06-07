#!/bin/sh
nix build .#homeManagerConfigurations.wyatt.activationPackage
./result/activate
