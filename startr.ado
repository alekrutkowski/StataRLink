prog startr
	if mi(`"$rscript_path"')  {
		noi di as err "You must set the global macro {bf:rscript_path}"
		err 691
	}
	loc stmp = strofreal(round(runiform()*1e8),"%9.0f")
	loc dt = subinstr("$S_DATE $S_TIME `stmp'",":",".",.)
	loc server_dir = subinstr("`c(tmpdir)'","\","/",.)
	qui findfile StataRLink_server.R
	loc server_file "`r(fn)'"
	tempfile server_file_copy
	qui copy "`server_file'" "`server_file_copy'.R", text public replace
	qui filewrap using "`server_file_copy'.R", /*
		*/ pre("..server_dir.. <- '`server_dir''; ..dt.. <- '`dt''")
	winexec $rscript_path --verbose "`server_file_copy'.R"
	waitforfile "`server_dir'`dt'.server_opened"
	rm "`server_dir'`dt'.server_opened"
	glo rserver "on"
	noi di as txt `"R "server" started successfully"'
end

