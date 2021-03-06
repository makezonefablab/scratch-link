<#
.SYNOPSIS
    Import one or more digital certificate(s) and private key(s) from WIN_CSC_* environment variables.
.DESCRIPTION
    This command assumes two environment variables:
      - WIN_CSC_LINK is assumed to contain one or more Base64-encoded, encrypted digital certificate(s) and/or key(s).
      - WIN_CSC_KEY_PASSWORD is assumed to contain the password necessary to decrypt the data in WIN_CSC_LINK.
        The script will import the contents of WIN_CSC_LINK into the local machine's "Personal" certificate store.
.NOTES
    This is designed for use with a continuous integration service which places sensitive information, like digital
    certificates, into environment variables. It may not work well for other purposes.
    The data in WIN_CSC_LINK most likely will need to contain intermediates.
#>

$ErrorActionPreference = "Stop"

# TODO: is there a way to avoid creating a temporary file?
$tempPfx = New-TemporaryFile
try {
    $env:WIN_CSC_LINK | Set-Content $tempPfx

    $securePassword = (ConvertTo-SecureString -String $env:WIN_CSC_KEY_PASSWORD -AsPlainText -Force)

    Import-PfxCertificate -FilePath $tempPfx -Password $securePassword -CertStoreLocation "Cert:/LocalMachine/My"
}
finally {
    Remove-Item -Force $tempPfx
}
