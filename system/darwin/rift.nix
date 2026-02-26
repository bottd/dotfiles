{ username, ... }: {
  launchd.user.agents.rift = {
    command = "/opt/homebrew/bin/rift";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = {
        SuccessfulExit = false;
        Crashed = true;
      };
      StandardOutPath = "/tmp/rift_${username}.out.log";
      StandardErrorPath = "/tmp/rift_${username}.err.log";
      ProcessType = "Interactive";
      Nice = -20;
      EnvironmentVariables = {
        RUST_LOG = "error,warn,info";
      };
    };
  };
}
