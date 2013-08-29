#!/bin/bash

# check number of arguments passed to the script

if [ $# -lt 1 ]; then
	echo "Usage: $0 [listofservernames...]"
	exit 1
fi

echo "we will be logging into the following servers:"
for i in $@; do
	echo "$i"
done

#collect password

echo -n "Insert your password: "
read -s PASSWORD

echo ""

# login to each box via expect

for server in $@; do

expectscript=$(cat << EOF
spawn /usr/bin/ssh ${USERNAME}@${server}
expect {
-re ".*Are.*.*yes.*no.*" {
send "yes\r"
exp_continue
}

"*?assword*:*" {
send "$PASSWORD\r"
exp_continue
}


"*\$ " {
send "sudo /etc/init.d/osad stop; sudo /bin/rm -f /etc/sysconfig/rhn/osad-auth.conf; sudo /etc/init.d/osad start; sudo /usr/sbin/rhn_check; /bin/echo \"$(date) osad fix run attempted\" >> /tmp/osadfix.log; exit\r"
exp_continue
}

}
EOF
)

expect -c "$expectscript" > /dev/null 2>&1 &

done
