#!/bin/bash

# Update a nameserver entry at inwx with the current WAN IP (DynDNS).

# based on the original work by Christian Busch (http://github.com/chrisb86/), adapted to my needs.

# Copyright 2018 mrwu
# http://github.com/eswd/


# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# check required tools
command -v dig >/dev/null 2>&1 || { echo >&2 "dig is required. install dig via dnsutils (e.g.debian) or bind-tools (e.g. alpine linux)."; exit 1; }

source global.conf

# get current ip addresses
current_IPv4=$(curl -s -4 $IP_CHECK_SITE)
current_IPv6=$(curl -s -6 $IP_CHECK_SITE)


# Loop through configs
for f in inwxns.d/*.conf
   do
      source $f

      ## # get the current IPs via nslookup and set WAN_IP
      if [[ "$IPV6" == "NO" ]]; then
	      old_IP=$(dig @ns.inwx.de $DOMAIN A +short) 
         WAN_IP=$current_IPv4
      else
	      old_IP=$(dig @ns.inwx.de $DOMAIN AAAA +short)
         WAN_IP=$current_IPv6
      fi
      
      API_XML="<?xml version=\"1.0\"?>
      <methodCall>
         <methodName>nameserver.updateRecord</methodName>
         <params>
            <param>
               <value>
                  <struct>
                     <member>
                        <name>user</name>
                        <value>
                           <string>$INWX_USER</string>
                        </value>
                     </member>
                     <member>
                        <name>pass</name>
                        <value>
                           <string>$INWX_PASS</string>
                        </value>
                     </member>
                     <member>
                        <name>id</name>
                        <value>
                           <int>$INWX_DOMAIN_ID</int>
                        </value>
                     </member>
                     <member>
                        <name>content</name>
                        <value>
                           <string>$WAN_IP</string>
                        </value>
                     </member>
                  </struct>
               </value>
            </param>
         </params>
      </methodCall>"

      if [[ (! "$current_IPv4" == "$old_IP") && "$IPV6" == "NO" ]]; then
         curl -silent -v -XPOST -H"Content-Type: application/xml" -d "$API_XML" https://api.domrobot.com/xmlrpc/
         echo "$(date) - $DOMAIN IPv4 updated. Old IP: "$old_IP "New IP: "$WAN_IP >> $LOG
       elif [[ (! "$current_IPv6" == "$old_IP") && "$IPV6" == "YES" ]]; then
         curl -silent -v -XPOST -H"Content-Type: application/xml" -d "$API_XML" https://api.domrobot.com/xmlrpc/
         echo "$(date) - $DOMAIN IPv6 updated. Old IP: "$old_IP "New IP: "$WAN_IP >> $LOG
       else
         echo "$(date) - No update needed for $DOMAIN. Current IP: "$WAN_IP >> $LOG
      fi

      unset old_IP
      unset DOMAIN
      unset WAN_IP
      unset INWX_DOMAIN_ID
    done
