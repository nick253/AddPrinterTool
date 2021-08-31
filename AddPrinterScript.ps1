Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore, PresentationFramework, System.Windows.Forms


Function New-Printer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$PrinterName,
        [Parameter(Mandatory)]
        [string]$IPAddress
    )
    # Add printer commands goes here
    $portName = "TCPPort:" + $IPAddress
    $printDriverName = "HP Universal Printing PCL 6 (v7.0.0)"
    $portExists = Get-Printerport -Name $portname -ErrorAction SilentlyContinue
    if (-not $portExists) {
      Add-PrinterPort -name $portName -PrinterHostAddress $IPAddress
    }
    $printDriverExists = Get-PrinterDriver -name $printDriverName -ErrorAction SilentlyContinue
    if ($printDriverExists) {
        Add-Printer -Name $PrinterName -PortName $portName -DriverName $printDriverName
        "Printer has been added."
    }
    else {
        Write-Warning "Printer Driver not installed"
    }
}



# GUI Setup Starts Here
# Where is the XAML file?
$xamlFile = "C:\Users\nickb\Desktop\AddPrinterTool\AddPrinterTool\MainWindow.xaml"

#Create Window
$inputXML = Get-content $xamlFile -Raw
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[XML]$XAML = $inputXML

# #Read XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $window = [Windows.Markup.XamlReader]::Load( $reader )
    # [Windows.Markup.XamlReader]::Load( $reader )
    "Step 1"
} catch {
    Write-Warning $_.Exception
    throw
}

# Create variables based on form control names.
# Variable will be named as 'var_<control name>'

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    #"trying item $($_.Name)"
    try {
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
        "Step 2"
    }
    catch {
        throw
    }
}


$var_btnAddPrinter.Add_Click( {
    New-Printer -PrinterName $var_txtPrinter.Text -IPAddress $var_txtIp.Text
})


# New-Printer

Get-Variable var_*
"Step 3"

 $Null = $window.ShowDialog()

# New-Printer
# "Printer has been added."
# cmd /c pause