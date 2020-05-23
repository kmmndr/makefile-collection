#!/bin/sh
set -eu

stage='default'

if [ $# -eq 1 ]; then
	stage=$1
fi

cat <<EOF
COMMON_VARIABLE=foo
EOF

case "$stage" in
	"default")
		cat <<-EOF
		CUSTOM_VARIABLE=bar
		EOF
		;;

	"production")
		cat <<-EOF
		CUSTOM_VARIABLE=foobar
		EOF
		;;

	*)
		echo "Unknown stage $stage" >&2
		exit 1
		;;
esac
