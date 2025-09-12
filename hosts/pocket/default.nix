{ ...
}: {
  imports = [
    ./configuration.nix
    ./optimizations.nix
    ../../system/base
    ../../system/common
    ../../system/users
  ];
}
