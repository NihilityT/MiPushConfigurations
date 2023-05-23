$Global:configList = Get-ChildItem *.json
$Global:configLocation = @{}
$Global:configDependencies = @{}
$Global:configDependenciesItem = @{}

if (Get-Command git -errorAction Ignore) {
	$prevEncoding = [Console]::OutputEncoding
	try {
		[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
			$repoFiles = git ls-files .
	} finally {
		[Console]::OutputEncoding = $prevEncoding
	}
	$configList = $configList | Where-Object { $repoFiles -contains $_.Name }
}

foreach ($file in $configList) {
	$content = Get-Content $file -Encoding UTF8 -Raw
	$json = ConvertFrom-Json $content

	$keys = $json.configs | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
	foreach ($key in $keys) {
		$configLocation[$key] += @($file.Name)
	}

	$dependencies = $content | Select-String '"([^"\r\n]+)"' -AllMatches
	$dependencies = $dependencies.Matches | ForEach-Object { $_.Groups[1].Value }
	$dependencies = $dependencies | Where-Object { ($keys -notcontains $_) -and ($_ -ne '^') -and ($_ -ne '$') }
	$configDependenciesItem[$file.Name] = $dependencies
}

foreach ($pair in $configDependenciesItem.GetEnumerator()) {
	$configDependencies[$pair.Name] = $pair.Value | ForEach-Object { $configLocation[$_] } | Where-Object { $_ } | Select-Object -Unique
}

function hash {
	param($s)
	$stringAsStream = [System.IO.MemoryStream]::new()
	$writer = [System.IO.StreamWriter]::new($stringAsStream)
	$writer.write($s)
	$writer.Flush()
	$stringAsStream.Position = 0
	Get-FileHash -InputStream $stringAsStream | Select-Object -ExpandProperty Hash
}

function formatToMermaid {
	param($name)
	return (hash $name) + '["' + $name + '"]'
}

$prevGraph = $null
$mermaid = @(
	'``` mermaid'
	'graph RL'
)
$configDependencies = $configDependencies.GetEnumerator() | Sort-Object -Property Name
foreach ($pair in $configDependencies) {
	$value = $pair.Value | ForEach-Object { formatToMermaid($_) }
	$null = $pair.Name -match '^[^_]+_[^_]+(?=[._])'
	$graph = $Matches[0]
	if ($graph -ne $prevGraph) {
		if ($null -ne $prevGraph) {
			$mermaid += "`tend"
		}
		$mermaid += "`tsubgraph $($Matches[0])"
		$prevGraph = $graph
	}
	if ($null -eq $value) {
		$mermaid += "`t`t$(formatToMermaid $pair.Name)"
	} else {
		$mermaid += "`t`t$(formatToMermaid $pair.Name) --> $($value -join ' & ')"
	}
}
if ($null -ne $prevGraph) {
	$mermaid += "`tend"
}
foreach ($pair in $configLocation.GetEnumerator()) {
	if ($pair.Value.Length -ge 2) {
		$value = $pair.Value | ForEach-Object { formatToMermaid($_) }
		$mermaid += "`t$($value -join ' <-- exclusive --> ')"
	}
}
$mermaid += '```'
$mermaid -join "`n" | Set-Content dependencies.md -Encoding UTF8 -NoNewline
