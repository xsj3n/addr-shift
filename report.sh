set -euo pipefail

ip_enc_file="./ip.txt.gpg"
[[ -f "${ip_enc_file:0:-4}" ]] || touch "${ip_enc_file:0:-4}"

ip="$(curl ifconfig.me)"
last_ip="$(cat ${ip_enc_file:0:-4})"

[[ "$last_ip" == "$ip" ]] && exit 0
echo "$ip" > "${ip_enc_file:0:-4}"
gpg --encrypt --recipient-file "./recipient.asc" --yes --trust-model always --output "$ip_enc_file" "${ip_enc_file:0:-4}"

helper="!echo 'username=$(cat ./user.txt)'; echo 'password=$(cat api.key)'";
git add "$ip_enc_file"
git commit -m "sync"
git -c credential.helper="$helper" push 
rm "$ip_enc_file"
