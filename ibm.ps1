# สร้าง WebSession
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# Bypass certificate validation
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

# POST Login
$response = Invoke-WebRequest -Uri "https://10.10.10.70:9569/srm/j_security_check" `
    -Method Post `
    -Body @{ j_username = "db2aapico"; j_password = "db2aapico" } `
    -WebSession $session

# GET API หลัง login
$response2 = Invoke-WebRequest -Uri "https://10.10.10.70:9569/srm/REST/api/v1/StorageSystems/23080/RemoteReplication" `
    -WebSession $session

# แปลง JSON
$data_list = @()
$result = $response2.Content | ConvertFrom-Json

foreach($data in $result) {
    $data_list += [PSCustomObject]@{
        object_id =  $data.id
        consistency_group = $data.'Consistency Group'
        name = $data.Name
        source_target_host = $data.'Source {0} Target Host'
        source_target_pool = $data.'Source {0} Target Pool'
        source_target_storage = $data.'Source {0} Target Storage System'
        source_target_tier = $data.'Source {0} Target Tier'
        source_target_volume = $data.'Source {0} Target Volume'
        status = $data.Status
        type =  $data.Type
    }
}


function Newsend-JsonPayload {
    param (
        [Parameter(Mandatory)]
        [string]$Url,

        [Parameter(Mandatory)]
        [object]$Payload,   # แก้จาก [hashtable] เป็น [object]

        [Parameter(Mandatory)]
        [int]$Depth,

        [string]$ContentType = "application/json"
    )

    try {
        $jsonBody = $Payload | ConvertTo-Json -Depth $Depth -Compress
        Write-Host "Sending JSON to $Url..."
        Write-Host $jsonBody

        # ใช้ Invoke-RestMethod แทน
        $response = Invoke-RestMethod -Uri $Url -Method Post -Body $jsonBody -ContentType $ContentType -ErrorAction Stop
        return $response
    } catch {
        if ($_.Exception.Response -ne $null) {
            return $_.Exception.Response.StatusCode.Value__
        } else {
            Write-Error "Error sending data: $_"
            return -1
        }
    }
}
function Chunked {
    param (
        [Parameter(Mandatory=$true)]
        [array]$Iterable,

        [Parameter(Mandatory=$true)]
        [int]$Size
    )

    for ($i = 0; $i -lt $Iterable.Count; $i += $Size) {
        $chunk = $Iterable[$i..([Math]::Min($i + $Size - 1, $Iterable.Count - 1))]
        ,$chunk   # comma operator ทำให้ return เป็น array เดียว ไม่ flatten
    }
}
    $payload = @{
        ip = 0
        product = "ibm_spectrum"
        data = @($data_list)
    }
    try {
    $targetUrl = "http://10.10.3.215:8181/server_logs/"
    # เรียก function ส่ง JSON
    $response = Newsend-JsonPayload -Url $targetUrl -Payload $payload -Depth 10
    Write-Host "Response from server: $response"
     $data_list | ft 
    Start-Sleep -Seconds 10

    }
    catch {
       write-Host "fail to push data to logs server Error: $_"
         $data_list | ft 
         Start-Sleep -Seconds 10
    }
    # ระบุ URL API
 


   
#$CookieContainer = $session.Cookies
#    $cookiesList = @()
#    # ใช้ reflection เพื่อเข้าถึง internal domain table ของ CookieContainer
#    $tableField = $CookieContainer.GetType().GetField("m_domainTable", "NonPublic, Instance")
#    $domainTable = $tableField.GetValue($CookieContainer)
#
#    foreach ($domainKey in $domainTable.Keys) {
#        $domainEntry = $domainTable[$domainKey]
#        $listField = $domainEntry.GetType().GetField("m_list", "NonPublic, Instance")
#        $cookieCollection = $listField.GetValue($domainEntry)
#
#        foreach ($cookieName in $cookieCollection.Keys) {
#            $cookie = $cookieCollection[$cookieName]
#            $cookiesList += $cookie
#        }
#    }
#
## ========================
## ตัวอย่างการใช้งาน
## ========================
##$allCookies = Get-AllCookies -CookieContainer $session.Cookies
#
## แสดงผล cookie ทั้งหมด
#$cookiesList | ForEach-Object {
#    Write-Output "$($_.Domain) : $($_.Name) = $($_.Value)"
#}


