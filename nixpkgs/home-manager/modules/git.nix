{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    userName = "Rakshan Shetty";
    userEmail = "shetty.raxx555@gmail.com";

    extraConfig = {
      core = {
        editor = "lvim";
        pager = "delta --syntax-theme=\"Nord\" --24-bit-color=\"always\" --file-style=\"#84a0c6\" --hunk-header-style=\"#84a0c6\" --plus-style=\"syntax #45493e\" --plus-emph-style=\"syntax #2C3025\" --minus-style=\"normal #53343b\" --minus-emph-style=\"normal #200108\"";
      };

      diff = {
        tool = "smerge";
      };

      difftool = {
        prompt = false;
        smerge = {
          trustExitCode = true;
          cmd = "smerge mergetool \"$LOCAL\" \"$REMOTE\"";
        };
      };

      merge = {
        tool = "smerge";
      };

      mergetool = {
        prompt = false;
        smerge = {
          trustExitCode = true;
          cmd = "smerge mergetool \"$LOCAL\" \"$BASE\" \"$REMOTE\" -o \"$MERGED\"";
        };
      };

      pull = {
        rebase = false;
      };

      rebase = {
        autoStash = true;
      };

      init = {
        defaultBranch = "main";
      };

      filter.lfs = {
        required = true;
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
      };
    };

    aliases = {
      # Pull
      up = "pull --rebase --autostash";

      # Reset
      unstage = "reset HEAD --";                    # Mixed reset (affects HEAD and Index)
      undo = "reset --soft HEAD~1";                 # Undo last commit (affects HEAD only)
      reset = "reset --hard HEAD~1";                # Remove last commit (from HEAD, Index and Working Dir)
    };

    ignores = [
      # Folder view configuration files
      ".DS_Store"
      "Desktop.ini"

      # Files that might appear on external disks
      ".Spotlight-V100"
      ".Trashes"

      # npm & bower
      "bower_components"
      "node_modules"
      "npm-debug.log"
      "yarn-debug.log"

      # IDEs stuff
      ".idea"
    ];
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
    extensions = [
      pkgs.gh-contribs
      pkgs.gh-notify
    ];
  };

  programs.gh-dash = {
    enable = true;
    settings = {
      smartFilteringAtLaunch = true;
      prSections = [
        {
          title = "My Pull Requests";
          filters = "is:open author:@me";
          type = null;
        }
        {
          title = "Needs My Review";
          filters = "is:open review-requested:@me";
          type = null;
        }
        {
          title = "Involved";
          filters = "is:open involves:@me -author:@me";
          type = null;
        }
      ];
      issuesSections = [
        {
          title = "My Issues";
          filters = "is:open author:@me";
        }
        {
          title = "Assigned";
          filters = "is:open assignee:@me";
        }
        {
          title = "Involved";
          filters = "is:open involves:@me -author:@me";
        }
      ];
      repo = {
        branchesRefetchIntervalSeconds = 30;
        prsRefetchIntervalSeconds = 60;
      };
      defaults = {
        prsLimit = 20;
        prApproveComment = "LGTM";
        issuesLimit = 20;
        view = "prs";
      };
    };
  };
}
