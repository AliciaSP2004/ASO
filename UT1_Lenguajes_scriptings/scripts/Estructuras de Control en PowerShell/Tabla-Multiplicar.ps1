
$numero=Read-Host "Introduce numero"
$numero=[int] $numero
for ($i=1;$i -le 10;$i++){
    $resultado=$numero * $i
    write-Host "$numero x $i = $resultado"
}