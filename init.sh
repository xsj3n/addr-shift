set -euo pipefail

ip="$1"
recipient="$2"
git_user="$3"
api_key_path="$4"
email="$5"

# we need to make the srv account and opt dir 
ssh "root@$ip" << 'EOF'
useradd --system ipsync
mkdir -p /opt/ipsync
cd /opt/ipsync
git clone https://github.com/xsj3n/addr-shift.git
EOF

# this files need to be present in the service dir 
gpg --armor --export "$recipient" > ./recipient.asc  
scp ./recipient.asc "root@$ip:/opt/ipsync/addr-shift"
scp "$api_key_path" "root@$ip:/opt/ipsync/addr-shift/api.key"
ssh "root@$ip" "echo '$git_user' > /opt/ipsync/addr-shift/user.txt"
ssh "root@$ip" "echo '$email' > /opt/ipsync/addr-shift/email.txt"
ssh "root@$ip" "chmod -R 700 /opt/ipsync"
ssh "root@$ip" "chown ipsync /opt/ipsync -R"
rm "./recipient.asc"

# cronjob to run once a day 
ssh "root@$ip" 'echo "0 0 * * * /opt/ipsync/addr-shift/report.sh" | crontab -u ipsync -'
