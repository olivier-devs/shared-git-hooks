# ------------------------------------------------ #
# Contrôle de la protection de la branche courante #
# ------------------------------------------------ #

# Récupération du nom de la branche courante
$CurrentBranch = git branch --show-current

# Liste des branches protégées
$ProtectedBranches = @("^master$", "^main$", "^develop$", "^release/")

# Vérification si la branche courante est protégée
if ($ProtectedBranches -imatch $CurrentBranch) {
    Write-Error "Vous ne pouvez pas commiter sur la branche '$CurrentBranch' car elle est protégée."
    Write-Output "Veuillez commiter sur une branche de type feature, bugfix, hotfix, experiment, chore ou doc."
    exit 1
}

# ------------------------------ #
# Validation du style de code C# #
# ------------------------------ #

# Récupération des fichiers C# modifiés
# --name-only : Affiche uniquement les noms des fichiers modifiés (pas le contenu des modifications)
# --cached : Examine uniquement les fichiers qui sont dans la zone de staging (index)
# --diff-filter=ACMR : A = fichier ajouté, C = fichier copié, M = fichier modifié, R = fichier renommé
$CSharpModifiedFiles = git diff --name-only --cached --diff-filter=ACMR | Where-Object { $_.EndsWith(".cs") }

if ($CSharpModifiedFiles) {
    Write-Output "Validation du style de code C# en cours..."

    # Recherche du fichier solution (.sln) dans le répertoire git
    $SolutionFile = Get-ChildItem -Path (git rev-parse --show-toplevel) -Filter "*.sln" -Recurse -File | Select-Object -First 1

    # Si pas de solution, recherche des fichiers projet (.csproj)
    if (-not $SolutionFile) {
        $ProjectFiles = Get-ChildItem -Path (git rev-parse --show-toplevel) -Filter "*.csproj" -Recurse -File
        
        if (-not $ProjectFiles) {
            Write-Error "Aucun fichier .sln ou .csproj trouvé dans le dépôt. Impossible de valider le style de code C#."
            exit 1
        }

        # Trouve le projet le plus pertinent (celui qui contient les fichiers modifiés)
        foreach ($CSharpFile in $CSharpModifiedFiles) {
            $FileDirectory = Split-Path -Parent $CSharpFile
            $ClosestProject = $ProjectFiles | Where-Object { $CSharpFile.StartsWith($_.Directory.FullName) } | Select-Object -First 1
            
            if ($ClosestProject) {
                # Exécution de dotnet format avec le projet trouvé
                Write-Output "Utilisation du projet : $($ClosestProject.FullName)"
                dotnet format --verify-no-changes "$($ClosestProject.FullName)" --include $CSharpModifiedFiles

                if ($LASTEXITCODE -ne 0) {
                    Write-Error "Le style de code C# n'est pas valide. Veuillez corriger les erreurs avant de commiter."
                    exit 1
                }
                break
            }
        }
    }
    else {
        # Utilisation du fichier solution trouvé
        Write-Output "Utilisation de la solution : $($SolutionFile.FullName)"
        dotnet format --verify-no-changes "$($SolutionFile.FullName)" --include $CSharpModifiedFiles

        if ($LASTEXITCODE -ne 0) {
            Write-Error "Le style de code C# n'est pas valide. Veuillez corriger les erreurs avant de commiter."
            exit 1
        }
    }
}

exit 0