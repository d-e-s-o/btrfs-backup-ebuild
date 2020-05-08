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
IUSE="+test tests"

PYTHON_COMPAT=( python3_{4,5,6,7,8} )
inherit python-r1

RDEPEND="
  dev-python/cleanup[${PYTHON_USEDEP}]
  dev-python/execute[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}
  dev-python/setuptools[${PYTHON_USEDEP}]
  test? ( dev-python/mock[${PYTHON_USEDEP}] )
"

# Note that due to the order of function invocation in ebuilds whenever the
# 'test' USE flag is specified we also need 'tests' to be enabled. The reason
# is that otherwise we remove the btrfs.test package and no tests are available
# to execute.
REQUIRED_USE="
  test? ( tests )
"

EGIT_BRANCH="devel"
EGIT_REPO_URI="https://github.com/d-e-s-o/btrfs-backup"

inherit git-r3
inherit distutils-r1

src_prepare() {
  features="FEATURES=\"-sandbox -usersandbox -userpriv test\""

  if has test $FEATURES; then
    if has sandbox $FEATURES ||\
       has userpriv $FEATURES ||\
       has usersandbox $FEATURES; then
      eerror "You have enabled the 'test' portage feature but the current"
      eerror "set of (additional) features prohibits tests from succeeding."
      eerror "Use the following features to allow for correct testing:"
      eerror
      eerror "${features}"
      echo
      die
    fi
  else
    ewarn "It is strongly recommended to run all associated tests for this"
    ewarn "package to ensure correct working."
    ewarn "To enable testing, you need to have the following combination of"
    ewarn "portage features:"
    ewarn
    ewarn "${features}"
    echo

    einfo "Continuing in five seconds..."
    sleep 5
  fi

  if ! use tests; then
    epatch "${FILESDIR}"/${PN}-remove-tests.patch
  fi
}

python_compile() {
  pushd "${S}"/btrfs-backup > /dev/null || die
  distutils-r1_python_compile
  popd > /dev/null || die
}

python_install() {
  pushd "${S}"/btrfs-backup > /dev/null || die
  distutils-r1_python_install

  doinitd "${FILESDIR}"/init.d/btrfs-backup
  popd > /dev/null || die
}

# Note that python_test() is the default function that is invoked by
# distutils-r1_src_test() which in turn is the default behavior of src_test()
# which gets invoked when the 'test' portage feature is enabled.
python_test() {
  # Note that we cannot use setup.py test here because it violates the sandbox
  # environment by creating files outside the temporary directory. In detail,
  # it downloads the argparse package and installs it temporarily in the
  # working directory.
  # It appears impossible to get rid of this behavior. Changing the directory
  # before running the test was unsuccessful, even copying the entire tree into
  # the temporary directory and running it there did not make a change.
  # Unfortunately, setup.py's test command does not accept any parameters that
  # would allow to change this directory or disable this behavior entirely.
  TEST_TMP_DIR="${TMPDIR}" ${EPYTHON} -m unittest discover --buffer\
    "${S}/btrfs-backup/src/deso/btrfs/test" || die
}
