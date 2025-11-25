file_one="./recipient.txt.gpg"
file_two="./api.key.gpg"
gpg --decrypt "$file_one" > "${file_one:0:-4}"
gpg --decrypt "$file_two" > "${file_two:0:-4}"
rm *.gpg
