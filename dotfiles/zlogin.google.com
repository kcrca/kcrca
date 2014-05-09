# This tells gnubbyd to look at the remote host for a gnubby
# (the port 3000 is set up in the .ssh/config on the remote host)
test -z "$REMOTE_HOST" || echo -ne "${REMOTE_HOST}: 3000\r\n\r\n" | nc localhost 1817 > /dev/null
eval $(ssx-agents)
