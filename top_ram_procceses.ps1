$ErrorActionPreference = "Stop"

# "Снимок" процессов
$before = @{}
Get-Process | ForEach-Object {
    $before[$_.Id] = @{
        Name = $_.ProcessName
        RAM  = $_.WorkingSet64
    }
}

# Общий объём оперативной памяти (в байтах)
$totalRAM = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory

# Контейнер для результатов
$delta = @()

# Формируем данные по каждому процессу
foreach ($p in $before.Keys) {
    $proc = $before[$p]
    if ($proc -and $totalRAM -gt 0) {
        $ramPercent = [math]::Round(($proc.RAM / $totalRAM) * 100, 2)
        $delta += [PSCustomObject]@{
            Name = $proc.Name
            RAM  = $ramPercent
        }
    }
}

# HTML-таблица
$html = "<table border='1' cellspacing='0' cellpadding='3'><thead><tr><th>Process</th><th>RAM, %</th></tr></thead><tbody>"

$delta | Sort-Object RAM -Descending | Select-Object -First 10 | ForEach-Object {
    $html += "<tr><td>$($_.Name)</td><td>$($_.RAM)</td></tr>"
}

$html += "</tbody></table>"

Write-Output $html
