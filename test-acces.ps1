# test-acces-direct.ps1 - Acces direct aux bon noeuds
Write-Host "ACCES DIRECT AUX VRAIS MAITRES" -ForegroundColor Cyan

Write-Host "`n1. ACCES DEPUIS LE BON NOEUD :" -ForegroundColor Yellow

# user:1003 est sur redis-node-3 (172.38.0.13)
Write-Host "  user:1003 est sur redis-node-3 :" -ForegroundColor White
$result1 = docker exec redis-node-3 redis-cli GET "user:1003"
Write-Host "    ✅ Acces DIRECT : $result1" -ForegroundColor Green

# user:1001 et user:1002 sont sur redis-node-6 (172.38.0.16)  
Write-Host "  user:1001 et user:1002 sont sur redis-node-6 :" -ForegroundColor White
$result2 = docker exec redis-node-6 redis-cli GET "user:1001"
$result3 = docker exec redis-node-6 redis-cli GET "user:1002"
Write-Host "    ✅ user:1001 : $result2" -ForegroundColor Green
Write-Host "    ✅ user:1002 : $result3" -ForegroundColor Green

Write-Host "`n2. ACCES DEPUIS UN MAUVAIS NOEUD :" -ForegroundColor Yellow

Write-Host "  user:1003 depuis redis-node-1 :" -ForegroundColor White
$result4 = docker exec redis-node-1 redis-cli GET "user:1003" 2>&1
Write-Host "    ❌ $result4" -ForegroundColor Red

Write-Host "`n3. VERIFICATION DES REPLIQUAS :" -ForegroundColor Yellow

# Trouver les replicas de redis-node-3 et redis-node-6
Write-Host "  Topologie complete :" -ForegroundColor White
docker exec redis-node-1 redis-cli cluster nodes