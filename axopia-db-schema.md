# Axopia — Spécification base de données

> Document de référence à donner à Claude Code pour générer les migrations SQL.
> SGBD cible : **PostgreSQL**. Architecture : **multi-tenant** (plusieurs organismes clients dans la même base).

---

## Conventions générales

- Noms de tables en **anglais**, `snake_case`, au **pluriel** (`training_centers`, `learners`...)
- Clé primaire : `id UUID DEFAULT gen_random_uuid() PRIMARY KEY`
- Isolation multi-tenant : chaque table métier porte une colonne `organization_id UUID NOT NULL REFERENCES organizations(id)`
- Horodatage systématique : `created_at TIMESTAMPTZ NOT NULL DEFAULT now()`, `updated_at TIMESTAMPTZ NOT NULL DEFAULT now()`
- Suppression : **mixte**, précisée table par table ci-dessous (`soft` = colonne `deleted_at TIMESTAMPTZ NULL`, `hard` = `DELETE` classique avec `ON DELETE CASCADE/RESTRICT` explicite)
- Clés étrangères nommées `<nom_singulier>_id` (ex: `training_center_id`)
- Enums métier : privilégier des tables de référence (`lookup tables`) plutôt que des `ENUM` Postgres natifs, pour rester éditable sans migration — sauf mention contraire

---

## Socle transverse (multi-tenant + droits)

### `audit_logs`
Historique générique des modifications — table neutre, indépendante d'un gem précis (PaperTrail, Audited, ou un concern maison) : polymorphique, couvre `learners` dès maintenant, et n'importe quel autre modèle plus tard (`trainings`, futures entités qualité...) sans nouvelle table à créer. Répond au besoin "qui a coché/modifié une fiche apprenant" sans construire un système d'audit sur-mesure par entité.

| Champ | Type | Contraintes | Notes |
|---|---|---|---|
| id | UUID | PK | |
| auditable_type | TEXT | NOT NULL | Nom du modèle concerné, ex: `Learner` |
| auditable_id | UUID | NOT NULL | id de la ligne modifiée dans sa table d'origine |
| action | TEXT | NOT NULL | `create`, `update`, `destroy` |
| user_id | UUID | NULL, FK → users(id) ON DELETE SET NULL | Auteur de la modification (`NULL` = action système/import automatisé) |
| previous_data | JSONB | NULL | État avant modification |
| changed_data | JSONB | NULL | Différentiel des champs modifiés (avant/après) |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |

*Index à prévoir : `(auditable_type, auditable_id)` — c'est la requête systématique ("historique de cette fiche apprenant précise").*

*Nommage volontairement neutre (`auditable_type`/`auditable_id`/`user_id` plutôt que `item_type`/`whodunnit` façon PaperTrail) pour rester indépendant du choix final : gem existant (PaperTrail, Audited) ou concern maison. Si vous partez sur un concern personnalisé, cette structure reste un bon point de départ — libre à vous d'ajuster les noms de colonnes une fois le choix arrêté, avant la première migration.*

### `legal_statuses`
Table de référence des statuts juridiques (conforme à la convention "lookup table plutôt qu'ENUM natif"). Référentiel technique commun, pas de `organization_id`.

| Champ | Type | Contraintes | Notes |
|---|---|---|---|
| id | UUID | PK | |
| code | TEXT | UNIQUE, NOT NULL | ex: `sas`, `sasu`, `sarl`, `eurl`, `micro_entreprise`, `ei`, `association_loi_1901` |
| label | TEXT | NOT NULL | ex: "SAS", "Micro-entreprise", "Association loi 1901" |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |

*Table à pré-remplir (seed) plutôt qu'alimentée par les utilisateurs — liste fermée des statuts juridiques français courants.*

**Seed à donner à Claude Code :**

```sql
INSERT INTO legal_statuses (code, label) VALUES
  ('ei', 'Entreprise Individuelle (EI)'),
  ('micro_entreprise', 'Micro-entreprise'),
  ('eurl', 'EURL'),
  ('sarl', 'SARL'),
  ('sasu', 'SASU'),
  ('sas', 'SAS'),
  ('sa', 'SA'),
  ('snc', 'SNC (Société en Nom Collectif)'),
  ('sci', 'SCI (Société Civile Immobilière)'),
  ('scop', 'SCOP (Société Coopérative de Production)'),
  ('scic', 'SCIC (Société Coopérative d''Intérêt Collectif)'),
  ('selarl', 'SELARL'),
  ('selas', 'SELAS'),
  ('gie', 'GIE (Groupement d''Intérêt Économique)'),
  ('association_loi_1901', 'Association loi 1901'),
  ('fondation', 'Fondation'),
  ('etablissement_public', 'Établissement public'),
  ('autre', 'Autre');
```

*Cas les plus fréquents pour des organismes de formation : `micro_entreprise`, `eurl`, `sarl`, `sasu`, `sas`, `association_loi_1901`. Les autres sont là pour couvrir les cas plus rares (GIE entre organismes, fondations, établissements publics...). Le code `autre` sert de filet de sécurité si un statut ne correspond à rien de la liste — dites-moi si vous préférez qu'un statut non listé bloque plutôt la saisie (formulaire fermé strict) qu'un `autre` fourre-tout.*

### `qualiopi_action_types`
Table de référence des catégories d'actions couvertes par une certification Qualiopi. Référentiel technique commun, pas de `organization_id`.

| Champ | Type | Contraintes | Notes |
|---|---|---|---|
| id | UUID | PK | |
| code | TEXT | UNIQUE, NOT NULL | `training_actions`, `skills_assessment`, `vae`, `apprenticeship` |
| label | TEXT | NOT NULL | "Actions de formation", "Bilan de compétences", "VAE", "Apprentissage (CFA)" |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |

**Seed à donner à Claude Code :**

```sql
INSERT INTO qualiopi_action_types (code, label) VALUES
  ('training_actions', 'Actions de formation'),
  ('skills_assessment', 'Bilan de compétences'),
  ('vae', 'VAE (Validation des Acquis de l''Expérience)'),
  ('apprenticeship', 'Apprentissage (CFA)');
```

### `organization_qualiopi_actions`
Relation many-to-many : quelles catégories d'actions Qualiopi un organisme couvre.

| Champ | Type | Contraintes | Notes |
|---|---|---|---|
| organization_id | UUID | PK (composite), FK → organizations(id) ON DELETE CASCADE | |
| qualiopi_action_type_id | UUID | PK (composite), FK → qualiopi_action_types(id) ON DELETE RESTRICT | |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |

*Cohérence métier à valider côté code (pas en contrainte SQL) : cette table ne devrait avoir de lignes que si `organizations.has_qualiopi = true`. Si `has_qualiopi` repasse à `false`, décider si on vide la table ou si on la garde en historique — à trancher plus tard si besoin.*

### `organizations`
Le tenant — l'organisme client qui utilise Axopia.

| Champ | Type | Contraintes | Notes |
|---|---|---|---|
| id | UUID | PK | |
| name | TEXT | NOT NULL | Raison sociale |
| slug | TEXT | UNIQUE, NOT NULL | Pour sous-domaine / URL |
| siret | VARCHAR(14) | NULL | |
| nda_number | VARCHAR(14) | NULL | Numéro de Déclaration d'Activité (ex: `11751234567`) |
| legal_status_id | UUID | NULL, FK → legal_statuses(id) ON DELETE RESTRICT | Micro-entreprise, SAS, SARL... |
| has_qualiopi | BOOLEAN | NOT NULL DEFAULT false | Certifié Qualiopi ou non |
| admin_user_id | UUID | NULL, FK → users(id) ON DELETE RESTRICT | L'administrateur de l'organisation — exactement un, garanti par la colonne unique elle-même. `NULL` toléré en `draft`, doit être renseigné pour passer en `active` (contrainte applicative, pas SQL) |
| has_subcontractors | BOOLEAN | NOT NULL DEFAULT false | L'organisme a-t-il recours à des sous-traitants ? |
| aasm_state | VARCHAR(20) | NOT NULL DEFAULT 'draft' | Géré par le gem AASM — `draft` / `active` / `archived` |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |
| updated_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |
| deleted_at | TIMESTAMPTZ | NULL | soft-delete |

*(Pas de `organization_id` ici — c'est la table racine du tenant.)*

### `organization_subcontractors`
Relation many-to-many auto-référencée : quel organisme sous-traite auprès de quel autre organisme (qui est lui aussi une ligne de `organizations`).

| Champ | Type | Contraintes | Notes |
|---|---|---|---|
| id | UUID | PK | |
| organization_id | UUID | NOT NULL, FK → organizations(id) ON DELETE CASCADE | L'organisme donneur d'ordre |
| subcontractor_id | UUID | NOT NULL, FK → organizations(id) ON DELETE RESTRICT | L'organisme sous-traitant (aussi une `organization`) |
| is_active | BOOLEAN | NOT NULL DEFAULT true | Relation active ou historisée |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |
| updated_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |

*Contrainte unique : `(organization_id, subcontractor_id)` — on évite le doublon. Vérifier aussi côté code que `organization_id ≠ subcontractor_id` (un organisme ne peut pas être son propre sous-traitant).*

*`ON DELETE RESTRICT` sur `subcontractor_id` plutôt que `CASCADE` : on ne veut pas qu'une organisation-sous-traitant supprimée fasse disparaître silencieusement l'historique de la relation — mieux vaut bloquer la suppression ou la gérer en soft-delete.*

**Note sur `aasm_state` (organizations) :**
- `draft` : organisme en cours de création, sans validations métier actives (permet de saisir progressivement une fiche incomplète)
- `active` : organisme opérationnel, toutes les validations s'appliquent
- `archived` : organisme désactivé, conservé pour historique
- Transitions : `draft → active`, `active → archived`, **et retour possible `archived → active`** (réactivation) — pas de sens unique strict
- Colonne simple `VARCHAR`, pas de table de référence ni d'`ENUM` Postgres : AASM gère les transitions et leurs garde-fous côté code Ruby (`aasm do ... end`), la colonne ne fait que stocker l'état courant
- Index à prévoir : `CREATE INDEX ON organizations (aasm_state);` — filtre fréquent ("lister les organismes actifs")

### `users`
Les comptes qui se connectent.

| Champ | Type | Contraintes | Notes |
|---|---|---|---|
| id | UUID | PK | |
| organization_id | UUID | NULL, FK → organizations(id) ON DELETE CASCADE | Organisation **principale** de connexion — `NULL` uniquement pour un `is_super_admin = true` (compte plateforme, pas rattaché à un organisme client). Garanti par contrainte `CHECK` au niveau table (voir note ci-dessous) |
| email | CITEXT | UNIQUE, NOT NULL | `CITEXT` = email insensible à la casse |
| password_hash | TEXT | NOT NULL | |
| first_name | TEXT | NOT NULL | |
| last_name | TEXT | NOT NULL | |
| is_active | BOOLEAN | NOT NULL DEFAULT true | |
| last_login_at | TIMESTAMPTZ | NULL | |
| is_super_admin | BOOLEAN | NOT NULL DEFAULT false | Super-accès global — **volontairement hors profils/permissions**, à ne modifier qu'en console (`rails console`), jamais via un formulaire applicatif |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |
| updated_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |
| deleted_at | TIMESTAMPTZ | NULL | soft-delete |

*Contrainte de table : `CHECK (organization_id IS NOT NULL OR is_super_admin = true)` — un utilisateur normal doit obligatoirement appartenir à un organisme ; seul un super-admin plateforme peut exister sans organisation.*

### Gestion des droits : RBAC dynamique maison (sans Rolify)

**Principe d'architecture (remplace l'approche Rolify+profils envisagée plus tôt — architecture proposée et validée par l'utilisateur) :**

- Système découplé de toute gemme tierce : **User → Role → Permission**, via une table pivot **`assignments`**
- **`users`** : identité unique globale — un même utilisateur peut travailler sur plusieurs organisations (ex: secrétaire indépendante, gérant multi-centres) sans compte dupliqué
- **`roles`** : appartient à **une** organisation précise (`organization_id NOT NULL`). Dynamique et configurable par les gestionnaires de l'organisation — pas de rôle "global" partagé entre organisations (contrairement à ce qu'on avait avec les profils système `organization_id NULL`)
- **`permissions`** : action technique atomique, codée en dur dans l'appli (ex: `courses:update`, `sessions:view_all`). Immuable pour les utilisateurs, ne change qu'en déployant du code
- **`assignments`** : la table pivot centrale — associe **User + Organization + Role** en un seul triplet
- Les policies Pundit interrogent des **permissions techniques**, jamais des noms de rôles métier volatils — un rôle peut être renommé sans casser aucune policy

### `roles`
Rôles configurables, propres à une organisation.

| Champ | Type | Contraintes | Notes |
|---|---|---|---|
| id | UUID | PK | |
| organization_id | UUID | NOT NULL, FK → organizations(id) ON DELETE CASCADE | Un rôle appartient à une seule organisation, pas de rôle global partagé |
| name | TEXT | NOT NULL | ex: "Secrétaire", "Auditeur qualité", "Administrateur" |
| slug | TEXT | NOT NULL | ex: `secretary` |
| is_system | BOOLEAN | NOT NULL DEFAULT false | true = rôle standard créé automatiquement à la création de l'organisation (voir plus bas), non supprimable |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |
| updated_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |

*Contrainte unique : `(organization_id, slug)`*

### `permissions`
Catalogue global des permissions techniques atomiques. Pas de `organization_id` — référentiel commun, codé en dur dans l'appli.

| Champ | Type | Contraintes | Notes |
|---|---|---|---|
| id | UUID | PK | |
| resource | TEXT | NOT NULL | ex: `courses`, `sessions`, `invoices` |
| action | TEXT | NOT NULL | ex: `view`, `update`, `view_all`, `view_assigned` |
| slug | TEXT | UNIQUE, NOT NULL | ex: `courses:update`, `sessions:view_all` — **doit correspondre exactement à la chaîne vérifiée dans `has_permission?`** |
| description | TEXT | NULL | Affiché dans l'UI d'admin lors de la composition d'un rôle (Phase 2) |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |

### `role_permissions`
Composition d'un rôle : quelles permissions il regroupe.

| Champ | Type | Contraintes | Notes |
|---|---|---|---|
| role_id | UUID | PK (composite), FK → roles(id) ON DELETE CASCADE | |
| permission_id | UUID | PK (composite), FK → permissions(id) ON DELETE CASCADE | |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |

### `permission_overrides`
Exceptions individuelles : accorde ou retire une permission précise à un utilisateur donné, sur une organisation donnée — **indépendamment de son rôle**. Le rôle reste une configuration de base partagée (non modifiable par organisation, comme chez Digiforma) ; les cas particuliers passent par cette table plutôt que par une modification de `role_permissions`.

| Champ | Type | Contraintes | Notes |
|---|---|---|---|
| id | UUID | PK | |
| user_id | UUID | NOT NULL, FK → users(id) ON DELETE CASCADE | |
| organization_id | UUID | NOT NULL, FK → organizations(id) ON DELETE CASCADE | |
| permission_id | UUID | NOT NULL, FK → permissions(id) ON DELETE CASCADE | |
| granted | BOOLEAN | NOT NULL | `true` = accordée même si aucun rôle de l'utilisateur ne l'inclut ; `false` = retirée même si un rôle de l'utilisateur l'inclurait normalement |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |
| updated_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |

*Contrainte unique : `(user_id, organization_id, permission_id)` — une seule exception par permission, par utilisateur, par organisation.*

*Priorité de résolution : une exception dans `permission_overrides` l'emporte toujours sur ce que donnerait `role_permissions` — voir la logique complète `has_permission?` sous `assignments` ci-dessous, qui vérifie d'abord les exceptions puis retombe sur les rôles.*

### `assignments`
Table pivot centrale : associe un utilisateur, une organisation et un rôle. C'est elle qui fait autorité pour l'autorisation (contrairement à l'ancien `user_profiles`, purement informatif).

| Champ | Type | Contraintes | Notes |
|---|---|---|---|
| id | UUID | PK | |
| user_id | UUID | NOT NULL, FK → users(id) ON DELETE CASCADE | |
| organization_id | UUID | NOT NULL, FK → organizations(id) ON DELETE CASCADE | |
| role_id | UUID | NOT NULL, FK → roles(id) ON DELETE CASCADE | |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |
| updated_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |

*Contrainte unique : `(user_id, organization_id, role_id)` — pas de doublon exact, mais un utilisateur peut avoir plusieurs rôles différents sur la même organisation, et des rôles sur plusieurs organisations distinctes.*

**Vérification des droits (Active Record, rappel pour Claude Code — version finale incluant les exceptions de `permission_overrides`) :**
```ruby
def has_permission?(permission_slug, organization)
  permission = Permission.find_by(slug: permission_slug)
  override = permission_overrides.find_by(organization: organization, permission: permission)
  return override.granted unless override.nil?

  assignments.joins(role: :permissions)
             .exists?(organization_id: organization.id, permissions: { slug: permission_slug })
end
```

**Intégration Pundit :** les policies vérifient uniquement des permissions techniques (`@user.has_permission?('courses:update', @organization)`), jamais un nom de rôle — le rôle métier peut changer sans toucher aux policies. Le `@organization` courant doit être fourni au contexte Pundit (via un `Pundit::Context` custom ou une méthode `pundit_user` enrichie côté controller) puisque Pundit ne transmet nativement que `user` + `record`.

**Automatisation à la création d'une organisation :** un callback `after_create` sur `Organization` initialise les rôles standards (Administrateur, Secrétaire, Formateur, Apprenant) avec leur pack de permissions par défaut, via `role_permissions`.

**Évolutivité prévue (à noter pour Claude Code, pas de conséquence sur le schéma actuel) :**
- Phase 1 (MVP) : rôles par défaut fixes, masqués côté client
- Phase 2 : interface de configuration des permissions par rôle (cases à cocher) — ajoute/retire des lignes dans `role_permissions`, **aucune modification de policy Pundit nécessaire**

**Note sur `is_super_admin` :**
- Doit donner accès à **tout**, sans exception — usage prévu : investigation en cas de problème, support/dépannage
- Se câble en court-circuitant Pundit à la racine plutôt qu'au cas par cas dans chaque policy : dans `ApplicationPolicy`, faire précéder chaque règle par `return true if user.is_super_admin?` — **ne pas** dupliquer `user.is_super_admin? ||` dans chaque policy individuelle, source d'oubli
- Reste un simple booléen sur `users`, aucune ligne dans `roles`/`permissions`/`assignments` — accès total intentionnellement en dehors du RBAC, pas une permission de plus à catégoriser

**Note sur le rôle "Administrateur" (organisation) et `organizations.admin_user_id` :**
- "Administrateur" est l'un des rôles standards créés automatiquement (`is_system = true`) à la création de chaque organisation, avec un pack de permissions large
- Ne pas confondre avec `is_super_admin` sur `users` : `is_super_admin` est un accès plateforme total (support Axopia), le rôle "Administrateur" est un rôle **métier propre à une organisation**, avec les permissions que `role_permissions` lui associe — rien de plus
- `organizations.admin_user_id` reste la source de vérité pour "qui EST l'**admin principal**" (une seule colonne = une seule valeur garantie) — c'est lui qui peut ajouter/retirer le rôle "Administrateur" à d'autres utilisateurs de son organisation, y compris supprimer un autre admin. **Rien n'empêche `assignments` de contenir plusieurs utilisateurs avec le rôle "Administrateur"** sur la même organisation (des admins "secondaires", gérés par l'admin principal) — les deux ne se contredisent pas : `admin_user_id` porte le pouvoir de gestion des accès, `assignments` liste tous ceux qui ont les permissions effectives du rôle. Règle applicative à respecter : quand `admin_user_id` est défini/changé, s'assurer qu'une ligne `assignments` correspondante existe bien pour ce triplet (user, organization, rôle "Administrateur")
- Un même utilisateur peut être `admin_user_id` de plusieurs organisations, et/ou avoir des `assignments` sur des organisations différentes de son `users.organization_id` "principal" — cohérent avec le cas du gérant multi-centres

---

## Entités métier

### `certifications`
Référentiel des certifications RNCP/RS (France Compétences) — alimenté par import périodique (cf. discussion sur les sources open data RNCP/RS), pas de `organization_id`, référentiel technique commun.

| Champ | Type | Contraintes | Notes |
|---|---|---|---|
| id | UUID | PK | |
| code | TEXT | UNIQUE, NOT NULL | Code RNCP ou RS (ex: `RNCP12345`, `RS6789`) |
| registry_type | TEXT | NOT NULL | `rncp` ou `rs` — table de référence à part si ça se complexifie, simple `TEXT` suffisant pour l'instant |
| label | TEXT | NOT NULL | Intitulé officiel de la certification |
| level | TEXT | NULL | Niveau (ex: "Niveau 5", "Bac+3"...) — format à confirmer selon la structure exacte des données France Compétences |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |
| updated_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | Mis à jour par le job d'import périodique |

*Table alimentée par synchronisation automatique (job cron), pas par saisie manuelle en temps normal.*

### `trainings`
Une formation proposée par un organisme.

| Champ | Type | Contraintes | Notes |
|---|---|---|---|
| id | UUID | PK | |
| organization_id | UUID | NOT NULL, FK → organizations(id) ON DELETE CASCADE | |
| qualiopi_action_type_id | UUID | NOT NULL, FK → qualiopi_action_types(id) ON DELETE RESTRICT | Une formation relève d'**une seule** catégorie (formation / bilan / VAE / apprentissage) — relation simple, pas many-to-many comme au niveau organisme |
| certification_id | UUID | NULL, FK → certifications(id) ON DELETE RESTRICT | `NULL` = formation libre, sans code RNCP/RS |
| title | TEXT | NOT NULL | Intitulé de la formation — copié depuis `certifications.label` si une certification est sélectionnée, saisi librement sinon |
| code | TEXT | NOT NULL | Code de formation, propre à l'organisme |
| diploma_code | TEXT | NULL | Code diplôme — pertinent uniquement si `qualiopi_action_type` = `apprenticeship` (CFA) |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |
| updated_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |
| deleted_at | TIMESTAMPTZ | NULL | soft-delete |

*Contrainte unique : `(organization_id, code)` — le code de formation est unique chez un organisme, pas forcément unique entre organismes différents.*

*Note sur `title` : `title` reste un champ **propre** à `trainings` (pas juste une lecture de `certifications.label`), pour deux raisons — (1) permettre les formations libres sans certification, (2) figer l'intitulé au moment de la création même si le libellé officiel de la certification est renommé plus tard côté France Compétences. Règle applicative : à la sélection d'une certification dans le formulaire, pré-remplir `title` avec `certifications.label` (mais rester modifiable).*

### `training_modalities`
Table de référence des modalités de formation (conforme à la convention "lookup table plutôt qu'ENUM natif" — vous l'avez signalé vous-même comme amenée à évoluer). Référentiel technique commun, pas de `organization_id`.

| Champ | Type | Contraintes | Notes |
|---|---|---|---|
| id | UUID | PK | |
| code | TEXT | UNIQUE, NOT NULL | `in_person`, `remote`, `blended` |
| label | TEXT | NOT NULL | "Présentiel", "Visio", "Mixte" |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |

**Seed à donner à Claude Code :**

```sql
INSERT INTO training_modalities (code, label) VALUES
  ('in_person', 'Présentiel'),
  ('remote', 'Visio'),
  ('blended', 'Mixte');
```

### `learners`
Fiche apprenant, rattachée à une formation précise de l'organisme.

| Champ | Type | Contraintes | Notes |
|---|---|---|---|
| id | UUID | PK | |
| organization_id | UUID | NOT NULL, FK → organizations(id) ON DELETE CASCADE | |
| training_id | UUID | NOT NULL, FK → trainings(id) ON DELETE RESTRICT | Doit appartenir au même `organization_id` — validation applicative, pas contrainte SQL native |
| training_modality_id | UUID | NOT NULL, FK → training_modalities(id) ON DELETE RESTRICT | |
| file_number | TEXT | NOT NULL | Numéro de dossier |
| first_name | TEXT | NOT NULL | |
| last_name | TEXT | NOT NULL | |
| start_date | DATE | NOT NULL | Date d'entrée en formation |
| end_date | DATE | NULL, CHECK (end_date IS NULL OR end_date >= start_date) | Date de sortie de formation — `NULL` tant que l'apprenant est encore en cours |
| is_subcontracted | BOOLEAN | NOT NULL DEFAULT false | L'apprenant est-il suivi via un sous-traitant de l'organisme ? |
| subcontractor_organization_id | UUID | NULL, FK → organizations(id) ON DELETE RESTRICT | Le sous-traitant sélectionné — doit obligatoirement faire partie des sous-traitants déclarés de l'organisme (voir validation ci-dessous) |
| comment | TEXT | NULL | Commentaire libre |
| prerequisites_analysis_done | BOOLEAN | NOT NULL DEFAULT false | Analyse des prérequis |
| needs_analysis_done | BOOLEAN | NOT NULL DEFAULT false | Analyse des besoins |
| agreement_sent | BOOLEAN | NOT NULL DEFAULT false | Convention envoyée |
| in_person_agreement_done | BOOLEAN | NOT NULL DEFAULT false | Convention présentiel |
| initial_assessment_done | BOOLEAN | NOT NULL DEFAULT false | Éval. de début |
| self_assessment_in_person_done | BOOLEAN | NOT NULL DEFAULT false | Auto-évaluation / éval. présentiel |
| hot_survey_received | BOOLEAN | NOT NULL DEFAULT false | Questionnaire à chaud reçu |
| attendance_sheet_done | BOOLEAN | NOT NULL DEFAULT false | Émargement |
| trainer_evaluation_done | BOOLEAN | NOT NULL DEFAULT false | Évaluation formatrice |
| completion_certificate_done | BOOLEAN | NOT NULL DEFAULT false | Certificat de réalisation |
| cold_survey_received | BOOLEAN | NOT NULL DEFAULT false | Questionnaire à froid |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |
| updated_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |
| deleted_at | TIMESTAMPTZ | NULL | soft-delete |

*Contexte phase 1 (précisé par l'utilisateur) : Axopia n'est pas la source de vérité pour ces données à ce stade — un outil comme Digiforma reste le système de référence. Axopia sert d'outil de **suivi**, d'où des booléens plats sans traçabilité fine (date/auteur) : suffisant pour ce niveau d'exigence, pas besoin d'une table d'audit dédiée pour l'instant. À revoir si le périmètre évolue vers une phase où Axopia devient source de vérité.*

*Contrainte unique : `(organization_id, file_number)` — le numéro de dossier est unique chez un organisme. `file_number` est saisi manuellement par l'utilisateur, pas généré automatiquement — l'unicité protège contre un doublon de saisie, l'appli devra afficher une erreur claire si le numéro existe déjà pour cet organisme.*

*Validation applicative à prévoir : `training_id` doit référencer une formation dont le `organization_id` correspond à celui de la fiche apprenant — pas de formation d'un autre organisme sélectionnable.*

*Validation applicative à prévoir : `subcontractor_organization_id` ne devrait être renseignable que si `is_subcontracted = true`, et doit obligatoirement correspondre à une ligne existante dans `organization_subcontractors` où `organization_id` = l'organisme de la fiche apprenant et `subcontractor_id` = la valeur choisie — la liste déroulante dans l'UI doit se limiter aux sous-traitants déjà déclarés pour cet organisme (`organizations.has_subcontractors = true` + lignes dans `organization_subcontractors`), pas à toutes les organisations de la base.*

### `funding_types`
Table de référence des types de financement d'une formation. Référentiel technique commun, pas de `organization_id`.

| Champ | Type | Contraintes | Notes |
|---|---|---|---|
| id | UUID | PK | |
| code | TEXT | UNIQUE, NOT NULL | `opco`, `cpf`, `pole_emploi`, `company`, `region`, `self_funded`, `other` |
| label | TEXT | NOT NULL | "OPCO", "CPF", "France Travail (ex-Pôle Emploi)", "Entreprise (plan de développement des compétences)", "Région", "Financement personnel", "Autre" |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |

**Seed à donner à Claude Code (liste indicative des financements courants — à ajuster/compléter selon vos besoins) :**

```sql
INSERT INTO funding_types (code, label) VALUES
  ('opco', 'OPCO'),
  ('cpf', 'CPF'),
  ('pole_emploi', 'France Travail (ex-Pôle Emploi)'),
  ('company', 'Entreprise (plan de développement des compétences)'),
  ('region', 'Région'),
  ('self_funded', 'Financement personnel'),
  ('other', 'Autre');
```

### `opcos`
Table de référence des 11 Opérateurs de Compétences agréés — liste fermée et stable, pas de synchronisation externe nécessaire (contrairement à Qualiopi/RNCP). Référentiel technique commun, pas de `organization_id`.

| Champ | Type | Contraintes | Notes |
|---|---|---|---|
| id | UUID | PK | |
| code | TEXT | UNIQUE, NOT NULL | ex: `afdas`, `akto` |
| name | TEXT | NOT NULL | ex: "AFDAS", "AKTO" |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |

**Seed à donner à Claude Code :**

```sql
INSERT INTO opcos (code, name) VALUES
  ('afdas', 'AFDAS'),
  ('akto', 'AKTO'),
  ('atlas', 'Atlas'),
  ('constructys', 'Constructys'),
  ('opcommerce', 'L''Opcommerce'),
  ('ocapiat', 'OCAPIAT'),
  ('opco_2i', 'OPCO 2i'),
  ('opco_ep', 'OPCO EP'),
  ('opco_mobilites', 'OPCO Mobilités'),
  ('opco_sante', 'OPCO Santé'),
  ('uniformation', 'Uniformation');
```

### `learner_fundings`
Relation many-to-many : une fiche apprenant peut cumuler plusieurs financements (ex: OPCO + reste à charge personnel).

| Champ | Type | Contraintes | Notes |
|---|---|---|---|
| learner_id | UUID | PK (composite), FK → learners(id) ON DELETE CASCADE | |
| funding_type_id | UUID | PK (composite), FK → funding_types(id) ON DELETE RESTRICT | |
| opco_id | UUID | NULL, FK → opcos(id) ON DELETE RESTRICT | Renseigné uniquement quand `funding_type_id` correspond au code `opco` — ouvre le menu de sélection de l'OPCO précis dans l'UI |
| created_at | TIMESTAMPTZ | NOT NULL DEFAULT now() | |

*Validation applicative à prévoir : `opco_id` doit être `NULL` si `funding_type_id` ≠ `opco`, et **requis** (`NOT NULL` en pratique) si `funding_type_id` = `opco` — pas une contrainte SQL simple (nécessite de vérifier le `code` d'une autre table), à gérer côté modèle Rails.*

*Pas de montant par financement pour l'instant (non demandé) — si besoin plus tard de tracer "70% OPCO / 30% personnel", il faudra remplacer la clé composite par un `id` de substitution et ajouter une colonne `amount` ou `percentage`. Facile à faire évoluer si le besoin apparaît, pas de raison de l'anticiper maintenant.*

*(À compléter — section en attente de vos apports)*

### ⏳ À prévoir plus tard : documents d'organisation

Signalé par l'utilisateur, pas encore modélisé — module à construire quand on l'abordera :
- Certificat Qualiopi
- Attestation de vigilance URSSAF
- Attestation RC Pro (responsabilité civile professionnelle)

Probablement une table générique `organization_documents` (type de document, fichier, date d'émission, date d'expiration, statut de validité) plutôt que 3 tables séparées — à confirmer selon si ces documents ont des cycles de vie très différents (dates de renouvellement, alertes d'expiration...).

*(À compléter — section en attente de vos apports)*

---

## Index à prévoir (rappel pour Claude Code)

- Index sur toute colonne `organization_id` (filtre systématique multi-tenant)
- Index sur les colonnes `deleted_at` si soft-delete (requêtes `WHERE deleted_at IS NULL` fréquentes)
- Index unique composite `(organization_id, slug)` ou équivalent partout où l'unicité n'est pas globale mais par tenant
