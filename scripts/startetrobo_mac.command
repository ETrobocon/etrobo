#!/bin/bash
export BEERHALL_VER="5.30d.250628"
echo
echo "------------"
echo " jtBeerHall - an implementation of Homebrew sandbox"
echo "------------"
echo " as 'startetrobo_mac.command' Ver $BEERHALL_VER"
# Copyright (c) 2020-2025 jtLab, Hokkaido Information University
# by TANAHASHI, Jiro(aka jtFuruhata) <jt@do-johodai.ac.jp>
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php
#

if [ "$1" = "update" ]; then
    shift
    if [ -z "$BEERHALL" ]; then
        BEERHALL="$(cd "$(dirname "$0")"; pwd)/BeerHall"
    fi
    if [ "$1" = "BeerHall" ]; then
        shift
        echo "update BeerHall Cellar:"
        makeBeerHall="update"
    else
        echo "update BeerHall invoker:"
        target="$BEERHALL/etrobo/scripts/startetrobo_mac.command"
        if [ -f "$target" ]; then
            cp -f "$target" ./
        fi
        makeBeerHall="rebuild"
    fi
    rm -f "$BEERHALL/BeerHall"
fi

if [ "$1" = "clean" ]; then
    shift
    if [ -z "$BEERHALL" ]; then
        BEERHALL="$(cd "$(dirname "$0")"; pwd)/BeerHall"
    fi
    if [ -d "$BEERHALL/usr/local/opt/flex/lib" ]; then
        ls $BEERHALL/usr/local/opt/flex/lib |
        while read line; do
            sudo rm -f "/usr/local/lib/$line"
            if [ -e "/usr/local/lib/$line.BeerHallTmp" ]; then
                sudo mv "/usr/local/lib/$line.BeerHallTmp" "/usr/local/lib/$line"
            fi
        done
    fi

    sudo rm -f /etc/bashrc_BeerHall

    targetFile=/etc/bashrc_vscode
    sudo touch $targetFile
    unset removeFlag
    bashrc=$(mktemp)
    cat $targetFile | 
    while IFS= read -r line; do
        if [ -z "$removeFlag" ]; then
            if [ -n "`echo $line | grep jtBeerHall`" ]; then
                removeFlag="remove"
            else
                echo "$line" >> $bashrc
            fi
        else
            if [ -n "`echo $line | grep jtBeerHall`" ]; then
                unset removeFlag
            fi
        fi
    done
    sudo rm -f $targetFile
    if [ -s $bashrc ]; then
        sudo mv -f $bashrc $targetFile
    else
        rm $bashrc
    fi

    if [ -n "$HOME_ORG" ]; then
        HOME="$HOME_ORG"
    fi
    targetFile="$HOME/.bash_profile"
    touch $targetFile
    unset removeFlag
    bashrc=$(mktemp)
    cat "$targetFile" | 
    while IFS= read -r line; do
        if [ -z "$removeFlag" ]; then
            if [ -n "`echo $line | grep jtBeerHall`" ]; then
                removeFlag="remove"
            else
                echo "$line" >> $bashrc
            fi
        else
            if [ -n "`echo $line | grep jtBeerHall`" ]; then
                unset removeFlag
            fi
        fi
    done
    sudo rm -f "$targetFile"
    if [ -s $bashrc ]; then
        sudo mv -f $bashrc "$targetFile"
    else
        rm $bashrc
    fi

    targetFile="$HOME/.zprofile"
    touch "$targetFile"
    unset removeFlag
    bashrc=$(mktemp)
    cat "$targetFile" | 
    while IFS= read -r line; do
        if [ -z "$removeFlag" ]; then
            if [ -n "`echo $line | grep jtBeerHall`" ]; then
                removeFlag="remove"
            else
                echo "$line" >> $bashrc
            fi
        else
            if [ -n "`echo $line | grep jtBeerHall`" ]; then
                unset removeFlag
            fi
        fi
    done
    sudo rm -f "$targetFile"
    if [ -s $bashrc ]; then
        sudo mv -f $bashrc "$targetFile"
    else
        rm $bashrc
    fi

    sudo rm -rf "$BEERHALL"
    unset BEERHALL
    echo "Please restart terminal to unset env vars."
    exit 0
fi

if [ -z "$BEERHALL" ]; then
    echo "check the Xcode installation:"
    echo "when after install the Xcode Command Line Tools,"
    echo '  you should reboot your Mac and run `Start ETrobo.command` again.'
    echo
    echo "if you get an error on below," 
    echo "  your environment is *GOOD* for create a new BeerHall."
    xcode-select --install
    if [ $? -eq 0 ]; then
        exit 0
    fi        

    echo
    echo "try to create a new BeerHall"

    if [ -z "$1" ]; then
        hallName="BeerHall"
    else
        hallName="$1"
        shift
    fi

    pwd="$(cd "$(dirname "$0")"; pwd)"

    if [ -e "$pwd/$hallName" ]; then
        echo "'$pwd/$hallName' already exists. please delete it or use other name or"
        read -p "Overwrite? (y/N): " yn
        case "$yn" in
            [yY]*) rm -rf "$pwd/$hallName";;
            *)     exit 1;;
        esac
    fi

    profile="$HOME/.bash_profile"
    touch "$profile"
    echo
    echo "add \$BEERHALL env var to $profile" 
    export BEERHALL="$pwd/$hallName"
    if [ -z "`cat $profile 2>&1 | grep BEERHALL`" ]; then
        echo "envvar named 'BEERHALL' is added into $profile"
        echo "# ----- this section was added by jtBeerHall -----" >> $profile
        echo "export BEERHALL=\"$BEERHALL\"" >> $profile
        echo "# ------------------------------- jtBeerHall end -" >> $profile
    fi
    profile="$HOME/.zprofile"
    touch "$profile"
    echo
    echo "add \$BEERHALL env var to $profile" 
    export BEERHALL="$pwd/$hallName"
    if [ -z "`cat $profile 2>&1 | grep BEERHALL`" ]; then
        echo "envvar named 'BEERHALL' is added into $profile"
        echo "# ----- this section was added by jtBeerHall -----" >> $profile
        echo "export BEERHALL=\"$BEERHALL\"" >> $profile
        echo "# ------------------------------- jtBeerHall end -" >> $profile
    fi

    bashrc="/etc/bashrc_BeerHall"
    echo "add $bashrc"
    echo 'if [ -z "$BEERHALL_INVOKER" ]; then' | sudo tee $bashrc
    echo '    . "$BEERHALL/BeerHall"' | sudo tee -a $bashrc
    echo 'else' | sudo tee -a $bashrc
    echo '    . "$BEERHALL/BeerHall" setpath' | sudo tee -a $bashrc
    echo 'fi' | sudo tee -a $bashrc

    bashrc="/etc/bashrc_vscode"
    sudo touch $bashrc
    echo "add $bashrc"
    if [ -z "`cat $bashrc 2>&1 | grep BEERHALL`" ]; then
        echo "'BEERHALL_INVOKER' event is added into $bashrc"
        echo '# ----- this section was added by jtBeerHall -----' | sudo tee -a $bashrc
        echo 'if [ "$BEERHALL_INVOKER" = "ready" ]; then' | sudo tee -a $bashrc
        echo '    . "$BEERHALL/BeerHall" setpath' | sudo tee -a $bashrc
        echo 'fi' | sudo tee -a $bashrc
        echo "# ------------------------------- jtBeerHall end -" | sudo tee -a $bashrc
    fi

    echo "make symbolic link"
    mkdir -p "$BEERHALL/usr/local"
    cd "$BEERHALL"
    ln -s "$HOME/.gitconfig" .gitconfig
    ln -s "$HOME/.ssh" .ssh
    ln -s "$HOME/.vscode" .vscode
    ln -s "$HOME/Applications" Applications
    ln -s "$HOME/Library" Library

    echo "install HomeBrew, please wait about an hour"
    cd "$BEERHALL/usr"
    curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C local
    makeBeerHall="install"
fi

export HOMEBREW_PREFIX="$BEERHALL/usr/local"
export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
export HOMEBREW_CACHE="$HOMEBREW_PREFIX/cache"
if [ -z "`echo $PATH | grep $HOMEBREW_PREFIX/bin`" ]; then
    export PATH="$HOMEBREW_PREFIX/bin:$PATH"
fi

if [ "$makeBeerHall" = "install" ] || [ "$makeBeerHall" = "update" ]; then
    brew update
    brew upgrade

    # install BeerHall (for etrobo) formulae

    brew install pkgconf            # for ncurses
    brew install ncurses            # for bash (keg only)
    brew link --force ncurses
    brew install bash
    brew install bash-completion@2

    brew install gmp                # for coreutils
    brew install coreutils  
    brew install findutils

    brew install libunistring       # for gettext
    brew install gettext            # for wget
    brew install libidn2            # for wget
    brew install ca-certificates    # for wget
    brew install openssl@3          # for wget
    brew install wget

    brew install pcre2              # for git
    brew install git

    brew install libyaml            # for ruby@3.2
    brew install readline           # for ruby@3.2 (keg only)
    brew link --force readline
    brew install m4                 # for ruby@3.2 (keg only)
    brew link --force m4
    brew install autoconf           # for ruby@3.2
    brew install bison              # for ruby@3.2 (keg only)
    brew link --force bison
    brew install libssh2            # for ruby@3.2
    brew install libgit2            # for ruby@3.2
    brew install mpdecimal          # for ruby@3.2
    brew install sqlite             # for ruby@3.2 (keg only)
    brew link --force sqlite
    brew install xz                 # for ruby@3.2
    brew install python@3.13        # for ruby@3.2
    brew install z3                 # for ruby@3.2
    brew install lz4                # for ruby@3.2
    brew install zstd               # for ruby@3.2
    brew install llvm               # for ruby@3.2
    brew install rust               # for ruby@3.2
    brew install ruby@3.2                         #(keg only)
    brew link --force ruby@3.2

    brew install berkeley-db@5      # for flex (keg only)
    brew link --force berkeley-db@5
    brew install gdbm               # for flex
    brew install perl               # for flex
    brew install help2man           # for flex
    brew install flex                         #(keg only)
    brew link --force flex

    brew install lzip               # for make
    brew install make

    brew install oniguruma          # for jq
    brew install jq

    brew install brotli             # for curl
    brew install libnghttp2         # for curl
    brew install rtmpdump           # for curl
    brew install curl                         #(keg only)
    brew link --force curl

    brew install esolitos/ipa/sshpass iproute2mac
    gem install shell -E

    # install additional kegs for athrill-gcc-package-mac_arm64
    if [ "`uname -m`" = "arm64" ]; then
        packages="gmp mpfr libmpc isl cloog"
        for package in $packages; do
            brew install $package
            if [ ! -e "/opt/homebrew/opt/$package/lib" ]; then
                sudo mkdir -p /opt/homebrew/opt/$package
                echo "make symbolic link from /opt/homebrew/opt/$package/lib to \$HOMEBREW_PREFIX/lib"
                sudo ln -s "$HOMEBREW_PREFIX/lib" /opt/homebrew/opt/$package/lib
            fi
        done
    fi

    gnupath="/Users/jt/BeerHall/usr/local/opt/make/libexec/gnubin"
    gnupath="$gnupath:/Users/jt/BeerHall/usr/local/opt/coreutils/libexec/gnubin"
    gnupath="$gnupath:/Users/jt/BeerHall/usr/local/opt/findutils/libexec/gnubin"

    cd "$HOMEBREW_PREFIX/bin"
fi

# check and install modifiers
if [ ! -f "$HOMEBREW_PREFIX/bin/code" ]; then
    echo "make aliase to code"
    echo "\"/usr/local/bin/code\" \"\$@\"" > "$HOMEBREW_PREFIX/bin/code"
    chmod +x "$HOMEBREW_PREFIX/bin/code"
fi

if [ ! -L "$BEERHALL/etc" ]; then
    echo "make symbolic link from \$BEERHALL/etc to \$HOMEBREW_PREFIX/etc"
    ln -s "$HOMEBREW_PREFIX/etc" "$BEERHALL/etc"
fi

if [ ! "`ls /usr/local/lib/libfl*`" ]; then
    echo "make symbolic link from /usr/local/lib to flex/lib"
    ls $HOMEBREW_PREFIX/opt/flex/lib |
    while read line; do
        if [ -e "/usr/local/lib/$line" ]; then
            if [ ! -e "/usr/local/lib/$line.BeerHallTmp" ]; then
                sudo mv "/usr/local/lib/$line" "/usr/local/lib/$line.BeerHallTmp"
            else
                sudo rm "/usr/local/lib/$line"
            fi
        fi
        sudo mkdir -p /usr/local/lib
        sudo cp -f "$HOMEBREW_PREFIX/opt/flex/lib/$line" "/usr/local/lib/"
    done
fi

# make the `BeerHall` script 
if [ -n "$makeBeerHall" ]; then
    echo "make BeerHall"
    beer=$(mktemp)
    echo '#!/usr/bin/env bash' > $beer
    echo 'if [ -z "$BEERHALL_INVOKER" ]; then' >> $beer
    echo '    export HOME_ORG="$HOME"' >> $beer
    echo '    export BEERHALL_INVOKER="booting"' >> $beer
    echo 'fi' >> $beer
    echo "export BEERHALL=\"$BEERHALL\"" >> $beer
    echo "export BEERHALL_VER=\"$BEERHALL_VER\"" >> $beer
    echo 'export HOMEBREW_PREFIX="$BEERHALL/usr/local"' >> $beer
    echo 'export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"' >> $beer
    echo 'export HOMEBREW_CACHE="$HOMEBREW_PREFIX/cache"' >> $beer
    echo 'export HOMEBREW_SVN="$HOMEBREW_PREFIX/bin/svn"' >> $beer
    echo 'export HOMEBREW_TEMP="/tmp"' >> $beer
    echo 'export BEERHALL_BIN="$HOMEBREW_PREFIX/bin"' >> $beer
    echo 'export BEERHALL_MAKE="$HOMEBREW_PREFIX/opt/make/libexec/gnubin"' >> $beer
    echo 'export BEERHALL_CORE="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin"' >> $beer
    echo 'export BEERHALL_FIND="$HOMEBREW_PREFIX/opt/findutils/libexec/gnubin"' >> $beer
    echo 'export BEERHALL_RUBY="$HOMEBREW_PREFIX/opt/ruby@2.5/bin"' >> $beer
    echo 'export BEERHALL_PATH_TO_BIN="$BEERHALL_MAKE:$BEERHALL_CORE:$BEERHALL_FIND:$BEERHALL_RUBY:$BEERHALL_BIN"' >> $beer
    echo 'export BEERHALL_DARWIN_VER=`uname -a | sed -E "s/^.*Darwin Kernel Version (.*): .*$/\1/"`' >> $beer
    echo 'export BEERHALL_ARCH="x86_64-apple-darwin$BEERHALL_DARWIN_VER"' >> $beer
    #echo 'export BEERHALL_GCC_VER_FULL=`gcc --version | head -n 1 | sed -E "s/^.*GCC (.*)\).*$/\1/"`' >> $beer
    #echo 'export BEERHALL_GCC_VER="${BEERHALL_GCC_VER_FULL:0:5}"' >> $beer
    #echo 'export BEERHALL_GCC_VER_MAJOR=`echo "$BEERHALL_GCC_VER" | sed -E "s/^(.*)\..*\..*$/\1/"`' >> $beer
    echo 'export HOME="$BEERHALL"' >> $beer
    echo 'export SHELL="$HOMEBREW_PREFIX/bin/bash"' >> $beer
    echo 'export PATH="$BEERHALL:$BEERHALL_PATH_TO_BIN:/usr/bin:/bin:/usr/sbin:/sbin"' >> $beer
    echo 'export BEERHALL_PATH="$PATH"' >> $beer
    echo 'export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"' >> $beer
    echo 'export TERM_PROGRAM="BeerHall"' >> $beer
    echo "export TERM_PROGRAM_VERSION=\"$BEERHALL_VER\"" >> $beer
    echo '' >> $beer
    echo 'if [ "$1" != "setpath" ]; then' >> $beer
    echo '    echo "Welcome, you are in jtBeerHall - an implementation of Homebrew sandbox"' >> $beer
    echo 'fi' >> $beer
    echo '' >> $beer
    echo 'tmpFile=$(mktemp)' >> $beer
    echo "ls -lFa \"\$BEERHALL/etc/profile.d\" | grep -v / | sed -e '1d' | sed -E 's/^.* (.*$)/\\1/' > \$tmpFile" >> $beer
    echo 'while read line; do' >> $beer
    echo '    . "$BEERHALL/etc/profile.d/$line"' >> $beer
    echo 'done < $tmpFile' >> $beer
    echo 'rm $tmpFile' >> $beer
    echo '' >> $beer
    echo 'if [ "$1" != "setpath" ]; then' >> $beer
    echo '    export BEERHALL_INVOKER="ready"' >> $beer
    echo '    cd "$HOME"' >> $beer
    echo '    if [ -n "$1" ]; then' >> $beer    
    echo '        echo "bash on BeerHall is invoked by params: $@"' >> $beer
    echo '        bash -c "$@"' >> $beer
    echo '    else' >> $beer
    echo '        bash -l' >> $beer
    echo '    fi' >> $beer
    echo 'fi' >> $beer
    mv -f $beer "$BEERHALL/BeerHall"
    chmod +x "$BEERHALL/BeerHall"

    # for startetrobo
    cd "$BEERHALL"
    if [ ! -f "$BEERHALL/startetrobo" ]; then
        echo "download startetrobo"
        "$HOMEBREW_PREFIX/bin/wget" "https://raw.githubusercontent.com/ETrobocon/etrobo/master/scripts/startetrobo"
        chmod +x startetrobo
    fi
else
    export PATH="$HOMEBREW_PREFIX/bin:$PATH"
fi

cd "$BEERHALL"
echo "bash on BeerHall is invoked on `pwd`"
#"$BEERHALL/BeerHall" code .

# for startetrobo
echo "invoker params: $@"
param1="$1"
shift
paramAt="$@"
"$BEERHALL/BeerHall" "./startetrobo $param1 $paramAt"


