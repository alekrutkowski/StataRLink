prog stopr
	r q()
	sleep 100
	cap rm "$rserver_script"
	glo rserver "off"
	glo rserver_script ""
	noi di as txt `"R "server" stopped successfully"'
end

