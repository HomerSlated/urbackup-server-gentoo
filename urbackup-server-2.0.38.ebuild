# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6
inherit user

DESCRIPTION="Fast and easily configured backup server"
HOMEPAGE="https://www.urbackup.org"
SRC_URI="https://hndl.urbackup.org/Server/${PV}/${P}.tar.gz"

SLOT="0"
LICENSE="AGPL-3"
KEYWORDS="~amd64 ~x86"
IUSE="crypt gcc-fortify fuse mail zlib"

RDEPEND="
	crypt? ( >=dev-libs/crypto++-5.1 )
	dev-db/sqlite
	fuse? ( sys-fs/fuse )
	mail? ( net-misc/curl )
	zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${P}-gcc-fortify.patch"
	"${FILESDIR}/${P}-gentoo-prefix.patch"
)

pkg_setup() {
	enewgroup urbackup
	enewuser urbackup -1 /bin/bash "${EPREFIX}"/var/lib/urbackup urbackup
}

src_configure() {
	econf \
	$(use_with crypt crypto) \
	$(use_enable gcc-fortify fortify) \
	$(use_with fuse mountvhd) \
	$(use_with mail) \
	$(use_with zlib)
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc docs/urbackupsrv.1
	fowners -R urbackup:urbackup "${EPREFIX}/var/lib/urbackup"
}
