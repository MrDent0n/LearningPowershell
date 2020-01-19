Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    Multiselect = $false # om du ønsker å velge flere filer
	Filter = 'File (*.csv)|*.csv' # filtrerer hvilken fil typer som kan velges
}
 
[void]$FileBrowser.ShowDialog()

$path = $FileBrowser.FileNames;

If($FileBrowser.FileNames -like "*\*") {

	$FileBrowser.FileNames #Lists selected files (optional)
	
	foreach($file in Get-ChildItem $path){
	Get-ChildItem ($file) |
		ForEach-Object {
        # importerer modulen activedirectory så vi kan bruke komandoene til å håndtere brukere.
Import-Module activedirectory

$ADUsers = Import-csv $path

 
foreach ($User in $ADUsers) #loop som kjører gjennom hele lista for alle brukerene
{
		
	$Username 	= $User.username #brukernavnet til hver bruker
	$Password 	= $User.password #her brukes et fast passord til alle
	$Firstname 	= $User.firstname #fornavn
	$Lastname 	= $User.lastname #etternavn
	$OU 		= $User.ou #refererer til hvilken org unit brukeren skal legges i
    $email      = $User.email #email adresse
    $jobtitle   = $User.jobtitle


	#Sjekker om brukeren allerede eksisterer i domene
	if (Get-ADUser -F {SamAccountName -eq $Username})
	{
		 #hvis brukeren allerede eksisterer i domenet så vil en advarsel bli gitt
		 Write-Warning "A user account with username $Username already exist in Active Directory."
	}
	else
	{
		
		New-ADUser `
            -SamAccountName $Username `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True ` #sørger for at kontoen blir aktivert
            -DisplayName "$Lastname, $Firstname" `
            -Path $OU `
            -EmailAddress $email `
            -Title $jobtitle `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -ChangePasswordAtLogon $True
            
	}
}
		# Legg til handlinger som skal gjøres i filen
		}
	}
	# Legg til oppgave som skal kjøres etter at handlingene i filen er fullført
}

else {
    Write-Host "Cancelled by user"
}
