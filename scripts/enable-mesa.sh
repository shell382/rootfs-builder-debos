#!/bin/sh

set -e

ARCH=$(dpkg --print-architecture)

case $ARCH in
    arm64)
        DEB_HOST_MULTIARCH="aarch64-linux-gnu"
        ;;
    armhf)
        DEB_HOST_MULTIARCH="arm-linux-gnueabihf"
        ;;
    amd64)
        DEB_HOST_MULTIARCH="x86_64-linux-gnu"
        ;;
esac

FILE="/usr/lib/$DEB_HOST_MULTIARCH/mesa-egl/ld.so.conf"
if [ ! -f "$FILE" ]; then
    # Add mesa ld conf since latest does not provide this
    echo "creating and making mesa the default alternatives for "$DEB_HOST_MULTIARCH"_egl_conf"
    echo "/usr/lib/$DEB_HOST_MULTIARCH/mesa-egl" > $FILE
    update-alternatives --force --install /etc/ld.so.conf.d/${DEB_HOST_MULTIARCH}_EGL.conf ${DEB_HOST_MULTIARCH}_egl_conf $FILE 500
else
    echo "making mesa the default alternatives for "$DEB_HOST_MULTIARCH"_egl_conf"
    update-alternatives --set $DEB_HOST_MULTIARCH"_egl_conf" $FILE
fi

# ldconfig needs to be run immediately as we're changing /etc/ld.so.conf.d/ with alternatives.
LDCONFIG_NOTRIGGER=y ldconfig

if [ -L "/etc/ld.so.conf.d/${DEB_HOST_MULTIARCH}_GL.conf" ]; then
    FILE="/usr/lib/$DEB_HOST_MULTIARCH/mesa/ld.so.conf"
    if [ ! -f "$FILE" ]; then
        # Add mesa ld conf since latest does not provide this
        echo "creating and making mesa the default alternatives for "$DEB_HOST_MULTIARCH"_gl_conf"
        echo "/usr/lib/$DEB_HOST_MULTIARCH/mesa" > $FILE
        update-alternatives --force --install /etc/ld.so.conf.d/${DEB_HOST_MULTIARCH}_GL.conf ${DEB_HOST_MULTIARCH}_gl_conf $FILE 500
    else
        echo "making mesa the default alternatives for "$DEB_HOST_MULTIARCH"_gl_conf"
        update-alternatives --set $DEB_HOST_MULTIARCH"_gl_conf" $FILE
    fi
    # ldconfig needs to be run immediately as we're changing /etc/ld.so.conf.d/ with alternatives.
    LDCONFIG_NOTRIGGER=y ldconfig
fi
