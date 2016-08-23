prog startr
	syntax [, force]
	if mi(`"$rscript_path"')  {
		noi di as err "You must set the global macro {bf:rscript_path}"
		err 691
	}
	if "$rserver"=="on" & mi("`force'") {
		di as err `"R "server" seems to be open already."' _n /*
			*/ "Use option {bf:force} if you really want to start R."
		err 691
	}
	loc stmp = strofreal(round(runiform()*1e8),"%9.0f")
	loc dt = subinstr("$S_DATE $S_TIME `stmp'",":",".",.)
	loc server_dir = subinstr("`c(tmpdir)'","\","/",.)
	qui findfile StataRLink_server.R
	loc server_file "`r(fn)'"
	loc server_file_copy "`server_dir'server `dt'.R"
	qui copy "`server_file'" "`server_file_copy'", text public replace
	qui filewrap using "`server_file_copy'", /*
		*/ add(")('`server_dir'', '`dt'')")
	winexec $rscript_path --verbose "`server_file_copy'"
	waitforfile "`server_dir'`dt'.server_opened"
	rm "`server_dir'`dt'.server_opened"
	glo rserver "on"
	glo rserver_script "`server_file_copy'"
	noi di as txt `"R "server" started successfully"'
end

