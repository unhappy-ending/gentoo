# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake multibuild

DESCRIPTION="KDAB's helper class for single-instance policy applications"
HOMEPAGE="https://github.com/KDAB/KDSingleApplication"
SRC_URI="https://github.com/KDAB/KDSingleApplication/releases/download/v${PV}/kdsingleapplication-${PV}.tar.gz"

LICENSE="BSD MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE="doc examples test qt5 qt6"
REQUIRED_USE="qt5? ( !qt6 ) qt6? ( !qt5 )"
RESTRICT="!test? ( test )"

DEPEND=""
BDEPEND="
	doc? (
		app-text/doxygen[dot]
		qt5? (
			dev-qt/qthelp:5
		)
		qt6? (
			dev-qt/qttools:6[assistant]
		)
	)
	examples? (
		dev-util/patchelf
	)
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtnetwork:5
		dev-qt/qtwidgets:5
	)
	qt6? (
		dev-qt/qtbase:6[network,widgets]
	)
"
RDEPEND="
	test? (
		qt5? ( dev-qt/qttest:5 )
	)
	${DEPEND}
"

pkg_setup() {
	MULTIBUILD_VARIANTS=( $(usev qt5) $(usev qt6) )
}

src_configure() {
	myconfigure() {
		local mycmakeargs=(
			-DINSTALL_DOC_DIR="${EPREFIX}/usr/share/doc/${PF}"
			-DKDSingleApplication_DOCS=$(usex doc)
			-DKDSingleApplication_EXAMPLES=$(usex examples)
			-DKDSingleApplication_QT6=$(usex qt6)
			-DKDSingleApplication_TESTS=$(usex test)
		)
	cmake_src_configure
	}
	multibuild_foreach_variant myconfigure
}

src_compile() {
	multibuild_foreach_variant cmake_src_compile
}

src_test() {
	multibuild_foreach_variant cmake_src_test
}

src_install() {
	myinstall() {
		cmake_src_install
		rm -rf "${BUILD_DIR}"/docs/api/html/examples || die
		use doc && HTML_DOCS="${BUILD_DIR}/docs/api/html/*"
		if use examples; then
			patchelf --remove-rpath "${BUILD_DIR}"/bin/widgetsingleapplication || die
			dobin "${BUILD_DIR}"/bin/widgetsingleapplication
		fi
	}
	multibuild_foreach_variant myinstall
	einstalldocs
}
