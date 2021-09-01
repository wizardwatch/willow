#!/bin/sh
nix build -v .#homeManagerConfigurations.wyatt.activationPackage --show-trace
bash ./result/activate
