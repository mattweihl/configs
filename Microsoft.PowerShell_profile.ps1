function get_time()
{
	$ESC = [char]27
	return "$ESC[35m$(Get-Date -UFormat "%I:%M %p")$ESC[0m"
}

function get_username()
{
	$ESC = [char]27
	return "$ESC[32m$env:UserName$ESC[0m"
}

function get_hostname()
{
	$ESC = [char]27
	return "$ESC[33m$(hostname)$ESC[0m"
}

function get_location()
{
	$ESC = [char]27
    return "$ESC[34m$( $pwd | Resolve-Path -Relative)$ESC[0m"
}

function prompt {
	$Host.UI.RawUI.WindowTitle = "$pwd"
	return "[$(get_time)] $(get_username)@$(get_hostname):$(get_location) `n↳ "
}

function Get-ChildItemUnix {
    Get-ChildItem $Args[0] |
        Format-Table Mode, @{N='Owner';E={(Get-Acl $_.FullName).Owner}}, Length, LastWriteTime, @{N='Name';E={if($_.Target) {$_.Name+' -> '+$_.Target} else {$_.Name}}}
}

if (!(test-path alias:ll))
{
	New-Alias ll Get-ChildItemUnix
}
