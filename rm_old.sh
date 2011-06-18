#!/bin/sh

cd `dirname $0`
find tmp/icons/* -mmin +100 2> /dev/null | xargs rm -f
