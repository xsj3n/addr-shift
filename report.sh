set -euo pipefail

cd /opt/ipsync/addr-shift 
ip_enc_file="./ip.txt.gpg"
[[ -f "${ip_enc_file:0:-4}" ]] || touch "${ip_enc_file:0:-4}"

ip="$(curl ifconfig.me)"
last_ip="$(cat ${ip_enc_file:0:-4})"

[[ "$last_ip" == "$ip" ]] && exit 0
echo "$ip" > "${ip_enc_file:0:-4}"
gpg --homedir "./" --encrypt --recipient-file "./recipient.asc" --yes --trust-model always --output "$ip_enc_file" "${ip_enc_file:0:-4}" 

user=$(cat ./user.txt)
email=$(cat ./email.txt)
helper="!echo 'username=$user'; echo 'password=$(cat api.key)'";



git add "$ip_enc_file"
GIT_AUTHOR_NAME="$user" \
GIT_COMMITTER_NAME="$user" \
GIT_AUTHOR_EMAIL="$email" \
GIT_COMMITTER_EMAIL="$email" \
git commit -m "sync"
git -c credential.helper="$helper" push --force
rm "$ip_enc_file"
