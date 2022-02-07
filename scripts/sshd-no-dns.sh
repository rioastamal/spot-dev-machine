#!/bin/sh

# Most of the time what takes SSH login taking too long are DNS resolution.
sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
systemctl reload sshd