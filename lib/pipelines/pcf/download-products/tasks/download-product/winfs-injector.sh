#!/bin/bash

[[ -n "$TRACE" ]] && set -x
set -eu

pwd



mkdir injector-workspace

PATH_TO_TAR=`find ./pivnet-download -name *windows.tgz`
echo "PATH TO TAR $PATH_TO_TAR"

tar -xf $PATH_TO_TAR -C injector-workspace

##COPY STEMCELL
mkdir pivnet-download-updated/pivnet-product
PATH_TO_STEMCELL=`find ./injector-workspace/pivnet-product/ -name *go_agent.tgz`

if [ ! -z $PATH_TO_STEMCELL ]
then
    echo $PATH_TO_STEMCELL
    STEMCELL_FILENAME=`basename $PATH_TO_STEMCELL`
    mv $PATH_TO_STEMCELL pivnet-download-updated/pivnet-product/$STEMCELL_FILENAME
fi


PATH_TO_INJECTOR_ZIP=`find ./injector-workspace/pivnet-product/ -name winfs-injector-*`
echo "PATH TO ZIP $PATH_TO_INJECTOR_ZIP"

unzip $PATH_TO_INJECTOR_ZIP -d injector-workspace/pivnet-product/
chmod +x injector-workspace/pivnet-product/winfs-injector-linux

PATH_TO_TILE=`find ./injector-workspace/pivnet-product/ -name *.pivotal`
echo "PATH TO tile $PATH_TO_TILE"

./injector-workspace/pivnet-product/winfs-injector-linux --input-tile=$PATH_TO_TILE --output-tile=pivnet-download-updated/pivnet-product/injected-tile.pivotal

#package pivnet-product
cp pivnet-download/version pivnet-download-updated/pivnet-product
cp pivnet-download/url pivnet-download-updated/pivnet-product

cd pivnet-download-updated

if [ -z $PATH_TO_STEMCELL ]
then
    tar cvzf pivnet-product-stemcell.tgz ./pivnet-product/injected-tile.pivotal ./pivnet-product/version ./pivnet-product/url
    rm -rf ./pivnet-product/injected-tile.pivotal

else
    tar cvzf pivnet-product-stemcell.tgz ./pivnet-product/injected-tile.pivotal ./pivnet-product/$STEMCELL_FILENAME ./pivnet-product/version ./pivnet-product/url
    rm -rf ./pivnet-product/injected-tile.pivotal
    rm -rf ./pivnet-product/$STEMCELL_FILENAME
fi
