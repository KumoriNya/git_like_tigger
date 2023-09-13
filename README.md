# git_like_tigger
Constructing Tigger provided a chance to practice Shell programming and to have a concrete understanding of Git's core semantics.

Commands covered:
  Subset 0:
    tigger-init
    tigger-add <filenames>
    tigger-commit -m <message>
    tigger-log
    tigger-show <commit:filename>

  Subset 1:
    tigger-commit [-a] -m <message>
    tigger-rm [--force] [--cached] <filenames>
    tigger-status

Commands not covered:
  tigger-branch [-d] <branch-name>
  tigger-checkout <branch-name>
  tigger-merge <branch-name|commit> -m <message>