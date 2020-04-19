#!/bin/sh

if [ "$#" != "1" ]
then
   echo "Error.  Syntax: $0 gem"
   exit 1
fi

gem=$1

rm ${gem}-*.*.*.gem
gem uninstall ${gem}
gem build ${gem}.gemspec
gem install ./${gem}-*.*.*.gem --no-rdoc --no-ri
rbenv rehash
