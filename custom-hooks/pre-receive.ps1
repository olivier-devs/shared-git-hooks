# Types de branches autorisés
$ValidBranchTypes = @(
    'feature',
    'bugfix',
    'hotfix',
    'release',
    'chore',
    'doc',
    'experiment'
)

# Fonction pour afficher une erreur et sortir
function Write-BranchError {
    param([string]$Message)
    Write-Error $Message
    exit 1
}

# Lecture du nom de la branche depuis l'entrée standard
# Dans un hook pre-receive, Git envoie les références via stdin
$Input = $input | Out-String
if (-not $Input) {
    exit 0
}

# Parsing de l'entrée (format: <old-value> <new-value> <ref-name>)
$InputParts = $Input -split ' '
$RefName = $InputParts[2]

# Extraction du nom de la branche depuis la référence
# refs/heads/feature/ma-branche -> feature/ma-branche
if ($RefName -match '^refs/heads/(.+)$') {
    $BranchName = $Matches[1]
}
else {
    exit 0  # Pas une branche, on ignore
}

# Regex pour valider le format du nom de branche
# Format: type/description-en-minuscules
$BranchPattern = '^(?<type>[a-z]+)/(?<description>[a-z0-9-]+)$'

if ($BranchName -match $BranchPattern) {
    $Type = $Matches.type
    $Description = $Matches.description

    # Validation du type
    if ($ValidBranchTypes -notcontains $Type) {
        Write-BranchError "Le type de branche '$Type' n'est pas autorisé. Types autorisés : $($ValidBranchTypes -join ', ')"
    }

    # Validation des caractères de la description
    if ($Description -match '[^a-z0-9-]') {
        Write-BranchError "Le nom de branche contient des caractères non autorisés. Utilisez uniquement des lettres minuscules et des tirets"
    }

    # Validation du format de la description
    if ($Description -match '-{2,}') {
        Write-BranchError "Le nom de branche ne doit pas contenir plusieurs tirets consécutifs"
    }

    if ($Description -match '^-|-$') {
        Write-BranchError "Le nom de branche ne doit pas commencer ou finir par un tiret"
    }
}
else {
    Write-BranchError "Le format du nom de branche ne respecte pas la convention : type/description-en-minuscules"
}

# Si toutes les validations sont passées, on sort avec succès
exit 0 