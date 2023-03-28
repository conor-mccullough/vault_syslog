# Vault, Journald, Syslog and Logrotate

### No proprietary information is held in this repository

Vault streams its stdout and stderr output using Journald, which produces a binary output that can be viewed using the `journalctl` command.

This reproduction sets up the parameters necessary to reproduce a "bug" (quotation marks as there is no actual product fault) wherein the combination of using `StandardOutput` or `StandardError` to redirect that output with the `file` parameter via syslog into a file, as such:

```
StandardOutput=file:/opt/vault/vault_stdout.log
StandardError=file:/opt/vault/vault_stdout.log
```

Combined with the `copytruncate` parameter of logrotate, as such:

```
/opt/vault/*.log{
  ..
  ..
  copytruncate
  ..
  ..
}
```

Results in syslog dumping the binary data produced by journald into its log files upon log rotation. 

I suspect this is due to, as mentioned, journald logging in binary format, and the `copytruncate` + `file` parameters both ending in the files either interrupting a lock required by Vault to output data, a positional marker that Vault uses for its logging, or simply journald not playing nice when converting its binary to plaintext as is required by syslog/rsyslogd.

The resolution is to remove either `copytruncate` from the logrotate congfiguration, or to replace the `file` parameter with `append` in the `vault.service` file. 

Also noting that the output from Vault should not be redirected into two separate streams for stdout and stderr, as these are designed to be streamed to the same output (journalctl).

For reproduction, force logrotate like so:

```
sudo logrotate -vf /etc/logrotate.d/vault-logrotate
```

Intermittent reproduction, exact steps are:

1. Ensure healthy or empty stdout and stderr log files exist
2. Run logrotate
3. Stop Vault
4. Start vault

At each step using the `file` command on the target log files in the directory, watching for them to turn to the `data` filetype.
