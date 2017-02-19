#!/bin/bash -xe

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <puppet_version>"
    exit 1
fi

puppet_version=$1
if [ "$puppet_version" != "latest" ]; then
  export PUPPET_GEM_VERSION="~> $puppet_version.0"
fi

mkdir -p .bundled_gems
export GEM_HOME=`pwd`/.bundled_gems
gem install bundler --no-rdoc --no-ri --verbose
$GEM_HOME/bin/bundle install --retry 3
$GEM_HOME/bin/bundle exec rake syntax
$GEM_HOME/bin/bundle exec rake lint
$GEM_HOME/bin/bundle exec rake spec SPEC_OPTS='--format documentation'
