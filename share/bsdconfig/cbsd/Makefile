# $FreeBSD$

NO_OBJ=

SUBDIR= include

LIBEXECDIR=	/usr/local/libexec
FILESDIR=	${LIBEXECDIR}/bsdconfig/cbsd
FILES=		INDEX USAGE

SCRIPTSDIR=	${FILESDIR}
SCRIPTS=	bhyvecfg cbsd jailcfg

beforeinstall:
	mkdir -p ${DESTDIR}${FILESDIR}

.include <bsd.prog.mk>
