# This script will download and install the Cisco Secure Client and profile to make it report to our account.


# 2024-03-11 : added the MSI for the old client to be downloaded and used to uninstall the RC before installing the new client.


# logging
#Start-Transcript -Path "C:\CyberSec\Cisco-SecClient-transcript.log"

#Define the URL to download  files from MS Blob
  # Secure Connect Install files
    $SECUREUMBRELLA  = "https://sysmonfiles.blob.core.windows.net/secure-client/cisco-secure-client-win-5.1.2.42-umbrella-predeploy-k9.msi?sp=r&st=2024-03-08T18:12:46Z&se=2050-03-09T02:12:46Z&sv=2022-11-02&sr=b&sig=GF1yGfcdOeFobADrfnJU9YWqbNv5%2FYfShgU8wjyDJDo%3D"
    $SECURECORE      = "https://sysmonfiles.blob.core.windows.net/secure-client/cisco-secure-client-win-5.1.2.42-core-vpn-predeploy-k9.msi?sp=r&st=2024-03-08T18:12:07Z&se=2050-03-09T02:12:07Z&sv=2022-11-02&sr=b&sig=Ch4jcWXGZ64x3CarTryPCYopB9jNmv8TlkCDtAyLnbg%3D"
  #AnyConnect install file for uninstalling it
    $ANYCONNDOWNLOAD = "https://sysmonfiles.blob.core.windows.net/secure-client/AnnyConnectSetup.msi?sp=r&st=2024-03-11T15:14:39Z&se=2050-03-12T00:14:39Z&sv=2022-11-02&sr=b&sig=1nmH7E1lM3UBxyh9xJIlwvsntiTSFuEx61JA0BaJTIg%3D"
  # Define the URL to download profile file from MS Blob
    $PROFILE = "https://sysmonfiles.blob.core.windows.net/secure-client/OrgInfo.json?sp=r&st=2024-03-08T18:13:03Z&se=2050-03-09T02:13:03Z&sv=2022-11-02&sr=b&sig=re7PdegO65RCCZyN%2F6aex8%2BBGDaipDnfiTJJ6otryhQ%3D"
  
# Define the folders needed for this job
  $LOCALFOLDER   = "C:\CyberSec\SecureClient" #cisco-secure-client-win-5.1.2.42-umbrella-predeploy-k9.msi"
  $PROFILEFOLDER = "C:\ProgramData\Cisco\Cisco Secure Client\Umbrella" # OrgInfo.json"

# Create the necessary directories if they don't already exist
   md -Force $LOCALFOLDER
   md -Force $PROFILEFOLDER

# Define the path to save the files (resused variables for convenience)
  $LOCALCORE     = "C:\CyberSec\SecureClient\cisco-secure-client-win-5.1.2.42-core-vpn-predeploy-k9.msi"
  $LOCALUMBRELLA = "C:\CyberSec\SecureClient\cisco-secure-client-win-5.1.2.42-umbrella-predeploy-k9.msi"
  $PROFILEFOLDER  = "C:\ProgramData\Cisco\Cisco Secure Client\Umbrella\OrgInfo.json"
  $PROFILEFOLDER2 = "C:\CyberSec\SecureClient\OrgInfo.json"
  $ANYCONNSETUP   = "C:\CyberSec\SecureClient\Setup.msi"


  
# Download files 
  # $ProgressPreference = 'SilentlyContinue'
  Invoke-WebRequest -Uri $SECURECORE      -OutFile $LOCALCORE      # download SecureClient to tempory folder
  Invoke-WebRequest -Uri $SECUREUMBRELLA  -OutFile $LOCALUMBRELLA  # download Umbrella client to tempory folder
  Invoke-WebRequest -Uri $PROFILE         -OutFile $PROFILEFOLDER     # download profile & put in folder
  Invoke-WebRequest -Uri $PROFILE         -OutFile $PROFILEFOLDER2    # download profile & put in folder
  Invoke-WebRequest -Uri $ANYCONNDOWNLOAD -OutFile $ANYCONNSETUP      # download AnyConnect & put in folder


# Uninstall AnyConnect - silently
  Start-Process -FilePath msiexec.exe -ArgumentList "/x $ANYCONNSETUP /qn /lvx* C:\CyberSec\AnyConnect-uninstall-output.log" -Wait

# Install secure client core & Umbrella
  Start-Process -FilePath msiexec.exe -ArgumentList "/i $LOCALCORE     /norestart /quiet ARPSYSTEMCOMPONENT=1 PRE_DEPLOY_DISABLE_VPN=1 /lvx* C:\CyberSec\Sec-Client_Core-output.log" -Wait
  Start-Process -FilePath msiexec.exe -ArgumentList "/i $LOCALUMBRELLA /promptrestart /quiet ARPSYSTEMCOMPONENT=1 /lvx* C:\CyberSec\Umbrella-output.log " -Wait


# cleanup
  rm  $LOCALCORE
  rm  $LOCALUMBRELLA
  rm  $PROFILEFOLDER2
  rm  $ANYCONNSETUP
  rm  $LOCALFOLDER

# end logging
# Stop-Transcript

# the end