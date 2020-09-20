#!/bin/bash
export BEERHALL_VER="5.00g.200920"
echo
echo "------------"
echo " jtBeerHall - an implementation of Homebrew sandbox"
echo "------------"
echo " as 'startetrobo_mac.command' Ver $BEERHALL_VER"
# Copyright (c) 2020 jtLab, Hokkaido Information University
# by TANAHASHI, Jiro(aka jtFuruhata) <jt@do-johodai.ac.jp>
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php
#

if [ "$1" = "update" ]; then
    if [ -z "$BEERHALL" ]; then
        BEERHALL="$(cd "$(dirname "$0")"; pwd)/BeerHall"
    fi
    makeBeerHall="rebuild"
    rm -f "$BEERHALL/BeerHall"
    rm -f "$BEERHALL/startetrobo"
fi

if [ "$1" = "clean" ]; then
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
    while read line; do
        if [ -z "$removeFlag" ]; then
            if [ -n "`echo $line | grep jtBeerHall`" ]; then
                removeFlag="remove"
            else
                echo $line >> $bashrc
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

    targetFile=~/.bash_profile
    touch $targetFile
    unset removeFlag
    bashrc=$(mktemp)
    cat $targetFile | 
    while read line; do
        if [ -z "$removeFlag" ]; then
            if [ -n "`echo $line | grep jtBeerHall`" ]; then
                removeFlag="remove"
            else
                echo $line >> $bashrc
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

    targetFile=~/.zprofile
    touch $targetFile
    unset removeFlag
    bashrc=$(mktemp)
    cat $targetFile | 
    while read line; do
        if [ -z "$removeFlag" ]; then
            if [ -n "`echo $line | grep jtBeerHall`" ]; then
                removeFlag="remove"
            else
                echo $line >> $bashrc
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
    export HOMEBREW_CACHE="$BEERHALL/usr/local/cache"
    export PATH="$BEERHALL/usr/local/bin:$PATH"
    brew update
    brew upgrade
    brew install bash

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
    # python@3.8 (for subversion)
    brew install python@3.8
    brew link python@3.8 --force
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
    # perl (for subversion)
    brew install perl
    # utf8proc (for subversion)
    brew install utf8proc
    # subversion (for homebrew core)
    brew install subversion
    export HOMEBREW_SVN="$BEERHALL/usr/local/bin/svn"

    # libyaml (for ruby@2.5)
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

    # install BeerHall (for etrobo) formulae

    brew install bash-completion findutils wget git ruby@2.5 flex make jq curl md5sha1sum
    brew link ruby@2.5 --force
    brew link flex --force
    brew link curl --force

#    echo "modify gcc@7 filenames"
    cd "$BEERHALL/usr/local/bin"
#    ls | grep 7$ | while read line; do
#        fileName=`echo "$line" | sed -E 's/(.*)-7/\1/'`
#        mv "$line" "$fileName"
#    done

    echo "make aliases"
    echo "gmake \"\$@\"" > make
    echo "gfind \"\$@\"" > find
    echo "\"/usr/local/bin/code\" \"\$@\"" > code
    chmod +x make find code

    echo "make symbolic link from \$BEERHALL/etc to \$BEERHALL/usr/local/etc"
    ln -s "$BEERHALL/usr/local/etc" "$BEERHALL/etc"

    echo "make symbolic link from /usr/local/lib to flex/lib"
    ls $BEERHALL/usr/local/opt/flex/lib |
    while read line; do
        if [ -e "/usr/local/lib/$line" ]; then
            if [ ! -e "/usr/local/lib/$line.BeerHallTmp" ]; then
                sudo mv "/usr/local/lib/$line" "/usr/local/lib/$line.BeerHallTmp"
            else
                sudo rm "/usr/local/lib/$line"
            fi
        fi
        sudo mkdir -p /usr/local/lib
        sudo cp -f "$BEERHALL/usr/local/opt/flex/lib/$line" "/usr/local/lib/"
    done
    makeBeerHall="build"
fi

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
    echo 'export HOMEBREW_CACHE="$BEERHALL/usr/local/cache"' >> $beer
    echo 'export HOMEBREW_SVN="$BEERHALL/usr/local/bin/svn"'
    echo 'export HOMEBREW_TEMP="/tmp"' >> $beer
    echo 'export BEERHALL_RUBY="$BEERHALL/usr/local/opt/ruby@2.5/bin"' >> $beer
    echo 'export BEERHALL_DARWIN_VER=`uname -a | sed -E "s/^.*Darwin Kernel Version (.*): .*$/\1/"`' >> $beer
    echo 'export BEERHALL_ARCH="x86_64-apple-darwin$BEERHALL_DARWIN_VER"' >> $beer
    #echo 'export BEERHALL_GCC_VER_FULL=`gcc --version | head -n 1 | sed -E "s/^.*GCC (.*)\).*$/\1/"`' >> $beer
    #echo 'export BEERHALL_GCC_VER="${BEERHALL_GCC_VER_FULL:0:5}"' >> $beer
    #echo 'export BEERHALL_GCC_VER_MAJOR=`echo "$BEERHALL_GCC_VER" | sed -E "s/^(.*)\..*\..*$/\1/"`' >> $beer
    echo 'export HOME="$BEERHALL"' >> $beer
    echo 'export SHELL="$BEERHALL/usr/local/bin/bash"' >> $beer
    echo 'export PATH="$BEERHALL:$BEERHALL/usr/local/bin:$BEERHALL_RUBY:/usr/bin:/bin:/usr/sbin:/sbin"' >> $beer
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
    echo '        bash -l -c "$@"' >> $beer
    echo '    else' >> $beer
    echo '        bash -l' >> $beer
    echo '    fi' >> $beer
    echo 'fi' >> $beer
    mv -f $beer "$BEERHALL/BeerHall"
    chmod +x "$BEERHALL/BeerHall"

    # for startetrobo
    echo "download startetrobo"
    cd "$BEERHALL"
    "$BEERHALL/usr/local/bin/wget" "https://raw.githubusercontent.com/ETrobocon/etrobo/master/scripts/startetrobo"
    chmod +x startetrobo
fi

cd "$BEERHALL"
echo "bash on BeerHall is invoked on `pwd`"
#"$BEERHALL/BeerHall" code .

# for startetrobo
"$BEERHALL/BeerHall" ./startetrobo


