ssh -X -D 5678 -o "ProxyCommand connect -S 127.0.0.1:1234 %h %p" ig@coontie.chickenkiller.com -p 2222
