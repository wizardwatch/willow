{ config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    ## HSCTF
    hping
    nmap
    masscan
    openvpn
    curlFull
    dig
    mitmproxy
    p0f
    hcxdumptool
    hcxtools
    bully
    aircrack-ng
    smbclient
    openssl
    hashcat
    john
    file
    exiftool
    hexdump
    binutils
    gdb-multitarget
    ghidra-bin
    burpsuite
    zap
    ruby
    perl
    python2Full
    thc-hydra
    gobuster
    rsync
    moreutils
    sqlmap
    metasploit
  ];
}
