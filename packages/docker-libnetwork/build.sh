TERMUX_PKG_HOMEPAGE=https://www.docker.com/
TERMUX_PKG_DESCRIPTION="Libnetwork provides a native Go implementation for connecting containers"
TERMUX_PKG_VERSION=18.04.0
LIBNETWORK_GIT_COMMIT=1b91bc94094ecfdae41daa465cc0c8df37dfb3dd
TERMUX_PKG_SHA256=e5016090ed5610571106372658e2bd22c4edd5933aa5162f60b1220ae308380c
TERMUX_PKG_SRCURL=https://github.com/docker/libnetwork/archive/${LIBNETWORK_GIT_COMMIT}.zip
TERMUX_PKG_FOLDERNAME=libnetwork-${LIBNETWORK_GIT_COMMIT}

termux_step_make() {
	# Create ${GO_WORKSPACE} and add it to ${GOPATH}
	termux_setup_golang --mimic-go-get-workspace "src/github.com/docker/libnetwork"

	# issue the build command
	go build -ldflags='-linkmode=external' github.com/docker/libnetwork/cmd/proxy
}

termux_step_make_install() {
	install -Dm0755 proxy ${TERMUX_DESTDIR}/${USR}/bin/docker-proxy
}
