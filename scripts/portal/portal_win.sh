  #cd ~;
  if [ ! -f startetrobo ]; then
    if [ -n "$ETROBO_ROOT" ]; then
        proxy="$ETROBO_ROOT/scripts/proxy.sh";
        if [ -f "$proxy" ]; then
            . "$proxy";
        fi;
    fi;
    url=https://raw.githubusercontent.com/ETrobocon/etrobo/master/scripts/startetrobo;
    wget -t 1 --no-hsts $url;
    if [ $? -eq 4 ]; then
      echo "** network error **";
      read -p "Do you have to use a network over HTTP PROXY? (Y/n): " yn;
      if [ "$yn" = "n" ] || [ "$yn" = "N" ]; then
        echo ;
        echo "** DOWNLOAD FAILED **"
        echo "etrobo package needs a network access.";
        echo "plaese check your network access and try again later"
        exit 1;
      fi;
      echo "Enter <HTTP_PROXY_SERVER_NAME>:<PORT_NUMBER>";
      read -p "(e.g. proxyserver:8080 ) : " proxy;
      export http_proxy=http://$proxy;
      export https_proxy=$http_proxy;
      wget -t 1 --no-hsts $url;
      if [ $? -eq 4 ]; then
        read -p "Enter your userID for HTTP PROXY : " userID;
        read -sp "Enter your password for HTTP PROXY : " password;
        echo;
        export http_proxy=http://${userID}:${password}@${proxy};
        export https_proxy=$http_proxy;
        wget -t 1 --no-hsts $url;
        if [ $? -eq 4 ]; then
          echo;
          echo "** DOWNLOAD FAILED **"
          echo "etrobo package needs a network access.";
          echo "please ask your organization's network administrator!";
          exit 1;
        fi;
      fi;
    fi;
    chmod +x startetrobo;
  fi;
  echo ./startetrobo
