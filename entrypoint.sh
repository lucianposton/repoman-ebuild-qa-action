#!/bin/sh -l

set -e

repoman_args="$INPUT_REPOMAN_ARGS"
path="$INPUT_PATH"
profile="$INPUT_PROFILE"
portage_version="$INPUT_PORTAGE_VERSION"
gentoo_repo="$INPUT_GENTOO_REPO"

apk add python3 py3-yaml py3-lxml git bash
ln -s /usr/bin/python3 /usr/bin/python
mkdir -p /etc/portage /var/cache/distfiles "$gentoo_repo"
echo "portage:x:250:250:portage:/var/tmp/portage:/bin/false" >> /etc/passwd
echo "portage::250:portage" >> /etc/group
wget "https://www.gentoo.org/dtd/metadata.dtd" -O /var/cache/distfiles/metadata.dtd
wget -O - "https://github.com/gentoo-mirror/gentoo/archive/master.tar.gz" | tar xz -C "$gentoo_repo" --strip-components=1

if [ "$profile" = "latest" ]; then
    profile="$(sed "1,/SYMLINK_LIB=no/d" < "$gentoo_repo/profiles/profiles.desc" | grep stable | head -1 | awk '{print $2}')"
fi
echo "Using profile \"$profile\""

if [ ! -e "$gentoo_repo/profiles/$profile" ]; then
    echo "Profile \"$profile\" not found in $gentoo_repo/profiles/"
    exit 2
fi
ln -s "$gentoo_repo/profiles/$profile" /etc/portage/make.profile

if [ "$portage_version" = "latest" ]; then
    portage_version=$(grep DIST "$gentoo_repo/sys-apps/portage/Manifest" | sort --version-sort | tail -1 | cut -d ' ' -f 2)
    portage_version=${portage_version%.tar.bz2}
    portage_version=${portage_version#portage-} # e.g. "2.3.20"
fi
echo "Using portage version \"$portage_version\""

if [ -z "$portage_version" ]; then
    echo "Unable to determine portage version."
    exit 3
fi

wget -O - "https://github.com/gentoo/portage/archive/portage-${portage_version}.tar.gz" | tar xz -C /
ln -s "/portage-portage-${portage_version}/cnf/repos.conf" /etc/portage/repos.conf
ln -s "/portage-portage-${portage_version}/repoman/bin/repoman" /usr/bin/repoman

if [ ! -d ".git" ]; then
    echo
    echo "Found no git repository."
    echo "Did you forget the actions/checkout step in your workflow job?"
    echo
    echo "    steps:"
    echo "        - uses: actions/checkout@v2"
    echo
fi

if [ -n "$path" ]; then
    cd "$path"
fi

echo "Running 'repoman full $repoman_args' from $(pwd)"
# shellcheck disable=SC2086
repoman full $repoman_args
