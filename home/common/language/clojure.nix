{ pkgs
, ...
}: {
  home.packages = with pkgs; [
    clojure

    # project manager
    leiningen

    # format
    cljfmt

    # lint
    clj-kondo

    # scripting environment
    babashka

    # JSON processor
    jet
  ];
}

