#!/bin/sh
nix build -v .#homeManagerConfigurations.wyatt.activationPackage 
bash ./result/activate
