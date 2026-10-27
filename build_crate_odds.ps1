param(
    [string]$CratesJsonPath = "D:\Burstdown\data\crates.json",
    [string]$OutHtmlPath = "$PSScriptRoot\crate-odds.html"
)

$data = Get-Content -Raw -Path $CratesJsonPath | ConvertFrom-Json
$rows = @()

$crateLabels = @{
    "standard" = "Standard Crate"
    "premium"  = "Premium Crate"
    "world"    = "World Crate"
    "season"   = "Season Crate"
}

foreach ($prop in $data.crates.PSObject.Properties) {
    $key = $prop.Name
    $c = $prop.Value
    $label = if ($crateLabels.ContainsKey($key)) { $crateLabels[$key] } else { $key }

    $costStr = ""
    if ($null -ne $c.cost.keys) { $costStr = "$($c.cost.keys) Key (<code>keys: $($c.cost.keys)</code>; earned in-game, never sold)" }
    elseif ($null -ne $c.cost.gems) { $costStr = "$($c.cost.gems) Gems (<code>gems: $($c.cost.gems)</code>; paid / online-only)" }
    elseif ($null -ne $c.cost.reward) { $costStr = "Gameplay / Season Reward (<code>reward: true</code>)" }

    $pityParts = @()
    if ($null -ne $c.pity) {
        if ($null -ne $c.pity.epic_or_better_within) {
            $pityParts += "Guaranteed <strong>Epic or better within $($c.pity.epic_or_better_within) opens</strong> (<code>epic_or_better_within: $($c.pity.epic_or_better_within)</code>)"
        }
        if ($null -ne $c.pity.legendary_or_better_within) {
            $pityParts += "Guaranteed <strong>Legendary or better within $($c.pity.legendary_or_better_within) opens</strong> (<code>legendary_or_better_within: $($c.pity.legendary_or_better_within)</code>)"
        }
        if ($null -ne $c.pity.mythic_within) {
            $pityParts += "Guaranteed <strong>Mythic within $($c.pity.mythic_within) opens</strong> (<code>mythic_within: $($c.pity.mythic_within)</code>)"
        }
    }
    if ($null -ne $c.guarantee -and $null -ne $c.guarantee.epic) {
        $pityParts += "Guaranteed at least <strong>$($c.guarantee.epic) Epic item per crate</strong> (<code>guarantee.epic: $($c.guarantee.epic)</code>)"
    }
    $pityStr = if ($pityParts.Count -gt 0) { $pityParts -join "; " } else { "Standard rarity roll per item slot" }

    $rows += @"
        <tr>
          <td><strong>$label</strong> (<code>$key</code>)</td>
          <td>$costStr</td>
          <td>$($c.items)</td>
          <td>$([string]::Format('{0:0.##}%', $c.odds.common))</td>
          <td>$([string]::Format('{0:0.##}%', $c.odds.rare))</td>
          <td>$([string]::Format('{0:0.##}%', $c.odds.epic))</td>
          <td>$([string]::Format('{0:0.##}%', $c.odds.legendary))</td>
          <td>$([string]::Format('{0:0.##}%', $c.odds.mythic))</td>
          <td>$pityStr</td>
        </tr>
"@
}

$scrapRows = @()
foreach ($prop in $data.duplicate_to_scrap.PSObject.Properties) {
    $rName = (Get-Culture).TextInfo.ToTitleCase($prop.Name)
    $scrapRows += @"
        <tr>
          <td>$rName</td>
          <td>$($prop.Value) Scrap</td>
        </tr>
"@
}

$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Mystery Crate Odds &amp; Pity Disclosure - Burstdown | Frictionborn</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <header>
    <div class="header-inner">
      <a class="brand" href="index.html">BURSTDOWN <span>by Frictionborn</span></a>
      <nav>
        <a href="index.html">Home</a>
        <a href="privacy.html">Privacy Policy</a>
        <a href="terms.html">Terms of Service</a>
        <a href="delete-account.html">Account Deletion</a>
        <a href="crate-odds.html" aria-current="page">Crate Odds</a>
      </nav>
    </div>
  </header>

  <main>
    <h1>Mystery Crate Odds &amp; Pity Disclosure</h1>
    <p class="meta">Last updated: 28 October 2026 &middot; Publisher: <strong>Frictionborn</strong> &middot; Generated at build time from <code>data/crates.json</code> (v$($data.version))</p>

    <p>In accordance with global consumer protection rules and Google Play policy on randomized virtual items, this page discloses the exact drop probabilities, item counts, guaranteed pity timers, duplicate conversion rates, and regional availability rules for all Mystery Crates in <strong>Burstdown</strong> (<em>Burstdown: Bottle Stair Smash</em>).</p>

    <h2>1. Crate Drop-Rate Probabilities &amp; Pity Timers</h2>
    <table>
      <thead>
        <tr>
          <th>Crate Type</th>
          <th>Cost / How Obtained</th>
          <th>Items per Crate</th>
          <th>Common</th>
          <th>Rare</th>
          <th>Epic</th>
          <th>Legendary</th>
          <th>Mythic</th>
          <th>Pity / Guarantee Rules</th>
        </tr>
      </thead>
      <tbody>
$($rows -join "`n")
      </tbody>
    </table>

    <h2>2. Item Pool &amp; Duplicate Conversion (Scrap)</h2>
    <p><strong>Pool Rules:</strong> $($data.pool_rules)</p>
    <p>If a crate roll yields an item you already own, it is automatically converted into <strong>Scrap</strong> (used to craft specific items directly without randomness) at the following rates:</p>
    <table>
      <thead>
        <tr>
          <th>Rarity</th>
          <th>Scrap Granted per Duplicate</th>
        </tr>
      </thead>
      <tbody>
$($scrapRows -join "`n")
      </tbody>
    </table>

    <h2>3. Player Protection &amp; Regional Compliance Rules</h2>
    <ul>
      <li><strong>In-Game Disclosure Before Open (<code>show_odds_before_open: $($data.compliance.show_odds_before_open.ToString().ToLower())</code>):</strong> These exact percentages and your current pity-timer counter are displayed directly on the crate purchase/open screen inside Burstdown.</li>
      <li><strong>No "Kompu Gacha" / Set-Completion Prizes (<code>set_completion_rewards: $($data.compliance.set_completion_rewards.ToString().ToLower())</code>):</strong> There are no rewards or bonuses gated behind collecting a complete set of randomized crate items.</li>
      <li><strong>Minor Mode Protection (<code>minor_mode_paid_crates: $($data.compliance.minor_mode_paid_crates.ToString().ToLower())</code>):</strong> Paid mystery crates (such as the Premium Crate) are completely disabled for players in the <code>13&ndash;17</code> age band.</li>
      <li><strong>Regional Availability (<code>$($data.compliance.paid_blocked_countries_rc_key)</code>):</strong> Paid mystery crates are disabled in jurisdictions where paid loot boxes are prohibited or restricted by law, including <strong>Belgium (<code>BE</code>)</strong> and <strong>Brazil (<code>BR</code>, Law 15.211/2025 Digital ECA)</strong>, with remote configuration support for the Netherlands (<code>NL</code>) and EU-wide regulatory updates.</li>
      <li><strong>Draw Log Retention (<code>draw_log_retention_days: $($data.compliance.draw_log_retention_days)</code>):</strong> Server-side crate draw logs (<code>crate_opens</code>) are kept for at least $($data.compliance.draw_log_retention_days) days; after account deletion they are kept only without the account link and deleted once $($data.compliance.draw_log_retention_days) days old.</li>
    </ul>
  </main>

  <footer>
    &copy; 2026 Frictionborn. All rights reserved. &middot; <a href="privacy.html">Privacy</a> &middot; <a href="terms.html">Terms</a> &middot; <a href="delete-account.html">Delete Account</a> &middot; <a href="crate-odds.html">Crate Odds</a>
  </footer>
</body>
</html>
"@

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutHtmlPath, $html, $utf8NoBom)
Write-Host "Generated $OutHtmlPath from $CratesJsonPath (UTF-8 no BOM)"
