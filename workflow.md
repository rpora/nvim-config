# Plan d’implémentation — Workflow Neovim ↔ Codex

## 1. Objectif

Améliorer le workflow existant entre Neovim et Codex sans ajouter de plugin IA ni remplacer Codex CLI.

L’objectif est de faciliter la collecte, la structuration et la copie de contexte depuis Neovim vers Codex, tout en conservant :

- Codex comme agent principal ;
- le presse-papiers système comme moyen de transfert ;
- des opérations explicites et inspectables ;
- des chemins relatifs à la racine Git ;
- un fonctionnement compatible avec le workflow quickfix, Gitsigns, diagnostics LSP et fichiers temporaires locaux.

Le système doit compléter les mappings existants :

- `<leader>cp` : chemin relatif au projet ;
- `<leader>cl` : `chemin:ligne` ;
- `<leader>cs` : `chemin:ligne:symbole` ;
- `<leader>cr` : `chemin:{début-fin}` ;
- `<leader>cR` : référence + code sélectionné dans un bloc Markdown ;
- `:CopyRelPath`.

## 2. Principes de conception

Le système ne doit pas envoyer automatiquement de contenu vers Codex ou vers un terminal tmux.

Toutes les données destinées à Codex doivent être :

- copiées explicitement dans le presse-papiers ;
- ou saisies et collées explicitement dans un buffer de prompt ;
- consultables et modifiables avant envoi ;
- formatées en Markdown lisible ;
- indépendantes de Codex et de son interface.

Éviter :

- les appels directs à Codex depuis Neovim ;
- `tmux send-keys` ;
- les dépendances à CodeCompanion ou à un autre plugin IA ;
- la multiplication de prompts prédéfinis ;
- les comportements implicites difficiles à inspecter.

## 3. Architecture proposée

Regrouper les fonctionnalités dans un module Lua dédié.

Structure suggérée :

```text
lua/
└── custom/
    └── agent_context/
        ├── init.lua
        ├── path.lua
        ├── selection.lua
        ├── prompt.lua
        ├── git.lua
        ├── diagnostics.lua
        ├── quickfix.lua
        └── annotations.lua
```

Le module principal doit exposer une API stable :

```lua
local agent_context = require("user.agent_context")

agent_context.open_prompt()
agent_context.copy_file_diff()
agent_context.copy_current_hunk()
agent_context.copy_buffer_diagnostics()
agent_context.copy_cursor_diagnostics()
agent_context.copy_quickfix()
agent_context.populate_ai_comments_quickfix()
```

Réutiliser autant que possible les fonctions existantes de résolution de racine Git, de copie de chemin et de récupération de sélection.

## 4. Convention de formatage

Tous les contextes complexes doivent être produits en Markdown.

### Référence de sélection

````markdown
app/features/example/file.ts:{20-34} — myFunction

```ts
const example = () => {
  // ...
};
```
````

Le symbole est facultatif lorsqu’il ne peut pas être déterminé.

### Diff d’un fichier

````markdown
## Diff — app/features/example/file.ts

```diff
diff --git a/app/features/example/file.ts b/app/features/example/file.ts
...
```
````

### Hunk courant

````markdown
## Hunk — app/features/example/file.ts:{20-34}

```diff
@@ -18,8 +18,12 @@
...
```
````

### Diagnostics

```markdown
## Diagnostics — app/features/example/file.ts

- `23:14` error `TS2345` — Argument of type ...
- `48:8` warning `eslint` — Unexpected ...
```

### Quickfix

```markdown
## Quickfix

- `app/foo.ts:12:3` — error message
- `app/bar.ts:48:8` — another issue
```

## 5. Étape 1 — Extraire et consolider les utilitaires existants

### Objectif

Éviter de dupliquer la logique déjà utilisée par les mappings `cp`, `cl`, `cs`, `cr` et `cR`.

### Travail attendu

Identifier et isoler les fonctions existantes pour :

- trouver la racine Git ;
- produire un chemin relatif à la racine Git ;
- récupérer le chemin du buffer courant ;
- récupérer une sélection visuelle ;
- récupérer les lignes de début et de fin ;
- détecter le filetype ;
- détecter le symbole courant ;
- copier du texte dans le presse-papiers système ;
- afficher une notification de succès ou d’erreur.

Créer une API interne cohérente :

```lua
get_git_root(bufnr)
get_relative_path(bufnr)
get_visual_selection()
get_visual_range()
get_current_symbol(bufnr)
get_markdown_fence(bufnr)
copy_to_clipboard(text)
notify_copy(label, text)
```

### Contraintes

La récupération de sélection doit :

- préserver les retours à la ligne ;
- fonctionner avec une sélection ligne par ligne ;
- gérer raisonnablement les sélections caractère par caractère ;
- ne pas modifier les registres utilisateur si possible ;
- fonctionner avec `clipboard=unnamedplus`.

### Critères d’acceptation

- Les mappings existants continuent de fonctionner.
- La nouvelle implémentation n’introduit pas de régression sur les chemins relatifs Git.
- Les buffers non associés à un fichier produisent une erreur claire.
- Les fichiers hors dépôt Git sont gérés explicitement.

## 6. Étape 2 — Créer le buffer de construction de prompt

### Commande

```vim
:CodexPrompt
```

### Mapping suggéré

```text
<leader>ao
```

### Objectif

Fournir un espace éditable permettant de construire progressivement une demande destinée à Codex.

### Comportement attendu

La commande ouvre ou réutilise un buffer dédié nommé par exemple :

```text
codex://prompt
```

Le buffer doit être :

- de type `nofile` ou `acwrite` ;
- non listé, si cela reste pratique ;
- non versionné ;
- en filetype Markdown ;
- persistant pendant la session Neovim ;
- réutilisé lors des ouvertures suivantes.

Le buffer est vide lors de sa création. Son contenu est entièrement rédigé ou
collé manuellement par l’utilisateur.

### Décision de persistance

Implémenter d’abord un buffer mémoire `nofile`.

Prévoir l’architecture pour permettre ultérieurement une variante persistante dans :

```text
.agents-work/prompts/current.md
```

Ne pas ajouter cette persistance dans la première version sauf si elle est trivialement compatible avec le setup existant.

### Critères d’acceptation

- `:CodexPrompt` ouvre toujours le même buffer pendant la session.
- Le contenu n’est pas réinitialisé à chaque ouverture.
- Le buffer est vide lors de sa première création.
- Le buffer s’ouvre dans un split prévisible.
- Le filetype est `markdown`.

## 7. Étape 3 — Insertion directe abandonnée

Ne pas ajouter de fonctions ou de mappings qui insèrent automatiquement des
références ou des sélections dans le prompt.

Les mappings `cp`, `cl`, `cs`, `cr` et `cR` restent les seuls moyens de produire
ces contextes. Ils les copient dans le presse-papiers, puis l’utilisateur choisit
explicitement où les coller.

## 8. Étape 4 — Copier le prompt complet

### Commande

```vim
:CopyCodexPrompt
````

### Mapping suggéré

```text
<leader>ac
```

Le mapping peut être actif uniquement dans le buffer Codex ou globalement.

### Objectif

Copier l’intégralité du prompt construit dans le presse-papiers système.

### Comportement attendu

- récupérer toutes les lignes du buffer Codex ;
- supprimer éventuellement les lignes vides terminales ;
- copier le contenu dans le registre système ;
- notifier le nombre de lignes ou de caractères copiés.

### Commande complémentaire

```vim
:ClearCodexPrompt
```

Mapping suggéré :

```text
<leader>ax
```

Cette commande doit demander confirmation avant de vider le buffer.

### Critères d’acceptation

- Le contenu collé dans Codex correspond exactement au buffer.
- Le prompt peut être copié même si son buffer n’est pas visible.
- La commande échoue proprement si aucun buffer Codex n’existe.

## 9. Étape 5 — Copier le diff Git du fichier courant

> Implémentée. Le mapping Fugitive `Gdiffsplit` précédemment associé à
> `<leader>cd` est temporairement désactivé.

### Mapping suggéré

```text
<leader>cd
```

### Commande

```vim
:CopyFileDiff
```

### Objectif

Copier les changements non commités du fichier courant.

### Commande Git cible

Depuis la racine du dépôt :

```bash
git diff --no-ext-diff --relative -- path/to/file
```

Prendre également en compte les changements indexés.

Options possibles :

- version initiale : uniquement `git diff` ;
- version améliorée : concaténer le diff unstaged et staged.

Format recommandé :

````markdown
## Diff unstaged — app/features/example/file.ts

```diff
...
```
````

## Diff staged — app/features/example/file.ts

```diff
...
```

````

Ne pas afficher les sections vides.

### Implémentation

Utiliser `vim.system` si la version de Neovim le permet.

Exécuter la commande avec :

- `cwd` réglé sur la racine Git ;
- des arguments séparés ;
- aucune concaténation shell fragile ;
- une gestion explicite du code de retour.

### Cas particuliers

- fichier non suivi ;
- fichier supprimé ;
- fichier renommé ;
- absence de changement ;
- dépôt Git absent.

Pour les fichiers non suivis, produire éventuellement un diff synthétique avec :

```bash
git diff --no-index -- /dev/null path/to/file
````

Cette prise en charge peut être une seconde itération.

### Critères d’acceptation

- Le diff est relatif au dépôt.
- Les espaces dans les chemins sont supportés.
- Un fichier sans modification produit une notification claire.
- Aucun shell escaping manuel n’est nécessaire.

## 10. Étape 6 — Copier le hunk Git courant

> Implémentée avec l’API publique `gitsigns.get_hunks()` pour identifier la
> modification sous le curseur, puis
> `git diff --diff-algorithm=patience --unified=0` pour reproduire la
> granularité de `Gitsigns preview_hunk` sans `linematch`, plutôt que le
> sous-hunk d’une ligne exposé par `gitsigns.get_hunks()`.

### Mapping suggéré

```text
<leader>ch
```

### Commande

```vim
:CopyCurrentHunk
```

### Objectif

Copier uniquement le hunk Git situé sous le curseur.

### Intégration privilégiée

Réutiliser Gitsigns, déjà présent dans la configuration.

Explorer l’API publique de Gitsigns permettant de récupérer :

- les hunks du buffer ;
- les lignes de début et de fin ;
- le contenu ajouté et supprimé ;
- le hunk contenant la ligne du curseur.

Ne pas dépendre d’une API interne non documentée si une API publique existe.

### Format attendu

````markdown
## Hunk — app/features/example/file.ts:{20-34}

```diff
@@ -18,8 +18,12 @@
...
```
````

````

### Alternative de repli

Si Gitsigns ne fournit pas directement le texte du patch :

1. récupérer la plage du hunk courant ;
2. exécuter `git diff` sur le fichier ;
3. parser les entêtes `@@`;
4. sélectionner le hunk contenant la ligne courante.

Cette alternative doit rester isolée dans le module Git.

### Critères d’acceptation

- Le hunk sous le curseur est correctement identifié.
- Un curseur hors hunk produit un message clair.
- Le contexte copié inclut le chemin et la plage de lignes.
- Le diff est directement collable dans Codex.

## 11. Étape 7 — Copier les diagnostics LSP

> Implémentée.

### Mappings suggérés

```text
<leader>ce
<leader>cE
````

### Commandes

```vim
:CopyBufferDiagnostics
:CopyCursorDiagnostics
```

### Objectif

Copier soit tous les diagnostics du buffer, soit uniquement ceux de la ligne ou de la position courante.

### Source

Utiliser :

```lua
vim.diagnostic.get(bufnr)
```

### Format

```markdown
## Diagnostics — app/features/example/file.ts

- `23:14` error `TS2345` — Argument of type ...
- `48:8` warning `eslint` — Unexpected ...
```

Inclure lorsque disponible :

- ligne ;
- colonne ;
- sévérité ;
- code ;
- source ;
- message.

Normaliser les messages multilignes afin de conserver un résultat lisible.

### Tri

Trier par :

1. numéro de ligne ;
2. colonne ;
3. sévérité.

### Diagnostic sous le curseur

Pour `<leader>cE`, récupérer les diagnostics :

- sur la ligne courante ;
- ou couvrant la position courante lorsque les bornes sont disponibles.

### Critères d’acceptation

- Aucun diagnostic produit une notification claire.
- Les positions affichées sont en base 1.
- Les diagnostics multiline ne cassent pas le Markdown.
- Le résultat est copié dans le presse-papiers.

## 12. Étape 8 — Copier la quickfix

> Implémentée avec une limite initiale de 200 entrées.

### Commande

```vim
:CopyQuickfix
```

### Mapping suggéré

```text
<leader>cq
```

### Objectif

Transformer la quickfix courante en contexte compact pour Codex.

### Source

Utiliser :

```lua
vim.fn.getqflist({
  title = 1,
  items = 1,
  context = 1,
})
```

### Format

```markdown
## Quickfix — Ripgrep results

- `app/foo.ts:12:3` — matching text
- `app/bar.ts:48:8` — another match
```

Pour chaque entrée :

- résoudre le nom de fichier depuis `bufnr` ou `filename` ;
- convertir le chemin en relatif Git lorsque possible ;
- inclure ligne et colonne ;
- inclure le texte ;
- ignorer proprement les entrées invalides.

### Limite de taille

Prévoir une limite configurable, par exemple :

```lua
max_quickfix_items = 200
```

Si la liste dépasse cette limite :

- copier les premiers éléments ;
- ajouter une indication du nombre d’éléments omis ;
- notifier que la sortie a été tronquée.

### Critères d’acceptation

- Fonctionne avec ripgrep, diagnostics et résultats Git.
- La quickfix vide est gérée proprement.
- Les chemins sont relatifs lorsque possible.
- Les entrées invalides ne font pas échouer l’ensemble.

## 13. Étape 9 — Ajouter les annotations temporaires `AI:*`

### Convention

Supporter les marqueurs :

```text
AI:QUESTION
AI:REVIEW
AI:CHANGE
AI:BUG
AI:TEST
```

Exemples :

```ts
// AI:REVIEW This fallback may hide a domain error.
```

```ts
// AI:CHANGE
// Extract this branch into a dedicated policy.
```

### Commande

```vim
:AiComments
```

### Mapping suggéré

```text
<leader>cA
```

### Objectif

Rechercher tous les marqueurs `AI:*` dans le dépôt et les charger dans la quickfix.

### Implémentation privilégiée

Exécuter `rg` depuis la racine Git :

```bash
rg --vimgrep 'AI:(QUESTION|REVIEW|CHANGE|BUG|TEST)'
```

Transformer les résultats en entrées quickfix.

Définir un titre explicite :

```text
AI annotations
```

Ouvrir la quickfix après population.

### Exclusions

Respecter les règles Git et ripgrep par défaut.

Ajouter éventuellement des exclusions configurables :

```lua
ai_comment_globs = {
  "!node_modules",
  "!dist",
  "!build",
}
```

### Commande complémentaire

```vim
:CopyAiComments
```

Cette commande peut :

1. reconstruire la quickfix des annotations ;
2. produire directement une sortie Markdown ;
3. copier cette sortie dans le presse-papiers.

Format :

```markdown
## AI annotations

- `app/foo.ts:42:1` — `AI:REVIEW` This fallback may hide a domain error.
- `app/bar.ts:18:1` — `AI:TEST` Add a regression test for the empty case.
```

### Critères d’acceptation

- Les cinq catégories sont reconnues.
- La quickfix permet de naviguer entre les annotations.
- Les résultats utilisent des chemins relatifs.
- Aucun résultat produit une notification claire.

## 14. Étape 10 — Ajouter le diff global du dépôt

### Mapping suggéré

```text
<leader>cD
```

### Commande

```vim
:CopyRepoDiff
```

### Objectif

Copier l’ensemble des modifications actives du dépôt pour une review globale.

### Comportement

Produire :

- le diff unstaged ;
- le diff staged ;
- éventuellement la liste des fichiers non suivis.

Format :

````markdown
# Repository changes

## Unstaged

```diff
...
```
````

## Staged

```diff
...
```

## Untracked files

- `app/example/new-file.ts`

````

### Protection contre les sorties trop volumineuses

Introduire une limite configurable :

```lua
max_diff_bytes = 200000
````

En cas de dépassement :

- ne pas copier silencieusement une sortie tronquée ;
- avertir l’utilisateur ;
- proposer dans le message d’utiliser le diff d’un fichier ou d’un hunk.

Une troncature explicite peut être acceptable si elle est clairement signalée dans le contenu copié.

### Critères d’acceptation

- Le diff global est lisible et structuré.
- Les sections vides sont omises.
- Les sorties excessives sont détectées.
- Le dépôt sans changement est géré proprement.

## 15. Configuration publique

Prévoir une fonction `setup`.

Exemple :

```lua
require("user.codex_context").setup({
  prompt = {
    buffer_name = "codex://prompt",
    split = "vertical",
    width = 90,
  },

  quickfix = {
    max_items = 200,
  },

  git = {
    max_diff_bytes = 200000,
    include_staged = true,
    include_untracked = true,
  },

  annotations = {
    tags = {
      "QUESTION",
      "REVIEW",
      "CHANGE",
      "BUG",
      "TEST",
    },
  },
})
```

Ne pas sur-concevoir cette configuration.

Commencer uniquement avec les options réellement utiles.

## 16. Mappings finaux proposés

Conserver les mappings actuels et ajouter :

```text
<leader>ao    ouvrir le buffer Codex
<leader>ac    copier le prompt Codex
<leader>ax    vider le prompt Codex

<leader>cd    copier le diff du fichier courant
<leader>cD    copier le diff global du dépôt
<leader>ch    copier le hunk courant

<leader>ce    copier les diagnostics du buffer
<leader>cE    copier les diagnostics sous le curseur

<leader>cq    copier la quickfix
<leader>cA    charger les annotations AI:* dans la quickfix
```

Éviter les conflits avec les mappings existants.

Les commandes Ex doivent rester disponibles indépendamment des mappings.

## 17. Notifications

Toutes les actions doivent fournir une notification courte.

Exemples :

```text
Copied file diff: app/features/foo.ts
Added selection to Codex prompt: app/features/foo.ts:{20-34}
Copied 14 diagnostics
Quickfix copied: 37 entries
No Git hunk under cursor
No AI annotations found
```

Utiliser `vim.notify` avec des niveaux adaptés :

- `INFO` pour les succès ;
- `WARN` pour les listes vides ou sorties tronquées ;
- `ERROR` pour les erreurs Git ou les buffers invalides.

Ne pas afficher le contenu complet dans les notifications.

## 18. Gestion des erreurs

Prévoir explicitement :

- buffer sans fichier ;
- fichier inexistant ;
- dépôt Git absent ;
- commande `git` indisponible ;
- commande `rg` indisponible ;
- Gitsigns non chargé ;
- sélection vide ;
- quickfix vide ;
- aucun diagnostic ;
- aucun hunk sous le curseur ;
- prompt buffer absent ;
- sortie Git trop importante ;
- erreur d’exécution de commande externe.

Les erreurs ne doivent jamais laisser Neovim dans un état incohérent.

## 19. Tests manuels attendus

### Chemins

- fichier à la racine ;
- fichier dans un sous-répertoire ;
- nom de fichier contenant des espaces ;
- buffer hors dépôt Git ;
- buffer non sauvegardé.

### Sélections

- sélection d’une ligne ;
- sélection multiline ;
- sélection partielle ;
- sélection contenant des backticks ;
- sélection dans différents filetypes.

### Prompt

- ouverture/fermeture répétée ;
- copie complète ;
- nettoyage ;
- buffer Codex non visible.

### Git

- fichier unstaged ;
- fichier staged ;
- fichier avec les deux types de changements ;
- fichier sans changement ;
- fichier non suivi ;
- plusieurs hunks ;
- curseur entre deux hunks ;
- dépôt sans modification.

### Diagnostics

- erreur unique ;
- plusieurs diagnostics ;
- diagnostic multiline ;
- diagnostic sans code ;
- aucun diagnostic ;
- diagnostic sous le curseur.

### Quickfix

- résultats ripgrep ;
- diagnostics ;
- quickfix vide ;
- entrées sans fichier ;
- liste supérieure à la limite.

### Annotations

- chaque catégorie `AI:*` ;
- plusieurs annotations dans un fichier ;
- plusieurs fichiers ;
- aucune annotation ;
- texte multiline après un marqueur.

## 20. Ordre d’implémentation recommandé

### Phase 1 — Fondations

1. Extraire les utilitaires existants.
2. Stabiliser la résolution de racine Git et de chemins relatifs.
3. Stabiliser la récupération des sélections.
4. Ajouter le helper de copie presse-papiers.
5. Vérifier les mappings existants.

### Phase 2 — Prompt buffer

1. Implémenter `:CodexPrompt`.
2. Implémenter la copie du prompt.
3. Implémenter le nettoyage du prompt.

Cette phase constitue le premier jalon utilisable.

### Phase 3 — Contextes techniques

1. Diff du fichier.
2. Diagnostics du buffer.
3. Diagnostics sous le curseur.
4. Copie de quickfix.

Cette phase apporte le meilleur rapport valeur/complexité.

### Phase 4 — Intégration Git avancée

1. Hunk courant.
2. Diff global du dépôt.
3. Gestion des fichiers non suivis.
4. Limites de taille.

### Phase 5 — Annotations `AI:*`

1. Recherche ripgrep.
2. Population quickfix.
3. Copie Markdown.
4. Documentation du workflow.

## 21. Définition de terminé

Le travail est terminé lorsque :

- les mappings existants sont conservés ;
- le buffer Codex peut recevoir manuellement plusieurs contextes copiés ;
- son contenu peut être copié intégralement ;
- le diff d’un fichier peut être copié ;
- le hunk courant peut être copié ;
- les diagnostics peuvent être copiés ;
- la quickfix peut être copiée ;
- les annotations `AI:*` peuvent être listées ;
- toutes les sorties utilisent des chemins relatifs Git ;
- toutes les sorties sont lisibles en Markdown ;
- les erreurs fréquentes sont gérées explicitement ;
- aucune dépendance à un plugin IA n’est introduite ;
- aucune donnée n’est envoyée automatiquement vers Codex ;
- les fonctions principales sont documentées dans la configuration Neovim.

## 22. Contraintes pour l’implémentation par l’agent

Avant d’implémenter :

1. inspecter les fonctions Lua existantes responsables de `cp`, `cl`, `cs`, `cr` et `cR` ;
2. réutiliser leur logique au lieu de la remplacer sans nécessité ;
3. respecter l’organisation actuelle de la configuration Neovim ;
4. vérifier la version de Neovim et les APIs disponibles ;
5. vérifier l’API publique de Gitsigns installée ;
6. vérifier les conventions existantes de mappings et de notifications.

Pendant l’implémentation :

- procéder par petits commits logiques ;
- ne pas modifier les comportements existants sans raison ;
- ne pas ajouter de dépendance externe non nécessaire ;
- privilégier les APIs Neovim natives ;
- utiliser `vim.system` plutôt que des commandes shell concaténées ;
- garder chaque fonction testable indépendamment ;
- documenter les éventuelles limitations.

À la fin :

- présenter la liste des fichiers modifiés ;
- présenter les mappings ajoutés ;
- décrire les cas limites non pris en charge ;
- fournir un protocole court de test manuel ;
- ne pas étendre le périmètre à une intégration directe avec Codex ou tmux.
