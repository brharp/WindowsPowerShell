/*
 * Creates a NAT network for running Drupal VM.
 *
 * See https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/setup-nat-network
 *
 */

# Variables
$SwitchName="Internal (NAT)"
$DefaultGateway="192.168.0.1"
$PrefixLength=24
$NATName="NAT"
$NATSubnetPrefix="192.168.0.0/24"

# Remove any existing Drupal switch.
Get-NetNat | Where-Object -Property Name -EQ $NATName | Remove-NetNat
Get-VMSwitch | where-object -property name -eq $SwitchName | Remove-VMSwitch
Get-NetIPAddress | Where-Object -Property IPAddress -EQ $DefaultGateway | Remove-NetIPAddress

# Create new switch
New-VMSwitch -SwitchName $SwitchName -SwitchType Internal

# Note ifIndex of new switch
$ifIndex=Get-NetAdapter | Where-Object name -Like "*$SwitchName*" | select-object -ExpandProperty ifIndex

# Create IP address
New-NetIPAddress -IPAddress $DefaultGateway -PrefixLength $PrefixLength -InterfaceIndex $ifIndex

# Enable NAT
get-netnat | remove-netnat
New-NetNat -Name $NATName -InternalIPInterfaceAddressPrefix $NATSubnetPrefix 


