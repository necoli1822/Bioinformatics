#!/usr/bin/env bash

if [ -z $1 ]; then
var="$(</dev/stdin)"
echo "${var^^}" | rev | tr [ATGC] [TACG]
else
echo $1 | tr [:lower:] [:upper:]| rev | tr [ATGC] [TACG]; fi
