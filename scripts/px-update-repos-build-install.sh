#!/bin/bash

srcdir=~/src

declare -A pack
pack[02-triceratops]="git clone git://git.code.sf.net/p/triceratops/code"
pack[02-amsynth]="git clone https://code.google.com/p/amsynth"
# pack[sord]="svn co http://svn.drobilla.net/sord/trunk"
# pack[lilv]="svn co http://svn.drobilla.net/lad/trunk/lilv"
pack[02-drumkv1]="svn co http://svn.code.sf.net/p/drumkv1/code/trunk"
pack[03-ardour]="git clone git://git.ardour.org/ardour/ardour.git"
pack[01-drobilla-lad]="svn co http://svn.drobilla.net/lad/trunk"
pack[00-lv2]="svn checkout http://lv2plug.in/repo/trunk"

pack_indexes=( ${!pack[@]} )
IFS=$'\n' pack_sorted=( $(echo -e "${pack_indexes[@]/%/\n}" | sed -r -e 's/^ *//' -e '/^$/d' | sort) )

# for z in "${pack[@]}"; do
#   echo $z ' - ' ${pack["$z"]}
# done

# echo "#"

# for k in "${pack_sorted[@]}"; do
#   echo $k ' - ' ${pack["$k"]}
# done

init=true

[[ -d $srcdir ]] && cd $srcdir || mkdir -v $srcdir && cd $srcdir

read -e -p "## Install deps? [Y/n] " yn
if [[ $yn == "y" || $yn == "Y" || $yn == "" ]] ; then
    sudo apt-get install autoconf libboost-dev libglibmm-2.4-dev libsndfile-dev liblo-dev libxml2-dev uuid-dev libcppunit-dev libfftw3-dev libaubio-dev liblrdf-dev libsamplerate-dev libsratom-dev libsuil-dev libgnomecanvas2-dev libgnomecanvasmm-2.6-dev libcwiid-dev libgtkmm-2.4-dev lv2-dev doxygen
fi

function build_waf {

    if [[ $1 = "ardour" ]] ; then
	read -e -p "## Build ardour with Windows VST support? [Y/n] " yn
	if [[ $yn == "y" || $yn == "Y" || $yn == "" ]] ; then
            sudo apt-get wine-dev
            build_flags="--windows-vst"
        else
            build_flags=""
        fi
    fi

    ./waf configure $build_flags && ./waf && sudo ./waf install
}

function build_make {
    if [[ $init ]] ; then
        if [[ -f autogen.sh ]] ; then
            ./autogen.sh
        else
            make -f Makefile.svn
        fi
    fi
    ./configure && make && sudo make install
}

function update_package {

    echo -e "\n## $1"
    pwd
    if [[ $init = true || $force = true ]] ; then
        [[ -f ./waf ]] && build_waf $1 || build_make
    else
        if [[ $vcsystem == "git" ]] ; then
            git pull 1>&1 | grep "Already up-to-date."
        else
            svn up 1>&1 | grep "At revision"
        fi

        if [ ! $? -eq 0 ]; then
            read -e -p "## Branch moved, build and install $1? [Y/n] " yn
            if [[ $yn == "y" || $yn == "Y" || $yn == "" || $init ]] ; then
                [[ -f ./waf ]] && build_waf || build_make
            fi
        fi
    fi
}


for k in "${pack_sorted[@]}"; do
  echo $k ' - ' ${pack["$k"]}
done

for package in "${pack_sorted[@]}" ; do
    vcsystem=${pack[$package]:0:3}
    [[ $vcsystem = "svn" ]] && vcupdatecommand="update" || vcupdatecommand="pull"
    [[ $vcsystem = "svn" ]] && vcinitcommand="checkout" || vcinitcommand="clone"
    # echo "URL of $package ($vcsystem $vcupdatecommand) is ${pack[$package]}"

    # echo "ze pack iz $package"

    # plop=$(echo $package|wc -c)
    # # echo $(( $plop - 4 ))

    name_length=$(( ${#package} -3 ))

    package=${package:3:$name_length}
    echo $package

    # # echo -e $sep"$package ($srcdir/$package/)"
    # if [[ ! -d $srcdir/$package ]] ; then
    #     init=true
    #     echo
    #     read -e -p "## $vcinitcommand $package in ($srcdir/$package/)? [Y/n] " yn
    #     if [[ $yn == "y" || $yn == "Y" || $yn == "" ]] ; then
    #         # cd $srcdir && ${pack[$package]}
    #         cd $srcdir && ${pack[$package]} $package && cd $package
    #         update_package $package
    #     fi
    # else
    #     init=false
    #     cd $srcdir/$package
    #     update_package $package
    # fi
done
