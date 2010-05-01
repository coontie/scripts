ssh -X -D 1234 -o "ProxyCommand connect -H fhdcproxy.verizon.com:80 %h %p" logastellus@hebe.bytesized-hosting.com
