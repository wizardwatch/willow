---
title: lsp.nix
---
```nix
{config, pkgs, ...}:{
  environment.systemPackages = with pkgs; [
    rnix-lsp
  ];
}
```
