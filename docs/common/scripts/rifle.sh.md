---
title: rifle.sh
---
```
set -l a
read line
set a $a $line
fish ( kitty -e rifle "$a" & ) &
```
