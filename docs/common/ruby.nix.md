---
title: ruby.nix
---
```nix
{config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    (ruby_3_0.override{jitSupport = true;})
    bundix
    rubyPackages_3_0.solargraph
  ];
}
```
