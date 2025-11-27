# real-sharding-test.ps1 - Voir la realite du sharding
Write-Host "TEST REEL DU SHARDING - SANS REDIRECTION AUTOMATIQUE" -ForegroundColor Cyan

$testData = @{
    "user:1001" = "Alice-DataCenter-Paris"
    "user:1002" = "Bob-DataCenter-Lyon" 
    "user:1003" = "Charlie-DataCenter-Marseille"
}

Write-Host "1. AVEC REDIRECTION (-c) - CE QUE VOUS AVEZ VU" -ForegroundColor Yellow
Write-Host "Tous les noeuds semblent avoir toutes les donnees (redirection automatique)" -ForegroundColor White

foreach ($node in @("redis-node-1", "redis-node-2", "redis-node-3")) {
    Write-Host "`n  Depuis $node (avec -c) :" -ForegroundColor Magenta
    foreach ($key in $testData.Keys) {
        $value = docker exec $node redis-cli -c GET $key 2>$null
        Write-Host "    $key : $value" -ForegroundColor Green
    }
}

Write-Host "`n2. SANS REDIRECTION (-c) - LA REALITE" -ForegroundColor Yellow
Write-Host "Chaque donnee est sur un seul maitre!" -ForegroundColor White

foreach ($node in @("redis-node-1", "redis-node-2", "redis-node-3")) {
    Write-Host "`n  Depuis $node (sans -c) :" -ForegroundColor Magenta
    foreach ($key in $testData.Keys) {
        $value = docker exec $node redis-cli GET $key 2>$null
        if ($value) {
            Write-Host "    OK $key : $value" -ForegroundColor Green
        } else {
            Write-Host "    ECHEC $key : NULL (pas sur ce noeud)" -ForegroundColor Red
        }
    }
}

Write-Host "`n3. VERIFICATION DES SLOTS" -ForegroundColor Yellow

foreach ($key in $testData.Keys) {
    $slot = docker exec redis-node-1 redis-cli cluster keyslot $key
    Write-Host "  $key -> Slot: $slot" -ForegroundColor Cyan
}

Write-Host "`n4. TEST AVEC MOVED REDIRECTION" -ForegroundColor Yellow

Write-Host "Forcer une erreur pour voir la redirection :" -ForegroundColor White
foreach ($key in $testData.Keys) {
    Write-Host "`n  GET $key depuis un mauvais noeud :" -ForegroundColor Gray
    $result = docker exec redis-node-1 redis-cli GET $key 2>&1
    if ($result -like "*MOVED*") {
        Write-Host "    REDIRECTION: $result" -ForegroundColor Yellow
    }
}

Write-Host "`n" + "="*70 -ForegroundColor Cyan
Write-Host "EXPLICATION :" -ForegroundColor Cyan
Write-Host "Avec -c : Redis redirige automatiquement -> vous voyez toutes les donnees" -ForegroundColor White
Write-Host "Sans -c : Vous voyez la REALITE -> chaque donnee sur un seul noeud" -ForegroundColor White
Write-Host "="*70 -ForegroundColor Cyan