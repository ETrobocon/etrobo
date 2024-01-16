#!/bin/bash
export BEERHALL_VER="5.25a.220617"
echo
echo "------------"
echo " jtBeerHall - an implementation of Homebrew sandbox"
echo "------------"
echo " as 'startetrobo_mac.command' Ver $BEERHALL_VER"
# Copyright (c) 2020-2022 jtLab, Hokkaido Information University
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
    ls $BEERHALL/usr/local/opt/flex/lib |
    while read line; do
        sudo rm -f "/usr/local/lib/$line"
        if [ -e "/usr/local/lib/$line.BeerHallTmp" ]; then
            sudo mv "/usr/local/lib/$line.BeerHallTmp" "/usr/local/lib/$line"
        fi
    done

    sudo rm -f /etc/bashrc_BeerHall

    targetFile=/etc/bashrc_vscode
    touch $targetFile
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

    echo "install HomeBrew, please wait a *few hours*"
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
    brew install bash

    # unlink md5sha1sum for old BeerHall
    # (that is included in coreutils)
    if [ "`brew list | grep md5sha1sum`" ]; then
        brew unlink md5sha1sum
    fi

    # install kegs

    # openjdk (for gettext)
    brew install openjdk
    brew link openjdk --force
    # pkg-config (for subversion)
    brew install pkg-config
    # gdbm (for subversion)
    brew install gdbm
    # openssl@1.1 (for subversion)
    brew install openssl@1.1
    brew link openssl@1.1 --force
    # readline (for subversion)
    brew install readline
    brew link readline --force
    # sqlite (for subversion)
    brew install sqlite
    brew link sqlite --force
    # xz (for subversion)
    brew install xz
    # mpdecimal (for python)
    brew install mpdecimal
    # tcl-tk (for python)
    brew install tcl-tk
    brew link tcl-tk --force
    # python@3.10 (for scons)
    brew install python@3.10
    brew link python@3.10 --force
    # scons (for subversion)
    brew install scons
    # pcre (for subversion)
    brew install pcre
    # swig (for subversion)
    brew install swig
    # apr (for subversion)
    brew install apr
    brew link apr --force
    # apr-util (for subversion)
    brew install apr-util
    brew link apr-util --force
    # gettext (for subversion)
    brew install gettext
    # lz4 (for subversion)
    brew install lz4
    # berkeley-db (for perl)
    brew install berkeley-db
    # perl (for subversion)
    brew install perl
    # utf8proc (for subversion)
    brew install utf8proc
    # subversion (for homebrew core)
    brew install subversion
    export HOMEBREW_SVN="$HOMEBREW_PREFIX/bin/svn"

    # libyaml (for ruby@2.7)
    brew install libyaml
    # libunistring (for wget)
    brew install libunistring
    # libidn2 (for wget)
    brew install libidn2
    # help2man (for flex)
    brew install help2man
    # pcre2 (for git)
    brew install pcre2
    # lzip (for make)
    brew install lzip
    # oniguruma (for jq)
    brew install oniguruma
    # brotli (for curl)
    brew install brotli
    # libmetalink (for curl)
    brew install libmetalink
    # libssh2 (for curl)
    brew install libssh2
    # c-ares (for curl)
    brew install c-ares
    # jemalloc (for curl)
    brew install jemalloc
    # libev (for curl)
    brew install libev
    # libnghttp2 (for nghttp2)
    brew install libnghttp2
    # nghttp2 (for curl)
    brew install nghttp2
    # openldap (for curl)
    brew install openldap
    brew link openldap --force
    # rtmpdump (for curl)
    brew install rtmpdump
    # zstd (for curl)
    brew install zstd

    # install BeerHall (for etrobo) formulae

    brew install bash-completion coreutils findutils wget git ruby@2.7 flex make jq curl
    brew install esolitos/ipa/sshpass iproute2mac
    brew link ruby@2.7 --force
    brew link flex --force
    brew link curl --force
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

#    echo "modify gcc@7 filenames"
    cd "$HOMEBREW_PREFIX/bin"
#    ls | grep 7$ | while read line; do
#        fileName=`echo "$line" | sed -E 's/(.*)-7/\1/'`
#        mv "$line" "$fileName"
#    done
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


