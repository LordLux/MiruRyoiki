(Get-Content -Path 'lib/utils/shell.dart' -Raw) -replace 'int _enumWindowsCallbackImpl','static int _enumWindowsCallbackImpl' | Set-Content -Path 'lib/utils/shell.dart'
