#!/bin/bash
dnf update -y \
    && dnf install -y \
            cronie \
            git \
&& rm -rf /var/cache/dnf/
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

dnf install -y postgresql15-server

sh-5.2$ sudo postgresql-setup initdb
