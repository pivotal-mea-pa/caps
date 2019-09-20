#!/bin/bash

[[ -n "$TRACE" ]] && set -x
set -eu

pwd



mkdir injector-workspace

PATH_TO_TAR=`find ./pivnet-download -name *windows.tgz`
echo "PATH TO TAR $PATH_TO_TAR"

tar -xf $PATH_TO_TAR -C injector-workspace

##COPY STEMCELL
PATH_TO_STEMCELL=`find ./injector-workspace/pivnet-product/ -name *go_agent.tgz`
echo $PATH_TO_STEMCELL
STEMCELL_FILENAME=`basename $PATH_TO_STEMCELL`
cp $PATH_TO_STEMCELL pivnet-download-updated/$STEMCELL_FILENAME

PATH_TO_INJECTOR_ZIP=`find ./injector-workspace/pivnet-product/ -name winfs-injector-*`
echo "PATH TO ZIP $PATH_TO_INJECTOR_ZIP"

unzip $PATH_TO_INJECTOR_ZIP -d injector-workspace/pivnet-product/
chmod +x injector-workspace/pivnet-product/winfs-injector-linux

PATH_TO_TILE=`find ./injector-workspace/pivnet-product/ -name *.pivotal`
echo "PATH TO tile $PATH_TO_TILE"

#./injector-workspace/pivnet-product/winfs-injector-linux --input-tile=$PATH_TO_TILE --output-tile=pivnet-download-updated/injected-tile.pivotal
mv $PATH_TO_STEMCELL pivnet-download-updated/win-stemcell.tgz
mv $PATH_TO_TILE pivnet-download-updated/updated-tile.pivotal