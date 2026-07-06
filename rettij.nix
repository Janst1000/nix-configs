{ config, lib, pkgs, ... }:

let
  # Native libs that rettij's pip wheels dlopen at runtime — fed to nix-ld
  # as a safety net.
  runtimeLibs = with pkgs; [
    stdenv.cc.cc.lib   # libstdc++ / libgcc_s
    zlib
    zstd
    openssl
    libffi
    bzip2
    xz
  ];
in
{
  # Single-node k3s, configured how rettij wants it.
  services.k3s = {
    enable = true;
    role = "server";
    # rettij's config.yaml disables these three. 644 lets your normal user
    # read the kubeconfig without sudo.
    extraFlags = lib.concatStringsSep " " [
      "--disable=traefik"
      "--disable=servicelb"
      "--disable=metrics-server"
      "--write-kubeconfig-mode=644"
    ];
  };

  # rettij builds VXLAN tunnels inside privileged pods.
  boot.kernelModules = [ "vxlan" "br_netfilter" ];

  # Safety net so pip wheels that ship ELF binaries find an interpreter.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = runtimeLibs;

  environment.systemPackages = [ pkgs.kubectl ];

  environment.sessionVariables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
}
