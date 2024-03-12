# Check if BIOS password is enabled
$BIOSPasswordEnabled = $false

# Run the command to check BIOS password status (This command may vary based on the system)
$BIOSPasswordStatus = Get-WmiObject -Namespace root\cimv2\Security\MicrosoftVolumeEncryption -Class Win32_EncryptableVolume | Select-Object -ExpandProperty EncryptionMethod

# Check if the output indicates that a BIOS password is enabled
if ($BIOSPasswordStatus -like "*BIOS*") {
    $BIOSPasswordEnabled = $true
}

# Output the result
if ($BIOSPasswordEnabled) {
    Write-Output "BIOS Password is enabled."
} else {
    Write-Output "BIOS Password is not enabled."
}
