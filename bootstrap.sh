#!/usr/bin/env bash
# A script to bootstrap figure.
# It expects to be run on Ubuntu 14.04 via 'sudo'
# It checks out the figure source code from Github into ~/figure and then runs 'make install' from figure source.

set -eo pipefail
export DEBIAN_FRONTEND=noninteractive
export FIGURE_REPO=${FIGURE_REPO:-"https://github.com/project-nsmg/figure.git"}

if ! command -v apt-get &>/dev/null
then
  echo "This installation script requires apt-get. "
  exit 1
fi

apt-get update
apt-get install -qq -y git make curl software-properties-common man-db help2man

[[ $(lsb_release -sr) == "12.04" ]] && apt-get install -qq -y python-software-properties

cd ~
test -d figure || git clone $FIGURE_REPO
cd figure
git fetch origin

if [[ -n $FIGURE_BRANCH ]]; then
  git checkout origin/$FIGURE_BRANCH
elif [[ -n $FIGURE_TAG ]]; then
  git checkout $FIGURE_TAG
fi

make install

echo
echo "Almost done! "
