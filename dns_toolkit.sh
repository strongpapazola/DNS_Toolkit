dg="\e[90m" #Dark gray"
r="\e[91m" #Light red"
g="\e[92m" #Light green"
y="\e[93m" #Light yellow"
b="\e[94m" #Light blue"
m="\e[95m" #Light magenta"
c="\e[96m" #Light cyan"
w="\e[97m" #White"
inp=$w"["$b"*"$w"] "
ins=$w"["$g"+"$w"] "
inf=$w"["$r"-"$w"] "

banner(){
clear
echo -e $r" ____  _   _ ____    _____           _ _    _ _   "
sleep 0.3
echo -e "|  _ \| \ | / ___|  |_   _|__   ___ | | | _(_) |_ "
sleep 0.3
echo -e "| | | |  \| \___ \    | |/ _ \ / _ \| | |/ / | __|"$w
sleep 0.3
echo -e "| |_| | |\  |___) |   | | (_) | (_) | |   <| | |_ "
sleep 0.3
echo -e "|____/|_| \_|____/    |_|\___/ \___/|_|_|\_\_|\__|"
sleep 0.3
echo
sleep 0.3
echo -e $y"     Author$w :$r strongpapazola"$w
sleep 0.3
echo
}

dnsbackup(){
clear
banner
echo
echo "1. Backup"
echo "2. Restore"
echo
read -p "Select : " dnsbackuprestore
if [ $dnsbackuprestore = "1" ];then
	echo -e $inp"Copying Default Config..."
	cp /etc/bind/named.conf.local /etc/bind/named.conf.local-default
	cp /etc/bind/db.local /etc/bind/db.local-default
	cp /etc/bind/db.127 /etc/bind/db.127-default
	echo -e $ins"Added Default Config...!"
	banner
	dnsfunction
elif [ $dnsbackuprestore = "2" ]; then
	echo -e $inp"Restoring Default Config..."
	cp /etc/bind/named.conf.local-default /etc/bind/named.conf.local
	cp /etc/bind/db.local-default /etc/bind/db.local
	cp /etc/bind/db.127-default /etc/bind/db.127
	echo -e $ins"Added Default Config...!"
	banner
	dnsfunction
else
	echo $inf"Abort."
	exit
fi
}

dnsmachine(){
echo
echo "1. Start"
echo "2. Restart"
echo "3. Stop"
echo
read -p "Select : " dnsmachinecommand
if [ $dnsmachinecommand = "1" ];then
	echo -e $inp"Starting Bind9...!"
	service bind9 start
	echo -e $ins"Bind9 Started...!"
elif [ $dnsmachinecommand = "2" ];then
	echo -e $inp"Restarting Bind9...!"
	service bind9 restart
	echo -e $ins"Bind9 Restarted...!"
elif [ $dnsmachinecommand = "3" ];then
	echo -e $inp"Stop Bind9...!"
	service bind9 stop
	echo -e $ins"Bind9 Stoped...!"
else
	echo Abort.
	banner
	dnsfunction
fi
}

dnsconfig(){
read -p "Enter Domain : " domain
read -p "Enter SubDomain : " subdomain
read -p "Change /etc/bind/db.local To : " dblocal
read -p "Change /etc/bind/db.127 To : " db127
read -p "Masukan IP (Pisahkan Dengan Spasi) : " ipdns1 ipdns2 ipdns3 ipdns4

sleep="sleep 1"
dirncl="/etc/bind/named.conf.local"
dirdblocal="/etc/bind/$dblocal"
dirdb127="/etc/bind/$db127"

echo
$sleep
echo -e $inp"Configure File 'named.conf.local' ...!" && $sleep
echo "zone	'$domain'	{	" >> $dirncl
echo "	type master;			" >> $dirncl
echo "	file '/etc/bind/$dblocal';	" >> $dirncl
echo "};				" >> $dirncl
echo "zone	'$ipdns3.$ipdns2.$ipdns1.in-addr.arpa'	{" >> $dirncl
echo "	type master;			" >> $dirncl
echo "	file '/etc/bind/$db127';	" >> $dirncl
echo "};				" >> $dirncl
sed -i "s/'/*/g" $dirncl
sed -i 's/*/"/g' $dirncl
echo -e $ins"File Configuration Added...!" && $sleep

echo -e $inp"Configure File '$dblocal' ...!" && $sleep
cp /etc/bind/db.local $dirdblocal
sed -i "5c\@       IN      SOA     $subdomain.$domain. root.localhost. (" $dirdblocal
sed -i "12c\@       IN      NS      $subdomain.$domain." $dirdblocal
sed -i "13c\ $subdomain       IN      A       $ipdns1.$ipdns2.$ipdns3.$ipdns4" $dirdblocal
sed -i "s/ $subdomain       IN      A       $ipdns1.$ipdns2.$ipdns3.$ipdns4/$subdomain       IN      A       $ipdns1.$ipdns2.$ipdns3.$ipdns4/g" $dirdblocal
sed -i "14c\server       IN      A       $ipdns1.$ipdns2.$ipdns3.$ipdns4" $dirdblocal
echo -e $ins"File Configuration Added...!" && $sleep

echo -e $inp"Configure File '$db127' ...!" && $sleep
cp /etc/bind/db.127 $dirdb127
echo >> $dirdb127
sed -i "5c\@       IN      SOA     $subdomain.$domain. root.localhost. (" $dirdb127
sed -i "12c\@       IN      NS      $subdomain." $dirdb127
sed -i "13c\ $ipdns4       IN      PTR     $subdomain.$domain." $dirdb127
sed -i "s/ $ipdns4       IN      PTR     $subdomain.$domain./$ipdns4       IN      PTR     $subdomain.$domain./g" $dirdb127
sed -i "14c\ $ipdns4       IN      PTR     server.$domain." $dirdb127
sed -i "s/ $ipdns4       IN      PTR     server.$domain./$ipdns4       IN      PTR     server.$domain./g" $dirdb127
echo -e $ins"File Configuration Added...!" && $sleep

echo -e $ins"Configure File 'resolv.conf' ...!" && $sleep
echo "nameserver $ipdns1.$ipdns2.$ipdns3.$ipdns4" > /etc/resolv.conf
echo -e $ins"File Configuration Added...!" && $sleep

banner
dnsfunction
}

dnsfunction(){
echo -e $inp"DNS Settings...!"
sleep 0.5
echo
echo "1. Backup / Restore"
echo "2. Configure"
echo "3. Machine Service"
echo
read -p "Select : " ok
if [ $ok = "1" ];then
dnsbackup
elif [ $ok = "2" ];then
dnsconfig
elif [ $ok = "3" ];then
dnsmachine
else
echo Abort.
banner
dnsfunction
fi
}

#####
# Main From Script
#####
banner
dnsfunction
