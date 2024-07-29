#!/bin/bash

yum-config-manager --setopt=baseos.baseurl='https://vault.centos.org/8-stream/BaseOS/$basearch/os/' --save
yum-config-manager --setopt=appstream.baseurl='https://vault.centos.org/8-stream/AppStream/$basearch/os/' --save
yum-config-manager --setopt=extras-common.baseurl='https://vault.centos.org/8-stream/extras/$basearch/extras-common/' --save
yum-config-manager --setopt=extras.baseurl='https://vault.centos.org/8-stream/extras/$basearch/os/' --save

sed -i -e '/^\(mirrorlist\|metalink\)=/s/^/#/' /etc/yum.repos.d/CentOS-*.repo
