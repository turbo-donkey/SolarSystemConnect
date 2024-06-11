<div align="center">
  <img src=".\ssc_logo.webp" alt="logo" width = 40% ></a>
</div>
<div align="center">
  
# SolarSystemConnect is a PowerShell wrapper for the SunSynk Connect API
</div>
<div align=left>
  
## Example Use

### Import the module with:
Download the latest release and upzip it.  Your execution polocy might need to be changed to load the module:
```
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
Import-Module C:\Module\Path\SSC\SSC.psd1 -Force -Verbose
```
I might publish on PowerShell Gallery if thats of use to anyone.  For now its a manual process to use.
### Permissions
Installer permissions are needed to use Set-SSCGateway, request the permissions from SunSynk here - [User Level Access Change Request](https://www.sunsynk.org/remote-monitoring#:~:text=An%20approved%20installer%20can%20create,certain%20or%20all%20settings%20%2F%20parameters.)
### Connect to the SunSynk API
```
Connect-SSC -Credentials (Get-Credental)
```
### Discover your environment
```
$SSCPlant = Get-SSCPlant
$SSCInverter = Get-SSCInverter
$SSCGateway = Get-SSCGateway
```
### Get into it
```
Get-SSCGenerationPurpose -PlantId $SSCPlant.Id
Get-SSCPowerFlow -PlantId $SSCPlant.Id
Get-SSCInverterSystemMode -InverterSerial $SSCInverter.Serial
Set-SSCInverterSystemMode -InverterSerial $SSCInverter.Serial -Time1 02:00 -Time1Power 3600 -Time1StateOfCharge 100 -GridCharge1Enabled $true
```
### Disclaimer
This module is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and noninfringement. In no event shall the author or contributors be held liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the module or the use or other dealings in the module.

**I am not responsible for your use of this module.**
### License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
</div>
