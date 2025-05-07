#!/usr/bin/expect -f
set timeout -1
set host $USER@i6.cims.nyu.edu
set password $your_password

spawn /usr/bin/ssh $host
expect {
    "password:" {
        send "$password\r"
        exp_continue
    }
    "option (1-1):" {
        send "1\r"
    }
}
interact