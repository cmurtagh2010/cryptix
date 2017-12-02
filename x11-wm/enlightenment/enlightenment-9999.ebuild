# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils
[ "${PV}" = 9999 ] && inherit git-r3 meson xdg-utils

DESCRIPTION="Enlightenment DR19 window manager"
HOMEPAGE="https://www.enlightenment.org/"
EGIT_REPO_URI="https://git.enlightenment.org/core/${PN}.git"
[ "${PV}" = 9999 ] || SRC_URI="http://download.enlightenment.org/rel/apps/${PN}/${P}.tar.bz2"

LICENSE="BSD-2"
[ "${PV}" = 9999 ] || KEYWORDS="~amd64 ~x86"
SLOT="0.17/${PV%%_*}"

E_MODULES_DEFAULT=(
	conf-applications conf-bindings conf-dialogs conf-display conf-interaction
	conf-intl conf-menus conf-paths conf-performance conf-randr conf-shelves
	conf-theme conf-window-manipulation conf-window-remembers

	appmenu backlight battery bluez4 clock conf connman cpufreq everything
	fileman fileman-opinfo gadman geolocation ibar ibox lokker mixer msgbus music-control
	notification pager pager-plain quickaccess shot start syscon systray tasks time
	teamwork temperature tiling winlist wireless wizard xkbswitch
	wl-weekeyboard wl-wl wl-x11
)
E_MODULES=(
	packagekit wl-desktop-shell wl-drm wl-fb wl-x11
)
IUSE_E_MODULES=(
	"${E_MODULES_DEFAULT[@]/#/+enlightenment_modules_}"
	"${E_MODULES[@]/#/enlightenment_modules_}"
)
IUSE="doc +eeze egl nls pam pm-utils static-libs systemd +udev udisks wayland xwayland ${IUSE_E_MODULES[@]}"

# maybe even dev-libs/wlc for wayland USE flag
RDEPEND="
	>=dev-libs/efl-9999[X,egl?,wayland?]
	virtual/udev
	x11-libs/libxcb
	x11-libs/xcb-util-keysyms
	>=media-libs/alsa-lib-1.0.8
	nls? ( sys-devel/gettext )
	pam? ( sys-libs/pam )
	pm-utils? ( sys-power/pm-utils )
	systemd? ( sys-apps/systemd )
	udisks? ( sys-fs/udisks )
	wayland? (
		>=dev-libs/wayland-1.3.0
		>=dev-libs/weston-1.11.0
		>=x11-libs/pixman-0.31.1
		>=x11-libs/libxkbcommon-0.3.1
	)"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

S="${WORKDIR}/${P/_/-}"

src_configure() {
	local emesonargs=(
#		--enable-install-enlightenment-menu
#		--enable-install-sysactions
		-Ddoc=$(usex doc true false)
		-Ddevice-udev=$(usex udev true false)
		-Degl=$(usex egl true false)
#		-Dfiles=$(usex files true false)
		-Dmount-udisks=$(usex udisks true false)
		-Dnls=$(usex nls true false)
		-Dpam=$(usex pam true false)
		-Dstatic-libs=$(usex static-libs true false)
		-Dsystemd=$(usex systemd true false)
		-Deeze=$(usex eeze true false)
		-Dwayland=$(usex wayland true false)
		-Dxwayland=$(usex xwayland true false)
	)

	local i
	for i in ${E_MODULES_DEFAULT} ${E_MODULES}; do
		emesonargs+="-D${i}=$(usex enlightenment_modules_${i} true false)"
	done

	if use wayland; then
		emesonargs+=(
			-Dwl-desktop-shell=$(usex enlightenment_modules_wl-desktop-shell true false)
			-Dwl-x11=$(usex enlightenment_modules_wl-x11 true false)
			-Dwl-wl=$(usex enlightenment_modules_wl-wl true false)
			-Dwl-drm=$(usex enlightenment_modules_wl-drm true false)
			-Dwl-text-input=$(usex enlightenment_modules_wl-text-input true false)
			-Dwl-weekeyboard=$(usex enlightenment_modules_wl-weekeyboard true false)
		)

	fi

	meson_src_configure
}

pkg_postinst() {
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}
