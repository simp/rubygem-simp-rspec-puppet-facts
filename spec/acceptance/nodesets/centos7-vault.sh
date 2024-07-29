#!/bin/bash

yum-config-manager --setopt=base.baseurl='http://vault.centos.org/7.9.2009/os/$basearch/' --save
yum-config-manager --setopt=updates.baseurl='http://vault.centos.org/7.9.2009/updates/$basearch/' --save
yum-config-manager --setopt=extras.baseurl='http://vault.centos.org/7.9.2009/extras/$basearch/' --save
sed -i -e '/^\(mirrorlist\|metalink\)=/s/^/#/' /etc/yum.repos.d/CentOS-*.repo
