{ ...
}: {
  imports = [
    ./configuration.nix

    ../../system/base
    ../../system/common/linux
    ../../system/users
  ];
}
