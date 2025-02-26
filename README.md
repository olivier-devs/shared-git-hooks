# Documentation Technique - Hooks Git Personnalisés

## Vue d'ensemble
Ce dépôt contient un ensemble de hooks Git personnalisés qui automatisent différentes validations et formatages lors des opérations Git.

## Prérequis Généraux
- Git
- PowerShell
- .NET SDK (pour la commande `dotnet format`)

## Hooks Disponibles

### 1. Pre-commit Hook (`pre-commit.ps1`)
#### Description
Script PowerShell exécuté avant chaque commit qui effectue des validations automatiques. Il assure deux fonctions principales :
1. La protection des branches sensibles
2. La validation du style de code C#

#### Fonctionnalités

##### Protection des Branches
###### Description
Cette fonctionnalité empêche les commits directs sur les branches protégées.

###### Branches Protégées
- `master`
- `main`
- `develop`
- Toutes les branches commençant par `release/`

###### Comportement
- Vérifie si la branche courante correspond à l'une des branches protégées
- Si oui, le commit est bloqué avec un message d'erreur
- Suggère d'utiliser une branche de type : feature, bugfix, hotfix, experiment, chore ou doc

##### Validation du Style de Code C#
###### Description
Vérifie automatiquement le style du code C# des fichiers modifiés avant le commit.

###### Fonctionnement
1. Identifie tous les fichiers C# (.cs) modifiés dans le staging
2. Exécute `dotnet format` en mode vérification
3. Bloque le commit si des problèmes de style sont détectés

###### Filtres des Fichiers
Ne prend en compte que les fichiers :
- Ajoutés (A)
- Copiés (C)
- Modifiés (M)
- Renommés (R)

#### Codes de Retour
- `0` : Succès - Le commit peut procéder
- `1` : Échec - Le commit est bloqué

#### Messages d'Erreur
- Protection de branche : "Vous ne pouvez pas commiter sur la branche '[nom_branche]' car elle est protégée."
- Style de code : "Le style de code C# n'est pas valide. Veuillez corriger les erreurs avant de commiter."

### 2. Prepare-Commit-Msg Hook (`prepare-commit-msg.ps1`)
#### Description
Script PowerShell exécuté pour préparer le message de commit avant son édition par l'utilisateur. Il assure la standardisation et l'enrichissement automatique des messages de commit.

#### Fonctionnalités

##### Format du Message de Commit
###### Description
Assure la conformité du message avec les conventions de commit.

###### Règles de Format
- Structure : `type(scope): description`
- Types autorisés : feat, fix, docs, style, refactor, perf, test, chore
- Longueur maximale : 72 caractères pour la première ligne
- Préfixage automatique basé sur le nom de la branche

##### Intégration avec les Outils de Gestion
###### Description
Enrichit automatiquement le message avec les références aux outils de gestion de projet.

###### Fonctionnalités
- Extraction du numéro de ticket depuis le nom de la branche
- Ajout automatique des liens vers les tickets
- Application d'un template par défaut

##### Validation Contextuelle
###### Description
Ajoute des informations contextuelles au message de commit.

###### Fonctionnalités
- Gestion des co-auteurs pour les commits collaboratifs
- Détection de contenu sensible
- Tagging automatique selon les fichiers modifiés

##### Enrichissement du Message
###### Description
Ajoute automatiquement des informations pertinentes au message.

###### Informations Ajoutées
- Liste des fichiers impactés
- Contexte d'environnement
- Résumé automatique des changements

#### Codes de Retour
- `0` : Message de commit validé et enrichi
- `1` : Erreur dans le format ou le contenu du message

#### Messages d'Erreur
- Format invalide : "Le format du message de commit ne respecte pas les conventions"
- Contenu sensible : "Le message contient des informations sensibles à retirer"
- Longueur excessive : "La première ligne du message dépasse 72 caractères"

### 3. Commit-Msg Hook (`commit-msg.ps1`)
#### Description
Script PowerShell exécuté après la saisie du message de commit pour valider sa conformité avec la Convention de Commit.

#### Fonctionnalités

##### Validation du Format Conventional Commits
###### Description
Vérifie que le message de commit respecte strictement le format : `type(scope): description`

###### Types Autorisés
- `feat` : Nouvelle fonctionnalité
- `fix` : Correction de bug
- `docs` : Documentation
- `style` : Formatage, point-virgules manquants, etc.
- `refactor` : Refactorisation du code
- `perf` : Amélioration des performances
- `test` : Ajout ou modification de tests
- `chore` : Maintenance

###### Règles de Validation
- Format général : `type(scope): description` ou `type: description`
- Le type doit être en minuscules
- Le scope est optionnel et doit être entre parenthèses
- La description doit commencer par une lettre minuscule
- Pas de point final dans la ligne de titre
- Longueur maximale de la ligne de titre : 72 caractères
- Corps du message optionnel, séparé par une ligne vide
- Breaking changes signalés par "!" après le type/scope

#### Codes de Retour
- `0` : Message de commit valide
- `1` : Message de commit non conforme

#### Messages d'Erreur
- Type invalide : "Le type '{type}' n'est pas autorisé. Types autorisés : feat, fix, docs, style, refactor, perf, test, chore"
- Format incorrect : "Le format du message ne respecte pas la convention : type(scope): description"
- Longueur excessive : "La première ligne ne doit pas dépasser 72 caractères"
- Casse incorrecte : "Le type doit être en minuscules"
- Description invalide : "La description doit commencer par une lettre minuscule"

### 4. Pre-receive Hook (`pre-receive.ps1`)
#### Description
Script PowerShell exécuté lors de la création ou mise à jour d'une branche pour valider sa conformité avec les conventions de nommage.

#### Fonctionnalités

##### Validation du Format des Branches
###### Description
Vérifie que le nom de la branche respecte strictement les conventions de nommage définies.

###### Formats Autorisés
- `feature/*` : Nouvelles fonctionnalités
- `bugfix/*` : Corrections de bugs
- `hotfix/*` : Corrections urgentes
- `release/*` : Branches de release
- `chore/*` : Tâches de maintenance
- `doc/*` : Documentation
- `experiment/*` : Expérimentations

###### Règles de Validation
- Format général : `type/description-en-minuscules`
- Le type doit être l'un des préfixes autorisés
- La description doit être en minuscules
- Les mots de la description doivent être séparés par des tirets
- Pas de caractères spéciaux sauf les tirets
- Si lié à un ticket, doit inclure l'ID (ex: feature/AUTH-123-login-oauth)

#### Codes de Retour
- `0` : Nom de branche valide
- `1` : Nom de branche non conforme

#### Messages d'Erreur
- Type invalide : "Le type de branche '{type}' n'est pas autorisé. Types autorisés : feature, bugfix, hotfix, release, chore, doc, experiment"
- Format incorrect : "Le format du nom de branche ne respecte pas la convention : type/description-en-minuscules"
- Caractères invalides : "Le nom de branche contient des caractères non autorisés. Utilisez uniquement des lettres minuscules et des tirets"

## Installation
*Section à compléter avec les instructions d'installation des hooks*

## Contribution
*Section à compléter avec les règles de contribution au projet*
