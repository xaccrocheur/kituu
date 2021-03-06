#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

arg1="${1:-}"

# Vars
shopt -s dotglob
REPODIR=~/.kituu
LISPDIR=~/.emacs.d/elisp
SCRIPTDIR=~/scripts
AUTOSTART_DIR=~/.config/autostart

SEP="\n################# "
RW=false

[[ ${arg1} = "-rw" ]] && RW=true

if ($RW); then vc_prefix="git@github.com:" && message="RW mode ON" && git config --global user.name "xaccrocheur" && git config --global user.email xaccrocheur@gmail.com ; else vc_prefix="https://github.com/" && message="RW mode OFF"; fi

# Packages
BASICS="dos2unix python zsh vim byobu apt-file curl wget htop bc locate sshfs git cowsay fortune fortunes-off zenity sox p7zip-full links unison baobab gparted xclip xsel smplayer gpicview gnome-terminal "

declare -A CONF
CONF[Qtractor.conf]="rncbc.org"
CONF[synthv1.conf]="rncbc.org"
CONF[Template.qtt]="rncbc.org"

declare -A pack
pack[dev_tools]="build-essential autoconf devscripts dpkg-dev-el"
pack[beatnitpicker]="python-gst0.10 python-scipy python-matplotlib"
pack[optional]="nautilus-dropbox"
pack[image_tools]="gimp inkscape"
pack[music_prod]="qtractor qjackctl kxstudio-meta-audio-plugins-lv2 qmidinet calf-plugins hexter zam-plugins drumkv1-lv2 synthv1-lv2 samplv1-lv2 jalv lilv-utils guitarix artyfx fluid-soundfont-gm fluid-soundfont-gs zynaddsubfx helm audacious audacity vmpk cadence lv2-dev radium-compressor pizmidi-plugins oxefmsynth argotlunar yoshimi dpf-plugins qmidiarp rtirq-init distrho-plugin-ports-lv2 swh-lv2 triceratops-lv2 mda-lv2"
pack[games]="extremetuxracer supertuxkart chromium-bsu"
pack[emacs]="emacs aspell-fr"
pack[i3]="i3 dmenu i3status i3lock thunar scrot numlockx"

# MOZilla addons
MOZURL="https://addons.mozilla.org/firefox/downloads/latest"
declare -A MOZ
MOZ[Uppity]="$MOZURL/869/addon-869-latest.xpi"
MOZ[back_is_close]="$MOZURL/939/addon-939-latest.xpi"
MOZ[Firebug]="$MOZURL/1843/addon-1843-latest.xpi"
MOZ[GreaseMonkey]="$MOZURL/748/addon-748-latest.xpi"
MOZ[French_dictionary_(save-as_for_thunderbird)]="$MOZURL/354872/addon-354872-latest.xpi"
MOZ[tabmix+]="$MOZURL/1122/addon-1122-latest.xpi"
MOZ[Video_DownloadHelper]="$MOZURL/3006/addon-3006-latest.xpi"
MOZ[ublock_origin]="$MOZURL/607454/addon-607454-latest.xpi"
MOZ[color_picker]="$MOZURL/271/addon-271-latest.xpi"
MOZ[TabCloser]="$MOZURL/9669/addon-9669-latest.xpi"
MOZ[Ctrl-Tab]="$MOZURL/5244/addon-5244-latest.xpi"
MOZ[TabCloser]="$MOZURL/5244/addon-9369-latest.xpi"
MOZ[Smart_Referer]="$MOZURL/327417/addon-327417-latest.xpi"
MOZ[https_everywhere]="https://www.eff.org/https-everywhere"

# Lisp packages
declare -A LISP
LISP[mail-bug]="git clone ${vc_prefix}xaccrocheur/mail-bug.git"
LISP[appt-bug]="git clone ${vc_prefix}xaccrocheur/appt-bug.git"
LISP[pixilang-mode]="git clone ${vc_prefix}xaccrocheur/pixilang-mode.git"
# LISP[nxhtml]="bzr branch lp:nxhtml"

# Various repos (that go in $SCRIPTDIR)
declare -A VARIOUS
# VARIOUS[beatnitpicker]="git clone ${vc_prefix}xaccrocheur/beatnitpicker.git"
VARIOUS[leecher]="git clone ${vc_prefix}xaccrocheur/leecher.git"
VARIOUS[z]="git clone ${vc_prefix}rupa/z.git"

echo -e $SEP"Kituu! #################

$message

Welcome to Kituu, $(whoami). This script allows you to install and maintain various packages from misc places. And well, do what you want done on every machine you install, and are tired of doing over and over again (tiny pedestrian things like create a "tmp" dir in your $HOME).
You will be asked for every package (or group of packages in the case of binaries) if you want to install it ; After that you can run $(basename $0) again (it's in your PATH now if you use the dotfiles, specifically the .*shrc) to update the packages. Sounds good? Let's go."

echo -e $SEP"Dotfiles and scripts"
read -e -p "#### Install / update dotfiles (in $HOME) and scripts (in $SCRIPTDIR)? [Y/n] " YN
if [[ $YN == "y" || $YN == "Y" || $YN == "" ]] ; then
    if [ ! -d $REPODIR ] ; then
	cd && git clone ${vc_prefix}xaccrocheur/kituu.git
    else
	cd $REPODIR && git pull
    fi

    for i in * ; do
	if [[  ! -h ~/$i && $i != *#* && $i != *~* && $i != *git* && $i != "README.org" && $i != "Qtractor.conf" && $i != "Template.qtt" && $i != "." && "${i}" != ".." ]] ; then
	    if [[ -e ~/$i ]] ; then echo "(move)" && mv -v ~/$i ~/$i.orig ; fi
	    ln -sv $REPODIR/$i ~/
	fi
    done
fi

echo -e $SEP"Various menial janitor tasks"
read -e -p "#### Create base dirs, set shell & .desktop (icon) files, add user to audio? [Y/n] " YN

if [[ $YN == "y" || $YN == "Y" || $YN == "" ]] ; then
    if [[ ! -d ~/tmp ]] ; then mkdir -v ~/tmp ; else echo -e "~/tmp \t\t\tOK" ; fi
    if [[ ! -d ~/src ]] ; then mkdir -vp ~/src ; else echo -e "~/src \t\tOK" ; fi
    if [[ ! $SHELL == "/bin/zsh" ]] ; then echo "Setting SHELL to zsh" && chsh -s /bin/zsh ; else echo -e "zsh shell \t\tOK" ; fi
    sudo adduser $(whoami) audio
    sudo cp -v ${REPODIR}/scripts/*.desktop /usr/share/applications/
fi

confs=$(printf "%s, " "${!CONF[@]}")
read -e -p "
#### Symlink (${confs::-2}) config files? [Y/n] " YN

if [[ $YN == "y" || $YN == "Y" || $YN == "" ]] ; then

    for conf in "${!CONF[@]}" ; do

        file=".config/${CONF[$conf]}/$conf"

        if [[ ! -h ~/$file ]] ; then
            rm -fv ~/$file
            ln -sv ${REPODIR}/$file ~/$file
        else
            echo "~/$file is already version-controlled"
        fi

    done
fi

# Packages

read -e -p "
#### Install basic packages ($BASICS) ? [Y/n] " YN

if [[ $YN == "y" || $YN == "Y" || $YN == "" ]] ; then
    sudo apt install $BASICS
fi

read -e -p "
#### Install package groups? [Y/n] " YN

if [[ $YN == "y" || $YN == "Y" || $YN == "" ]] ; then
	for group in "${!pack[@]}" ; do
	    read -e -p "
## Install $group? (${pack[$group]})
[Y/n] " YN
	    if [[ $YN == "y" || $YN == "Y" || $YN == "" ]] ; then
		    sudo apt install ${pack[$group]}
	    fi
	done
fi

[[ ! -d "$SCRIPTDIR" ]] && mkdir -pv $SCRIPTDIR
echo -e $SEP"Various repositories"
read -e -p "#### Stuff? [Y/n] " YN
if [[ $YN == "y" || $YN == "Y" || $YN == "" ]] ; then
    for PROJECT in "${!VARIOUS[@]}" ; do
        VCSYSTEM=${VARIOUS[$PROJECT]:0:3}
        echo -e $SEP"$PROJECT ($SCRIPTDIR/$PROJECT/)"
        if [ ! -e $SCRIPTDIR/$PROJECT/ ] ; then
	    read -e -p "## Install $PROJECT in ($SCRIPTDIR/$PROJECT/)? [Y/n] " YN
	    if [[ $YN == "y" || $YN == "Y" || $YN == "" ]] ; then
	        cd $SCRIPTDIR && ${VARIOUS[$PROJECT]}
                # for i in *.py *.pl ; do `ln -vs "$i" ../` ; done
                cd $PROJECT && pwd
                for i in *.py *.pl ; do
                    [[ -e $i ]] && ln -sv $SCRIPTDIR/$PROJECT/$i $SCRIPTDIR/$i
                done
	    fi
        else
	    cd $SCRIPTDIR/$PROJECT/ && $VCSYSTEM pull
        fi
    done
fi

if [ ! -d "$LISPDIR" ] ; then mkdir -p $LISPDIR/ ; fi
echo -e $SEP"Various repositories"
read -e -p "#### (e)Lisp stuff? [Y/n] " YN
if [[ $YN == "y" || $YN == "Y" || $YN == "" ]] ; then
    for PROJECT in "${!LISP[@]}" ; do
        VCSYSTEM=${LISP[$PROJECT]:0:3}
        echo -e $SEP"$PROJECT ($LISPDIR/$PROJECT/)"
        if [ ! -e $LISPDIR/$PROJECT/ ] ; then
	          read -e -p "## Install $PROJECT in ($LISPDIR/$PROJECT/)? [Y/n] " YN
	          if [[ $YN == "y" || $YN == "Y" || $YN == "" ]] ; then
	              cd $LISPDIR && ${LISP[$PROJECT]}
	          fi
        else
	          cd $LISPDIR/$PROJECT/ && $VCSYSTEM pull
        fi
    done
fi

PAGE=~/tmp/kituu-addons.html
ADDONS=""
ADDON_NAMES=""
echo -e $SEP"Mozilla add-ons"
for ADDON in "${!MOZ[@]}" ; do
	ADDONS=$ADDONS"    <li><a href='"${MOZ[$ADDON]}"'>$ADDON</a></li>\n"
	ADDON_NAMES=$ADDON", "$ADDON_NAMES
done
read -e -p "Install add-ons ($ADDON_NAMES)?
[Y/n] " YN
if [[ $YN == "y" || $YN == "Y" || $YN == "" ]] ; then
	echo -e "
<html>
<head>
<style>
  body {font-family: sans-serif;background:#ccc;}
  hr {margin-top: 1em;width:35%;}
  img#logo {float:right;margin:1em;}
  img#id {width:25px;border:1px solid black;vertical-align:middle}
</style>
<title>Kituu: Install Mozilla addons for $(whoami)</title>
<link rel='shortcut icon' type='image/x-icon' href='http://mozilla.org/favicon.ico'></head>
<body style='background:#ccc'>
<a href='http://opensimo.org/play/?a=Azer0,Counternatures' title='Music!'>
<img id='logo' src='http://people.mozilla.com/~faaborg/files/shiretoko/firefoxIcon/firefox-128-noshadow.png' /></a>
  <h1>Hi $(whoami), click to install extension</h1>
  <ul>" > $PAGE
    echo -e $ADDONS >> $PAGE
    echo -e "</ul>
  <hr />
  <div style='margin-left: auto;margin-right: auto;width:75%;text-align:center;'><a href='https://github.com/xaccrocheur/kituu'><img id='id' src='http://a0.twimg.com/profile_images/998643823/xix_normal.jpg' /></a>&nbsp;&nbsp;Don't forget that you're a genius, $(whoami) ;)</div>
</body>
</html>" >> $PAGE && xdg-open $PAGE
	# printf $ADDONS
fi

if [ -e $SCRIPTDIR/build-emacs.sh ]; then
    echo -e $SEP"Emacs trunk"
    read -e -p "## Download, build and install / update (trunk: ~500Mb initial DL) emacs? [Y/n] " YN
    if [[ $YN == "y" || $YN == "Y" || $YN == "" ]] ; then
        # sudo apt install build-dep emacs23
	build-emacs.sh
    fi
fi

read -e -p "
## Setup autostart apps? (Byobu / tmux) [Y/n] " YN
if [[ $YN == "y" || $YN == "Y" || $YN == "" ]] ; then
[[ ! -d $AUTOSTART_DIR ]] && mkdir -v $AUTOSTART_DIR

    printf "[Desktop Entry]
Type=Application
Exec=gnome-terminal --command byobu --maximize --hide-menubar
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Byobu
Name=Byobu
Comment[en_US]=Byobu tmuxed (zsh) shell (gnome-terminal)
Comment=Byobu tmuxed (zsh) shell" > $AUTOSTART_DIR/byobu.desktop

fi

echo -e $SEP"...Done."
