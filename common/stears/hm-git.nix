{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gitAndTools.delta
  ];

  programs.git = {
    enable = true;
    userName  = "philipstears";
    userEmail = "philip@philipstears.com";
    signing = {
      signByDefault = true;
      key = "FA836504B26D139A";
    };
    ignores = [
      "tags"
    ];
    extraConfig = {
      core = {
        pager = "${pkgs.gitAndTools.delta}/bin/delta";
      };
      interactive = {
        diffFilter = "${pkgs.gitAndTools.delta}/bin/delta --color-only";
      };
    };
    lfs = {
      enable = true;
    };
  };
}

