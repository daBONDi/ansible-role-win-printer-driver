#!powershell
# (c) 2018, David Baumann <daBONDi@users.noreply.github.com>
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# WANT_JSON
# POWERSHELL_COMMON

$ErrorActionPreference = 'Stop';

$params = Parse-Args -arguments $args -supports_check_mode $true;
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false;
$diff_mode = Get-AnsibleParam -obj $params -name "_ansible_diff" -type "bool" -default $false;

$inf_file = Get-AnsibleParam -obj $params -name "inf_file" -type "str" -failifempty $true;
$driver_name = Get-AnsibleParam -obj $params -name "driver_name" -type "str" -failifempty $true;
$printer_env = Get-AnsibleParam -obj $params -name "printer_env" -validateset "x86","x64" -default "x64";
$state = Get-AnsibleParam -obj $params -name "state" -validateset "present","absent" -default "present";

$printer_environment = "Windows x64";
if($printer_env -eq "x86"){ $printer_environment = "Windows NT x86"};

$result = @{
  changed = $false
}

function Test-DriverPresent()
{
  $driverObject = Get-WmiObject -Class "Win32_PrinterDriver" -Filter "SupportedPlatform = '$printer_environment' and Name like '$driver_name,%'"
  if($driverObject){ return $true }
  return $false
}

function Install-Driver()
{
  if(-not (Test-Path -Path $inf_file)){
    Fail-Json -obj $result -msg "Cannot find or access the Driver INF file on $inf_file";
  }
  
  $inf_file_folder = (Get-Item -Path $inf_file).Directory.FullName.ToString();

  # http://dennisspan.com/printer-drivers-installation-and-troubleshooting-guide/#PowerShellAndWMI
  try{
    $DriverClass = [WMIClass]"Win32_PrinterDriver";
		$DriverClass.Scope.Options.EnablePrivileges = $true;
		$DriverObj = $DriverClass.createinstance();
		$DriverObj.Name = $driver_name;
		$DriverObj.DriverPath =  $inf_file_folder;
		$DriverObj.Infname = $inf_file;
    $DriverObj.SupportedPlatform = $printer_environment;
    $DriverObj.Version = 3;
		$ReturnValue = $DriverClass.AddPrinterDriver($DriverObj);
		$Null = $DriverClass.Put()
		if ( $ReturnValue.ReturnValue -ne 0 ) {
      Fail-Json -obj $result -msg "Error on installing Printer Driver with WMI Object: $($ReturnValue.ReturnValue)";
		}
  }catch{
    Fail-Json -obj $result -msg "Error on installing Printer Driver: $($_.Exception.Message)";
  }
}

function Uninstall-Driver()
{
  $driverObject = Get-WmiObject -Class "Win32_PrinterDriver" -Filter "SupportedPlatform = '$printer_environment' and Name like '$driver_name,%'";

  $os_driver_support_version = $driverObject.Version;

  # http://hajuria.blogspot.com/2014/03/adding-and-deleting-printer-drivers-on.html
  try {
    RUNDLL32 PRINTUI.DLL,PrintUIEntry /dd /m $driver_name /h $printer_env /v $os_driver_support_version   # I have to use the RUNDLL32.exe to delete the printer driver, because the WMI class Win32_PrinterDriver does not have a delete method
  }catch{
    Fail-Json -obj $result -msg "Error on Uninstalling Printer Driver: $($_.Exception.Message)";
  }
}


$driver_present = Test-DriverPresent


if($state -ne "absent")
{
  # Ensure driver is installed
  if(-not $driver_present)
  {
    if(-not $check_mode)
    {
      Install-Driver
    }
    $result.changed = $true
  }
}else{
  # Ensure driver is uninstalled
  if($driver_present)
  {
    if(-not $check_mode)
    {
      Uninstall-Driver
    }

    $result.changed = $true
  }
}

Exit-Json -obj $result