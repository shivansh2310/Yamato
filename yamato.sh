#!/bin/bash

cat << "EOF"
			 _   _			   _                     
			\ \ / /                   | |       
			 \ V /__ _ _ __ ___   __ _| |_ ___  
			  \ // _` | '_ ` _ \ / _` | __/ _ \ 
			  | | (_| | | | | | | (_| | || (_) |
			  |_|\__,_|_| |_| |_|\__,_|\__\___/ 
                /\                               
 /VVVVVVVVVVVVVV|================================================/       
 `^^^^^^^^^^^^^^|===============================================/
                \/      # Coded By Shivansh Kumar a.k.a Mr.7i74N                                              	

	Tool Features:-
	1> Whois info
	2> Broken Link
	3> Subdomain
	4> Third-level subdomain
	5> Checking for alive domain(httprobe)
	6> Host Header injection
	7> Nmap		           
     	8> Eyewitness
                     
EOF

if [ $# -gt 2 ]; then
	echo "Usage: ./yamato.sh <Domain>"
	echo "Example: ./yamato.sh yahoo.com"
	exit 1
fi


if [ ! -d "scans" ]; then
	mkdir scans
fi

if [ ! -d "eyewitness" ]; then
	mkdir eyewitness
fi

pwd=$(pwd)

echo "[+]Gathering basic information about the target......"
whois -H $1 >> info.txt 

echo "[+]Checking for brokenlinks....."
blc -rof --filter-level 3 https://$1/ | grep BROKEN | sort -u >> Brokenlinks.txt

echo "[+]Gathering subdomain using sublister....."
sublist3r -d $1 -o final.txt

echo $1 >> final.txt

echo "[+]Compiling third-level domain....."
cat final.txt | grep -Po "(\w+\.\w+\.\w+)$" | sort -u >> third-level.txt


if [ $# -eq 2 ];
then
	echo "[+]probing alive third levels....."
	cat third-level.txt | sort -u | grep -v $2 |  httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ":443" > probed.txt
else
	echo "[+]probing alive third levels....."
	cat third-level.txt | sort -u | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ":443" > probed.txt
fi

echo "[+]Checking for host header injection......"
for cache in $(cat probed.txt); do curl -X GET -H "Host:bing.com" https://$cache >>Hostheader.txt;done

echo "[+]Scanning for open ports......"
nmap -iL probed.txt -T5 -oA scans/scanned.txt

echo "[+]Running Eyewitness....."
eyewitness -f $pwd/probed.txt -d eyewitness/$1 --web




