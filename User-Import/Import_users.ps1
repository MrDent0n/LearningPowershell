Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    Multiselect = $false # if you want to choose more then one file type
	Filter = 'File (*.csv)|*.csv' # set the file type that you want to be able to import
}
 
[void]$FileBrowser.ShowDialog()

$path = $FileBrowser.FileNames;

If($FileBrowser.FileNames -like "*\*") {

	$FileBrowser.FileNames # Lists selected files (optional)
	
	foreach($file in Get-ChildItem $path){
	Get-ChildItem ($file) |
		ForEach-Object {
Import-Module activedirectory

$ADUsers = Import-csv $path

 
foreach ($User in $ADUsers) #loop that run the entire file you selected
{
		
	$Username 	= $User.username
	$Password 	= $User.password #her brukes et fast passord til alle
	$Firstname 	= $User.firstname
	$Lastname 	= $User.lastname
	$OU 		= $User.ou # reference to the org unit the users should be added to
    $email      = $User.email #email adresse
    $jobtitle   = $User.jobtitle

	if (Get-ADUser -F {SamAccountName -eq $Username})
	{
		 # if the user allready exist a warning will be printed
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
		# add tasks that you want to run within the file
		}
	}
	# add tasks that run after the file action is complete
}

else {
    Write-Host "Cancelled by user"
}
