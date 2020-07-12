wsl ^
  cd ~^; ^
  if [ ^! -f startetrobo ]^; then ^
    url=https://raw.githubusercontent.com/ETrobocon/etrobo/master/scripts/startetrobo^; ^
    wget -t 3 --no-hsts $url^; ^
    if [ $? -eq 4 ]^; then ^
      echo ** network error **^; ^
      read -p ^"Do you have to use a network over HTTP PROXY? (Y/n): ^" yn^; ^
      if [ ^"$yn^" = ^"n^" ] ^|^| [ ^"$yn^" = ^"N^" ]^; then ^
        exit 1^; ^
      fi^; ^
      echo ^"Enter <HTTP_PROXY_SERVER_NAME>:<PORT_NUMBER>^"^; ^
      read -p ^"(e.g. proxyserver:8080 ) : ^" proxy^; ^
      export http_proxy=http://$proxy^; ^
      export https_proxy=$http_proxy^; ^
      wget -t 3 --no-hsts $url^; ^

      fi^; ^
    fi^; ^
    chmod +x startetrobo^; ^
  fi^; ^
  ./startetrobo
