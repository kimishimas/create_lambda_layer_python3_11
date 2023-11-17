#!/bin/bash

DSTDIR="./layer"
ZIPFILE="layer.zip"
BUCLET_NAME=$1
LAYER_NAME=$2
VERSION=3.11.6

sudo yum install -y openssl11 openssl11-devel
sudo yum install -y gcc make zlib-devel bzip2 bzip2-devel readline-devel sqlite-devel tk-devel libffi-devel xz-devel
if [ -e ~/.pyenv ]; then
  sudo rm -rf ~/.pyenv
fi
git clone https://github.com/yyuu/pyenv.git ~/.pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
source ~/.bashrc
pyenv install $VERSION
pyenv global $VERSION
 
if [ -e $DSTDIR ]; then
  sudo rm -rf $DSTDIR
fi
pip install -t $DSTDIR -r requirements.txt 
zip -q -r $ZIPFILE $DSTDIR
aws s3 cp $ZIPFILE s3://$BUCKET_NAME/$ZIPFILE
aws lambda publish-layer-version --layer-name $LAYER_NAME --compatible-runtimes python3.11 --content S3Bucket=$BUCKET_NAME,S3Key=$ZIPFILE
