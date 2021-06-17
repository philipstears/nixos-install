# vim: set sts=2 ts=2 sw=2 expandtab :

{ pkgs, ... }:

let
  extensions = (with pkgs.vscode-extensions; [
    # ms-dotnettools.csharp
  ])
  ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
    name = "csharp";
    publisher = "ms-dotnettools";
    version = "1.23.2";
    sha256 = "0ydaiy8jfd1bj50bqiaz5wbl7r6qwmbz9b29bydimq0rdjgapaar";
  }];

  vscode-with-extensions = pkgs.vscode-with-extensions.override {
    vscodeExtensions = extensions;
  };
in
  {
    home.packages = with pkgs; [
      vscode-with-extensions
    ];
  }

