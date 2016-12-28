# copyright © 2016 slated.org
# Distributed under the terms of the AGPLv3+
# $Header: $

EAPI=6
inherit user systemd

DESCRIPTION="Fast and easily configured backup server"
HOMEPAGE="https://www.urbackup.org"
SRC_URI="https://ssl.webpack.de/beta.urbackup.org/Server/${PV}%20beta/${P}.tar.gz"
S=${WORKDIR}/${P}.0

SLOT="0"
LICENSE="AGPL-3"
KEYWORDS="~amd64 ~x86"
IUSE="crypt hardened fuse mail zlib"

RDEPEND="
	crypt? ( >=dev-libs/crypto++-5.1 )
	dev-db/sqlite
	fuse? ( sys-fs/fuse )
	mail? ( >=net-misc/curl-7.2 )
	zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${P}-autoupdate-code.patch"
	"${FILESDIR}/${P}-autoupdate-config.patch"
	"${FILESDIR}/${P}-autoupdate-datafiles.patch"
	"${FILESDIR}/${P}-autoupdate-ui.patch"
	"${FILESDIR}/${P}-gcc-fortify.patch"
	"${FILESDIR}/${P}-gentoo-prefix.patch"
	"${FILESDIR}/${P}-manpage.patch"
)

pkg_setup() {
	enewgroup urbackup
	enewuser urbackup -1 /bin/bash "${EPREFIX}"/var/lib/urbackup urbackup
}

src_configure() {
	econf \
	$(use_with crypt crypto) \
	$(use_enable hardened fortify) \
	$(use_with fuse mountvhd) \
	$(use_with mail) \
	$(use_with zlib) \
	--enable-packaging
}

src_install() {
	dodir "${EPREFIX}"/usr/share/man/man1
	emake DESTDIR="${D}" install
	insinto "${EPREFIX}"/etc/logrotate.d
	newins logrotate_urbackupsrv urbackupsrv
	newconfd defaults_server urbackupsrv
	doinitd "${FILESDIR}"/urbackupsrv
	systemd_dounit ${FILESDIR}/urbackup-server.service
	fowners -R urbackup:urbackup "${EPREFIX}/var/lib/urbackup"
	fowners -R urbackup:urbackup "${EPREFIX}/usr/share/urbackup/www"
}
