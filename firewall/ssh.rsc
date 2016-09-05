# 
# Based on http://wiki.mikrotik.com/wiki/Bruteforce_login_prevention
#
# Install by copying script to router and running console command /import ssh.rsc or copy paste script to
# terminal. 
#

{
    :local port 22

    /ip firewall filter	

    :foreach rule in=[find jump-target=SSH] do={
        remove $rule
    }

    :foreach rule in=[find chain=SSH] do={
        remove $rule
    }

    add chain=SSH comment="SSH Chain: limit attemps, allow whitelisted and drop blacklisted" \
	action=accept \
	src-address-list=ssh_whitelist

    add chain=SSH \
	action=drop \
	src-address-list=ssh_blacklist

    add chain=SSH \
	action=add-src-to-address-list \
	address-list=ssh_blacklist \
	address-list-timeout=1w \
	src-address-list=ssh_stage3
    
    add chain=SSH \
	action=add-src-to-address-list \
	address-list=ssh_stage3 \
	address-list-timeout=1m \
	src-address-list=ssh_stage2

    add chain=SSH \
    	action=add-src-to-address-list \
    	address-list=ssh_stage2 \
    	address-list-timeout=1m \
    	src-address-list=ssh_stage1

    add chain=SSH \
	action=add-src-to-address-list \
	address-list=ssh_stage1 \
	address-list-timeout=1m

    add chain=SSH \
	action=accept

    add chain=input comment="Jump for SSH" \
        action=jump \
        jump-target=SSH \
	connection-state=new \
	protocol=tcp dst-port=$port \
	place-before=2 

    add chain=forward comment="Jump for SSH" \
        action=jump \
        jump-target=SSH \
	connection-state=new \
	protocol=tcp dst-port=$port \
	place-before=2
}
