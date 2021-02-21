clear
$tailRecursion = {
    param(
        $Path
    )
    foreach ($childDirectory in Get-ChildItem -Force -LiteralPath $Path -Directory) {
        & $tailRecursion -Path $childDirectory.FullName
    }
    $currentChildren = Get-ChildItem -Force -LiteralPath $Path
    $isEmpty = $currentChildren -eq $null
    if ($isEmpty) {
        Write-Verbose "Removing empty folder at path '${Path}'." -Verbose
        Remove-Item -Force -LiteralPath $Path
    }
}

Function File-delete {
    clear
    remove-variable days, path -ErrorAction SilentlyContinue
    Get-Content ".\settings.ini" | foreach-object -begin {$config=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $config.Add($k[0], $k[1]) } } -ErrorAction stop

    for(;;){

        if ($days -eq $null){
        Write-host -NoNewline 'How days of record do you wish to keep (i.e 15): '
        $days =  read-host }
        write-host ' '

        $limit = (Get-Date).AddDays(-$days)

        if ($path -eq $null){
        Write-host -NoNewline 'Full path of the directory to delete from (i.e c:\path\logs): '
        [string]$path = read-host
        Write-host ' '
            if ( !( Test-Path -Path $path -PathType "Container" ) ) {
                
            
            Write-Warning 'This path is not valid !!!! '
            sleep 4
            remove-variable days, path -ErrorAction SilentlyContinue
            file-delete
            }
        Write-Warning 'This will delete files in the path directory and all sub directories'
        }
        write-host ' '

        if ($format -eq $null){
        Write-host -NoNewline 'Enter the extention of the files you want to delete (i.e pdf, txt, xls, log..): '
        $format = read-host
        }
        write-host ' '
        $extention = '*.'+$format

        # Delete files older than the $limit.


        Get-ChildItem -Path $path -File -filter $extention -Recurse | Where-Object { $_.LastWriteTime -lt $limit } | Remove-Item -Verbose
        

        # Deletes empty folders.
        if (($config.IncludeEmptyFolders -eq 'Yes') -or ($config.IncludeEmptyFolders -eq 'yes') -or ($config.IncludeEmptyFolders -eq 'Y') -or ($config.IncludeEmptyFolders -eq 'y')){
        & $tailRecursion -path $path
        }
        $hourtime = $config.WaitForTime

        $sectime = 60 * 60 * $hourtime
        sleep $sectime
    }
}
file-delete