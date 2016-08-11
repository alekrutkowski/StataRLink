prog waitforfile
	loc rc 1
	while `rc' {
		cap conf file `0'
		loc rc = _rc
		sleep 10
	}
end
