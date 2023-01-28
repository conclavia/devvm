using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# ==================================================
#   Acknowledgements
#
#     Most of the useful helpers below are from the PSReadLine project:
#     https://github.com/PowerShell/PSReadLine/blob/master/PSReadLine/SamplePSReadLineProfile.ps1
#
#     Tricks & tips learned from many others as well
# ==================================================

# ==================================================
#   Shell prompt
# ==================================================

# Setup shell prompt
if (-not $OhMyPoshConfig) {
  $OhMyPoshConfig = "~/.poshthemes/devvm.omp.json"
}
oh-my-posh init pwsh --config $OhMyPoshConfig | Invoke-Expression
Import-Module Terminal-Icons

# Sometimes you want to get a property of invoke a member on what you've entered so far
# but you need parens to do that.  This binding will help by putting parens around the current selection,
# or if nothing is selected, the whole line.
Set-PSReadLineKeyHandler -Key 'Alt+(' `
  -BriefDescription ParenthesizeSelection `
  -LongDescription "Put parenthesis around the selection or entire line and move the cursor to after the closing parenthesis" `
  -ScriptBlock {
  param($key, $arg)

  $selectionStart = $null
  $selectionLength = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  if ($selectionStart -ne -1) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, '(' + $line.SubString($selectionStart, $selectionLength) + ')')
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
  }
  else {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, '(' + $line + ')')
    [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
  }
}

# This example will replace any aliases on the command line with the resolved commands.
Set-PSReadLineKeyHandler -Key "Alt+%" `
  -BriefDescription ExpandAliases `
  -LongDescription "Replace all aliases with the full command" `
  -ScriptBlock {
  param($key, $arg)

  $ast = $null
  $tokens = $null
  $errors = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

  $startAdjustment = 0
  foreach ($token in $tokens) {
    if ($token.TokenFlags -band [TokenFlags]::CommandName) {
      $alias = $ExecutionContext.InvokeCommand.GetCommand($token.Extent.Text, 'Alias')
      if ($alias -ne $null) {
        $resolvedCommand = $alias.ResolvedCommandName
        if ($resolvedCommand -ne $null) {
          $extent = $token.Extent
          $length = $extent.EndOffset - $extent.StartOffset
          [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
            $extent.StartOffset + $startAdjustment,
            $length,
            $resolvedCommand)

          # Our copy of the tokens won't have been updated, so we need to
          # adjust by the difference in length
          $startAdjustment += ($resolvedCommand.Length - $length)
        }
      }
    }
  }
}

# F1 for help on the command line - naturally
Set-PSReadLineKeyHandler -Key F1 `
  -BriefDescription CommandHelp `
  -LongDescription "Open the help window for the current command" `
  -ScriptBlock {
  param($key, $arg)

  $ast = $null
  $tokens = $null
  $errors = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

  $commandAst = $ast.FindAll( {
      $node = $args[0]
      $node -is [CommandAst] -and
      $node.Extent.StartOffset -le $cursor -and
      $node.Extent.EndOffset -ge $cursor
    }, $true) | Select-Object -Last 1

  if ($commandAst -ne $null) {
    $commandName = $commandAst.GetCommandName()
    if ($commandName -ne $null) {
      $command = $ExecutionContext.InvokeCommand.GetCommand($commandName, 'All')
      if ($command -is [AliasInfo]) {
        $commandName = $command.ResolvedCommandName
      }

      if ($commandName -ne $null) {
        Get-Help $commandName -ShowWindow
      }
    }
  }
}

# Cycle through arguments on current line and select the text. This makes it easier to quickly change the argument if re-running a previously run command from the history
# or if using a psreadline predictor. You can also use a digit argument to specify which argument you want to select, i.e. Alt+1, Alt+a selects the first argument
# on the command line.
Set-PSReadLineKeyHandler -Key Alt+a `
  -BriefDescription SelectCommandArguments `
  -LongDescription "Set current selection to next command argument in the command line. Use of digit argument selects argument by position" `
  -ScriptBlock {
  param($key, $arg)

  $ast = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$null, [ref]$null, [ref]$cursor)

  $asts = $ast.FindAll( {
      $args[0] -is [System.Management.Automation.Language.ExpressionAst] -and
      $args[0].Parent -is [System.Management.Automation.Language.CommandAst] -and
      $args[0].Extent.StartOffset -ne $args[0].Parent.Extent.StartOffset
    }, $true)

  if ($asts.Count -eq 0) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Ding()
    return
  }

  $nextAst = $null

  if ($null -ne $arg) {
    $nextAst = $asts[$arg - 1]
  }
  else {
    foreach ($ast in $asts) {
      if ($ast.Extent.StartOffset -ge $cursor) {
        $nextAst = $ast
        break
      }
    }

    if ($null -eq $nextAst) {
      $nextAst = $asts[0]
    }
  }

  $startOffsetAdjustment = 0
  $endOffsetAdjustment = 0

  if ($nextAst -is [System.Management.Automation.Language.StringConstantExpressionAst] -and
    $nextAst.StringConstantType -ne [System.Management.Automation.Language.StringConstantType]::BareWord) {
    $startOffsetAdjustment = 1
    $endOffsetAdjustment = 2
  }

  [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($nextAst.Extent.StartOffset + $startOffsetAdjustment)
  [Microsoft.PowerShell.PSConsoleReadLine]::SetMark($null, $null)
  [Microsoft.PowerShell.PSConsoleReadLine]::SelectForwardChar($null, ($nextAst.Extent.EndOffset - $nextAst.Extent.StartOffset) - $endOffsetAdjustment)
}

# ==================================================
#   History
# ==================================================

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -EditMode Windows

$WindowSize = (Get-Host).UI.RawUI.WindowSize
if ($WindowSize.Width -ge 54 -and $WindowSize.Height -ge 15) {
  Set-PSReadLineOption -PredictionViewStyle ListView
}

# This key handler shows the entire or filtered history using Out-GridView. The
# typed text is used as the substring pattern for filtering. A selected command
# is inserted to the command line without invoking. Multiple command selection
# is supported, e.g. selected by Ctrl + Click.
Set-PSReadLineKeyHandler -Key F7 `
  -BriefDescription History `
  -LongDescription 'Show command history' `
  -ScriptBlock {
  $pattern = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$pattern, [ref]$null)
  if ($pattern) {
    $pattern = [regex]::Escape($pattern)
  }

  $history = [System.Collections.ArrayList]@(
    $last = ''
    $lines = ''
    foreach ($line in [System.IO.File]::ReadLines((Get-PSReadLineOption).HistorySavePath)) {
      if ($line.EndsWith('`')) {
        $line = $line.Substring(0, $line.Length - 1)
        $lines = if ($lines) {
          "$lines`n$line"
        }
        else {
          $line
        }
        continue
      }

      if ($lines) {
        $line = "$lines`n$line"
        $lines = ''
      }

      if (($line -cne $last) -and (!$pattern -or ($line -match $pattern))) {
        $last = $line
        $line
      }
    }
  )
  $history.Reverse()

  $command = $history | Out-GridView -Title History -PassThru
  if ($command) {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command -join "`n"))
  }
}

# Sometimes you enter a command but realize you forgot to do something else first.
# This binding will let you save that command in the history so you can recall it,
# but it doesn't actually execute.  It also clears the line with RevertLine so the
# undo stack is reset - though redo will still reconstruct the command line.
Set-PSReadLineKeyHandler -Key Alt+w `
  -BriefDescription SaveInHistory `
  -LongDescription "Save current line in history but do not execute" `
  -ScriptBlock {
  param($key, $arg)

  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($line)
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
}

# ==================================================
#   Development
# ==================================================

Set-PSReadLineKeyHandler -Key Ctrl+Shift+b `
  -BriefDescription BuildCurrentDirectory `
  -LongDescription "Build the current directory" `
  -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  if (Test-Path -Path ".\package.json") {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("npm run build")
  }
  else {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("dotnet build")
  }
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Key Ctrl+Shift+r `
  -BriefDescription TestCurrentDirectory `
  -LongDescription "Test the current directory" `
  -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  if (Test-Path -Path ".\package.json") {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("npm run test")
  }
  else {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("dotnet test")
  }
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# ==================================================
#   Command auto complete
# ==================================================

Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
  param($commandName, $wordToComplete, $cursorPosition)
  dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}

Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)
  [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
  $Local:word = $wordToComplete.Replace('"', '""')
  $Local:ast = $commandAst.ToString().Replace('"', '""')
  winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}


# ==================================================
#   Profile
# ==================================================

$PSProfile = $PROFILE.CurrentUserAllHosts
function Open-PwshProfile {
  code $PSProfile
}
Set-Alias profile Open-PwshProfile


# Import a local override file if it exists
$LocalProfileOverride = "$PSScriptRoot/local_profile.ps1"
if (Test-Path $LocalProfileOverride -PathType Leaf) {
  . $LocalProfileOverride
}
