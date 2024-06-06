# NixOS Configurations

These are my NixOS configuration files using Hyprland, Waybar, Hyprlock, Wlogout, and more. Please note that these configurations are still a work in progress and not all programs configurations are being declared in the nixos config. Additionally powerlevel10k for zsh is using a workaround that sources a config every time that zsh is started.

## Installation

To use these configurations, follow these steps:

1. Clone this repository:

    ```bash
    git clone <repository-url>
    ```

2. Symlink the desired configuration files to your NixOS system:

    ```bash
    sudo ln -s <repository-path>/* /etc/nixos/
    ```

3. Configure Hyprland by editing the `.config/hyprland.conf` file.

4. Edit the `/etc/nixos/configuration.nix` file to include the desired configurations:

    ```nix
    imports = [
      # ...
      /etc/nixos/<configuration-file>.nix
    ];
    ```

5. Apply the changes by running:

    ```bash
    sudo nixos-rebuild switch
    ```

## Contributing

Feel free to contribute to this repository by submitting pull requests or opening issues.