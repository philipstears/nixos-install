{ pkgs, ... }:

{
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
        pager = "less -F -X";
      };
    };
  };
}

