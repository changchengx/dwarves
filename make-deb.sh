#!/usr/bin/env bash
# Copyright (C) 2020  Liu Changcheng <changcheng.liu@aliyun.com>
# Author: Liu Changcheng <changcheng.liu@aliyun.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

set -xe

# Create dir for build
base=${1:-/tmp/release}
codename=$(lsb_release -sc)
releasedir=$base/$(lsb_release -si)/dwarves
rm -rf $releasedir
mkdir -p $releasedir

src_dir=$(readlink -e `basename $0`)
dwarves_dir=$(dirname $src_dir)
basename=$(basename $dwarves_dir)
dirname=$(dirname $dwarves_dir)
version=$(git describe --match "v*" | cut -d '-' -f 1 | cut -d 'v' -f 2)
outfile="dwarves-dfsg-$version"
orgfile="dwarves-dfsg_$version"

# Prepare source code
cp -arf ${dirname}/${basename} ${releasedir}/${outfile}
cd ${releasedir}/${outfile}
git clean -dxf

# Change changelog if it's needed
cur_ver=`head -1 debian/changelog | sed -n -e 's/.* (\(.*\)) .*/\1/p' | cut -d '-' -f 1`
if [ "$cur_ver" != "$version" ]; then
	dch -D $codename --force-distribution -b -v "$version-1" "new version"
fi

# Create tar archieve
cd ../
tar cvzf ${outfile}.tar.gz ${outfile}
ln -s ${outfile}.tar.gz ${orgfile}.orig.tar.gz

# Build debian package
cd -
debuild
