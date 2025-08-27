
#!/bin/bash

artUrl=$(playerctl metadata 2>/dev/null | grep "mpris:artUrl" | sed 's/mpris:artUrl\s*//' | sed 's/^brave\s*//')

if [[ -z $artUrl ]] 
then
   # Now music is playing
   exit
fi


curl -s  "${artUrl}" --output "/tmp/cover.jpeg"
echo "/tmp/cover.jpeg"
