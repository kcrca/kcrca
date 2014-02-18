
#
# fm_start:
#	Start up fmbatch (synchronous)
#
sub fm_start
{
    local($cmd) = "fmbatch";
    local($oh);

    return if ($FMStarted);
    open(FMBATCH, "| $cmd") || &die("$cmd: $!");# start up fmbatch
    &unbuffer('FMBATCH');			# make the pipe unbuffered
    &fm_sync();					# wait for startup
    $FMStarted++;
}

#
# fm_cmd:
#	Send a list of commands to fmbatch and wait for the response.
#
sub fm_cmd
{
    local ($cmd);

    foreach $cmd (@_) {				# send the commands
	print FMBATCH $cmd, "\n";
    }
    &fm_sync();
}

#
# fm_sync:
#	Sync up with the fmbatch process, i.e., wait until it can
#	process the "touch" command via "system" to create the
#	$DoneFile, which we wait for.
#
sub fm_sync
{
    unlink($DoneFile);				# clear out the "done" file
    &die("$DoneFile: $!") if (-f $DoneFile);	# ensure the unlink worked

    print FMBATCH "system 'touch $DoneFile'\n";	# make it send the "done"
    while (! -f $DoneFile) {			# wait for it to be "done"
	sleep(1);
    }
}

#
# unbuffer:
#	Set the given file to be unbuffered.
#
sub unbuffer
{
    local ($fd) = @_;
    local ($oh);

    $oh = select($fd);
    $| = 1;
    select($oh);
}

#
# to_mif:
#	Generate mif for the named file.  We only do this if the file
# 	is newer than the .mif file.
#
sub to_mif
{
    local ($file) = @_;
    local ($mif) = &mif_of($file);

    return if ($file =~ /\.mif$/);
    if ($Optimize && (stat($file))[$ST_MTIME] < (stat($mif))[$ST_MTIME]){
	print "$mif (up to date)\n";
	return;
    }

    print $file;
    &fm_cmd(
	"Open $file",
	"SaveAs m $file $mif"
    );
    print ".mif\n";
}

#
# from_mif:
#	Generate the named file from its mif.  We only do this if the
#	mif is newer than the file.
#
sub from_mif
{
    local ($file) = @_;
    local ($mif) = &mif_of($file);

    if ($Optimize && (stat($file))[$ST_MTIME] > (stat($mif))[$ST_MTIME]){
	print "$file (up to date)\n" if ($Verbose);
	return;
    }

    print "$file.mif" if ($Verbose);
    &fm_cmd(
	"Open $mif",
	"SaveAs d $mif $file"
    );
    print "\b\b\b\b    \n" if ($Verbose);
}

#
# mif_of:
#	Return the .mif file for the give path.
#
sub mif_of
{
    local($_) = @_;

    s/$/.mif/ if (!/\.mif$/);
    return $_;
}

#
# fm_cleanup:
#	Cleanup the state of the process, letting fmbatch exit cleanly
#	and cleaning up any of our own files.
#
sub fm_cleanup
{
    local ($file);

    print FMBATCH "Quit\n" if (FMBATCH);	# let Frame clean up
    unlink($DoneFile);				# remove this file (if there)
}

#
# check_lock:
#	Ensure that none of the listed files has a lock set (i.e., is
#	being edited).
#
sub check_lock
{
    local ($err) = 0;

    foreach $file (@_) {
	if (! -w "$file") {
	    print STDERR "$file is read-only\n";
	    $err++;
	}
	if (-f "$file.lck") {
	    print STDERR "$file is locked\n";
	    $err++;
	}
    }
    &die("Cannot continue") if ($err);
}

$DoneFile = "/tmp/fm_done$$";
$Optimize++;

1;      # this makes "require" happy
