function get_time()
{
        $ESC = [char]27
        $prompt="$ESC[38;2;0;0;0m$ESC[48;2;0;135;255m $(Get-Date -UFormat "%I:%M %p") $ESC[0m"
        return $prompt

}

function get_username_and_hostname()
{
        $ESC = [char]27
        $prompt = "$ESC[38;2;0;0;0m$ESC[48;2;95;255;0m $env:UserName@$(hostname) $ESC[0m"
        return $prompt
}


function get_location()
{
        $ESC = [char]27
        return "$ESC[38;2;0;0;0m$ESC[48;2;13;188;121m 📂 $( $pwd | Resolve-Path -Relative) ⚡ $ESC[0m"
}

function prompt {
        $Host.UI.RawUI.WindowTitle = "$pwd"
        return "$(get_username_and_hostname)$(get_location) `n➤ "
}

function Get-ChildItemUnix {
    Get-ChildItem $Args[0] |
        Format-Table Mode, @{N='Owner';E={(Get-Acl $_.FullName).Owner}}, Length, LastWriteTime, @{N='Name';E={if($_.Target) {$_.Name+' -> '+$_.Target} else {$_.Name}}}
}

if (!(test-path alias:ll))
{
        New-Alias ll Get-ChildItemUnix
}


function c()
{
        Set-Location  $env:HOMEPATH\Code
}
