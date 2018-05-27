TERMUX_PKG_HOMEPAGE=http://invisible-island.net/ncurses/
TERMUX_PKG_DESCRIPTION="Library for text-based user interfaces in a terminal-independent manner"
TERMUX_PKG_VERSION=6.1.20180512
TERMUX_PKG_SHA256=a0c7b776702f504200f2beb78c6f798532a8c345506aa634a57e67094316610d
TERMUX_PKG_SRCURL=https://dl.bintray.com/termux/upstream/ncurses-${TERMUX_PKG_VERSION:0:3}-${TERMUX_PKG_VERSION:4}.tgz
# --without-normal disables static libraries:
# --disable-stripping to disable -s argument to install which does not work when cross compiling:
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
ac_cv_header_locale_h=no
--with-install-prefix=${TERMUX_DESTDIR}
--disable-stripping
--enable-const
--enable-ext-colors
--enable-ext-mouse
--enable-overwrite
--enable-pc-files
--enable-widec
--without-ada
--without-cxx-binding
--without-debug
--without-normal
--without-static
--without-tests
--with-shared
--with-pkg-config-libdir=/${USR}/lib/pkgconfig
"
TERMUX_PKG_INCLUDE_IN_DEVPACKAGE="
share/man/man1/ncursesw6-config.1*
bin/ncursesw6-config
"
TERMUX_PKG_RM_AFTER_INSTALL="
bin/captoinfo
bin/infotocap
share/man/man1/captoinfo.1*
share/man/man1/infotocap.1*
share/man/man5
share/man/man7
"

termux_step_post_make_install () {
	cd ${TERMUX_DESTDIR}/${USR}/lib
	for lib in form menu ncurses panel; do
		for file in lib${lib}w.so*; do
			ln -s -f $file `echo $file | sed 's/w//'`
		done
		(cd pkgconfig && ln -s -f ${lib}w.pc `echo $lib | sed 's/w//'`.pc)
	done
	# some packages want libcurses while building/compiling
	ln -sf libncurses.so libcurses.so

	# Some packages want these:
	cd ${TERMUX_DESTDIR}/${USR}/include/
	rm -Rf ncurses{,w}
	mkdir ncurses{,w}
	ln -s ../{ncurses.h,termcap.h,panel.h,unctrl.h,menu.h,form.h,tic.h,nc_tparm.h,term.h,eti.h,term_entry.h,ncurses_dll.h,curses.h} ncurses
	ln -s ../{ncurses.h,termcap.h,panel.h,unctrl.h,menu.h,form.h,tic.h,nc_tparm.h,term.h,eti.h,term_entry.h,ncurses_dll.h,curses.h} ncursesw
}

termux_step_post_massage () {
	# Strip away 30 years of cruft to decrease size.
	local TI=$TERMUX_PKG_MASSAGEDIR/${USR}/share/terminfo
	mv $TI $TERMUX_PKG_TMPDIR/full-terminfo
	mkdir -p $TI/{a,d,e,n,l,p,r,s,t,v,x}
	cp $TERMUX_PKG_TMPDIR/full-terminfo/a/ansi $TI/a/
	cp $TERMUX_PKG_TMPDIR/full-terminfo/d/{dtterm,dumb} $TI/d/
	cp $TERMUX_PKG_TMPDIR/full-terminfo/e/eterm-color $TI/e/
	cp $TERMUX_PKG_TMPDIR/full-terminfo/n/nsterm $TI/n/
	cp $TERMUX_PKG_TMPDIR/full-terminfo/l/linux $TI/l/
	cp $TERMUX_PKG_TMPDIR/full-terminfo/p/putty{,-256color} $TI/p/
	cp $TERMUX_PKG_TMPDIR/full-terminfo/r/rxvt{,-256color} $TI/r/
	cp $TERMUX_PKG_TMPDIR/full-terminfo/s/screen{,2,-256color} $TI/s/
	cp $TERMUX_PKG_TMPDIR/full-terminfo/t/tmux{,-256color} $TI/t/
	cp $TERMUX_PKG_TMPDIR/full-terminfo/v/{vt52,vt100,vt102} $TI/v/
	cp $TERMUX_PKG_TMPDIR/full-terminfo/x/xterm{,-color,-new,-16color,-256color,+256color} $TI/x/

	local RXVT_TAR=$TERMUX_PKG_CACHEDIR/rxvt-unicode-9.22.tar.bz2
	termux_download https://fossies.org/linux/misc/rxvt-unicode-9.22.tar.bz2 \
		$RXVT_TAR \
		e94628e9bcfa0adb1115d83649f898d6edb4baced44f5d5b769c2eeb8b95addd
	cd $TERMUX_PKG_TMPDIR
	local TI_FILE=rxvt-unicode-9.22/doc/etc/rxvt-unicode.terminfo
	tar xf $RXVT_TAR $TI_FILE
	tic -x -o $TI $TI_FILE
}
