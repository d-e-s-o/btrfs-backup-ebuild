#/***************************************************************************
# *   Copyright (C) 2015 Daniel Mueller (deso@posteo.net)                   *
# *                                                                         *
# *   This program is free software: you can redistribute it and/or modify  *
# *   it under the terms of the GNU General Public License as published by  *
# *   the Free Software Foundation, either version 3 of the License, or     *
# *   (at your option) any later version.                                   *
# *                                                                         *
# *   This program is distributed in the hope that it will be useful,       *
# *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
# *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
# *   GNU General Public License for more details.                          *
# *                                                                         *
# *   You should have received a copy of the GNU General Public License     *
# *   along with this program.  If not, see <http://www.gnu.org/licenses/>. *
# ***************************************************************************/

EAPI=5

DESCRIPTION="A simple and fast btrfs-based backup tool."
HOMEPAGE="https://github.com/d-e-s-o/btrfs-backup"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="arm amd64 amd64-linux x86 x86-linux"

PYTHON_COMPAT=( python3_{2,3} )
inherit python-r1

DEPEND="
  dev-python/setuptools[${PYTHON_USEDEP}]
  dev-python/mock[${PYTHON_USEDEP}]
"
RDEPEND="${DEPEND}"

EGIT_BRANCH="devel"
EGIT_REPO_URI="https://github.com/d-e-s-o/btrfs-backup"

inherit git-2
inherit distutils-r1
