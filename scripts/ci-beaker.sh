#!/bin/bash -xe

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <os> (centos7, xenial)"
    exit 1
fi

os=$1

sudo sysctl -w vm.nr_hugepages=1024
cat /proc/meminfo | grep Huge
mkdir .bundled_gems
export GEM_HOME=`pwd`/.bundled_gems
gem install bundler --no-rdoc --no-ri --verbose
$GEM_HOME/bin/bundle install --retry 3
export BEAKER_set=nodepool-$os
export BEAKER_debug=yes
export BEAKER_color=no
$GEM_HOME/bin/bundle exec rspec spec/acceptance
