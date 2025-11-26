set -euo pipefail

rec_enc_file="./recipient.txt.gpg"
ip_enc_file="./ip.txt.gpg"
api_enc_file="./api.key.gpg"

([[ -f "$ip_enc_file" ]] && gpg --decrypt "$ip_enc_file" > "${ip_enc_file:0:-4}") || touch "${ip_enc_file:0:-4}"

ip="$(curl ifconfig.me)"
last_ip="$(cat ${ip_enc_file:0:-4})"

[[ "$last_ip" == "$ip" ]] && rm "${ip_enc_file:0:-4}" && exit 0

gpg --decrypt "$api_enc_file" > "${api_enc_file:0:-4}"
gpg --decrypt "$rec_enc_file" > "${rec_enc_file:0:-4}"

echo "$ip" | gpg --encrypt --recipient "$(cat ${rec_enc_file:0:-4})" --yes --trust-model always --output "$ip_enc_file"
git add "$ip_enc_file"
git commit -m "sync"
git -c credential.helper='!echo "username=xsj3n"; echo "password=$(cat api.key)";' push

rm "${api_enc_file:0:-4}" "${rec_enc_file:0:-4}"
