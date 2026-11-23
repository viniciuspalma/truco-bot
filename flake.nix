{
  description = "Truco bot configuration's flake";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = {
    self,
    nixpkgs,
  }: let
    overlays = [
      (final: prev: {
        ruby = prev.ruby_4_0;
      })
    ];
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {inherit overlays system;};
        });
    # Keep gems inside the project so the shell never touches the Nix store
    # or a global GEM_HOME.
    rubyShellHook = ''
      export GEM_HOME="$PWD/.gems"
      export BUNDLE_PATH="$GEM_HOME"
      export PATH="$GEM_HOME/bin:$PATH"
    '';
  in {
    packages = forEachSupportedSystem ({pkgs}: let
      rubyShell = pkgs.mkShell {
        packages = with pkgs; [
          ruby
        ];

        shellHook = rubyShellHook;
      };
    in {
      default = rubyShell;

      # Used by GitHub Actions: `nix develop .#github --command ...`
      github = rubyShell;
    });
  };
}
