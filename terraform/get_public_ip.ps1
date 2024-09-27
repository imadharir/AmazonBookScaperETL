# Fetch the public IP address using an API like ifconfig.me
$publicIP = Invoke-RestMethod -Uri "https://ifconfig.me"

# Return the IP address as a JSON object
$publicIPObject = @{
    "public_ip" = $publicIP
}

# Convert the object to JSON format
$publicIPObject | ConvertTo-Json
