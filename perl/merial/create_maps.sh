for interface in `ls INTERFACES/`
do
	./map.pl $interface
	sleep 2
done
