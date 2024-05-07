if (-not (Get-Variable OhMyPoshConfig -ErrorAction SilentlyContinue)) {
  $OhMyPoshConfig = "~/.poshthemes/devvm.omp.json"
}

if (Get-Command oh-my-posh) {
  oh-my-posh init pwsh --config $OhMyPoshConfig | Invoke-Expression
}
