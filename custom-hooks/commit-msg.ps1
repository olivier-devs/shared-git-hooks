# Récupération du fichier contenant le message de commit
param(
    [Parameter(Mandatory=$true)]
    [string]$CommitMessageFile
)

# Types de commit autorisés
$ValidTypes = @(
    'feat',
    'fix',
    'docs',
    'style',
    'refactor',
    'perf',
    'test',
    'chore'
)

# Fonction pour afficher une erreur et sortir
function Write-CommitError {
    param([string]$Message)
    Write-Error $Message
    exit 1
}

# Lecture du message de commit
$CommitMessage = Get-Content $CommitMessageFile -Raw
$FirstLine = ($CommitMessage -split "`n")[0].Trim()

# Validation de la longueur maximale
if ($FirstLine.Length -gt 72) {
    Write-CommitError "La première ligne ne doit pas dépasser 72 caractères"
}

# Regex pour valider le format du message
# Format: type(scope): description ou type: description
# Le ! est optionnel pour les breaking changes
$CommitPattern = '^(?<type>[a-z]+)(?:\((?<scope>[a-z0-9-_]+)\))?(?<breaking>!)?:\s(?<description>.+)$'

if ($FirstLine -match $CommitPattern) {
    $Type = $Matches.type
    $Scope = $Matches.scope
    $Breaking = $Matches.breaking
    $Description = $Matches.description

    # Validation du type
    if ($ValidTypes -notcontains $Type) {
        Write-CommitError "Le type '$Type' n'est pas autorisé. Types autorisés : $($ValidTypes -join ', ')"
    }

    # Validation de la description
    if ($Description -cmatch '^[A-Z]') {
        Write-CommitError "La description doit commencer par une lettre minuscule"
    }

    if ($Description -match '\.$') {
        Write-CommitError "La description ne doit pas se terminer par un point"
    }
}
else {
    Write-CommitError "Le format du message ne respecte pas la convention : type(scope): description"
}

# Si toutes les validations sont passées, on sort avec succès
exit 0
