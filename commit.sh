#!/bin/bash

# commit script to keep the package list up to date.

pacman -Qqet > fullpackagelist

case $1 in
	-m)
		git commit -m "$2"
		;;
	--amend)
		git commit --amend
		;;
	*)
		git commit $@
esac
