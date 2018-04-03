#!/bin/bash
    ufw -f enable
    ufw allow 80/tcp
    ufw allow from julianbersnakmbp to any port 22
    ufw reload