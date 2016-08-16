StataEnv <- new.env()

(function(server_dir, dt_stamp) {
    # Helpers
    f <- list
    qui <- capture.output
    '%>>>%' <- function(x,y) do.call(y[[1]], c(list(x),tail(y,-1)))
    '%+%' <- function(x,y) paste0(x,y)
    sendMess <- function(path,txt) cat("", file = path %+% '.' %+% txt)
    errHandl <- function(err, newfile) {
        function(err) {
            Err <<- TRUE
            sendMess(newfile, 'error')
            sub(pattern=newfile, replacement="",
                'Error:\n ' %+% geterrmessage(),
                fixed=TRUE) %>>>%
                f(cat, sep='\n')
        }
    }
    execRcmd <- function(newfile, StataEnv)
        capture.output(tryCatch(source(newfile,
                                       echo=TRUE,
                                       local=StataEnv),
                                error = errHandl(err, newfile)),
                       file = newfile %+% '.output')
    # Core:
    cat('\014') # clear Rscript window
    message('StataRLink Rscript "server" started\n',
            'The Stata-R communication directory:\n',
            server_dir)
    message('Deleting old files...')
    qui(list.files(full.names=TRUE,
                   path=server_dir,
                   pattern='^script .*\\.R$' %+%
                       '|^script .*\\.R.done$' %+%
                       '|^script .*\\.R.output$' %+%
                       '|.*.server_opened$' %+%
                       '|^server.*\\.R$') %>>>%
            f(setdiff, server_dir %+% 'server ' %+% dt_stamp %+% '.R') %>>>%
            f(file.remove))
    message('Waiting for jobs...')
    sendMess(server_dir %+% dt_stamp, 'server_opened')
    repeat {
        newfile <-
            list.files(path=server_dir,
                       pattern='^script .*\\.R$',
                       full.names=TRUE)[1]
        if (!is.na(newfile)) {
            message(Sys.time(), ' Executing:\n', readLines(newfile))
            Err <- FALSE
            execRcmd(newfile, StataEnv)
            if (Err) message('Error!')
            sendMess(newfile, 'done')
            file.remove(newfile)
            message('Waiting for jobs...')
            Sys.sleep(.01)
        }
    }
}
