<h1 align="center">
  <br>
  <img src=".\ssc_logo.webp" alt="logo" width = 40% ></a>
  <br>
  SolarSystemConnect
  <br>
</h1>
<h4 align="center">
SolarSystemConnect is a PowerShell wrapper for the SunSynk Connect API
</h4>
<div align="center">
  
## Example Use

### Import the module with:
Import-Module C:\Module\Path\SSC\SSC.psd1 -Force -Verbose

### Connect to the SunSynk API
Connect-SSC -Credentials (Get-Credental)

### Discover your environment
$SSCPlant = Get-SSCPlant
$SSCInverter = Get-SSCInverter
$SSCGateway = Get-

### Get into it
Get-SSCGenerationPurpose -PlantId $SSCPlant.Id
Get-SSCPowerFlow -PlantId $SSCPlant.Id
Get-SSCInverterSystemMode -InverterSerial $SSCInverter.Id
Set-SSCInverterSystemMode -InverterSerial $SSCInverter.Id -Time1 02:00 -Time1Power 3600 -Time1StateOfCharge 100 -GridCharge1Enabled $true

### Disclaimer
This module is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and noninfringement. In no event shall the author or contributors be held liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the module or the use or other dealings in the module.

**I am not responsible for your use of this module.**

### License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
</div>
