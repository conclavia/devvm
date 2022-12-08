# Setup shell prompt
$OhMyPoshConfig = "~/.poshthemes/devvm.omp.json"
oh-my-posh init pwsh --config $OhMyPoshConfig | Invoke-Expression
Import-Module posh-git
Import-Module Terminal-Icons

# Import a local override file if it exists
if (Test-Path ... -PathType Leaf) {
  # . local_profile.ps1
}
