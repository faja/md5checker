#!/bin/sh -

PATH_TO_CHECK='/home'
PATH_ONLY_BIN=false

PACKAGES_TO_CHECK='nginx nginx-full'
PACKAGES_ONLY_BIN=false

FILES_TO_CHECK='/home/test /home/test2'

#PACKAGES
for i in $PACKAGES_TO_CHECK
do
  if $PACKAGES_ONLY_BIN; then
    for j in `dpkg -L $i | grep bin`
# use rpm -ql $i for RedHat/CentOS
#    for j in `dpkg -L $i | grep bin`
    do
      if test ! -d $j; then
        md5sum $j
      fi
    done
  else
    for j in `dpkg -L $i`
# use rpm -ql $i for RedHat/CentOS
#    for j in `rpm -ql $i`
    do
      if test ! -d $j; then
        md5sum $j
      fi
    done
  fi
done


# PATH
for i in $PATH_TO_CHECK
do
  if $PATH_ONLY_BIN; then
    for j in `find $i | grep bin`
      do
        if test ! -d $j; then
          md5sum $j
        fi
      done
  else
    for j in `find $i`
    do
      if test ! -d $j; then
        md5sum $j
      fi
    done
  fi
done


# FILES
for i in $FILES_TO_CHECK
do 
  md5sum $i
done
