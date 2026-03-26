# 💼 Analyse des Offres d'Emploi LinkedIn avec Snowflake

<p align="center">
  <img src="https://img.shields.io/badge/Snowflake-Data%20Warehouse-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white" alt="Snowflake" />
  <img src="https://img.shields.io/badge/SQL-Analytics-336791?style=for-the-badge&logo=postgresql&logoColor=white" alt="SQL" />
  <img src="https://img.shields.io/badge/Streamlit-Dashboard-FF4B4B?style=for-the-badge&logo=streamlit&logoColor=white" alt="Streamlit" />
  <img src="https://img.shields.io/badge/Python-3.11-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python" />
  <img src="https://img.shields.io/badge/Projet-MBAESG-6A1B9A?style=for-the-badge" alt="MBAESG" />
  <img src="https://img.shields.io/badge/Status-Terminé-success?style=for-the-badge" alt="Status" />
</p>

<p align="center">
  Projet académique de Data Engineering / Analytics réalisé avec <strong>Snowflake</strong>, <strong>SQL</strong> et <strong>Streamlit</strong> à partir d'un dataset LinkedIn hébergé sur AWS S3.
</p>

---

## 📌 Présentation

Ce projet a pour objectif d'explorer et d'analyser plusieurs milliers d'offres d'emploi LinkedIn afin de mettre en évidence les grandes tendances du marché de l'emploi.

L'ensemble du pipeline est construit dans **Snowflake** :
- ingestion de fichiers **CSV** et **JSON** depuis un **bucket S3 public** ;
- structuration des données dans des tables relationnelles ;
- réalisation de **requêtes analytiques SQL** ;
- création d'un **dashboard Streamlit** pour visualiser les résultats.

---

## 🎯 Objectifs pédagogiques

Ce projet permet de démontrer les compétences suivantes :

- créer une base de données et un environnement de travail dans Snowflake ;
- charger des données externes depuis AWS S3 via un stage ;
- définir des formats de fichiers adaptés aux données CSV et JSON ;
- transformer des données semi-structurées (`VARIANT`) en tables exploitables ;
- réaliser des analyses métier avancées en SQL ;
- produire une visualisation interactive avec Streamlit dans Snowflake.

---

## 🧰 Stack technique

| Technologie | Rôle |
|------------|------|
| **Snowflake** | Entrepôt de données cloud |
| **SQL** | Création, chargement, transformation, analyse |
| **AWS S3** | Source des fichiers de données |
| **JSON / CSV** | Formats des datasets |
| **Python** | Support applicatif pour Streamlit |
| **Streamlit** | Dashboard interactif |
| **Altair** | Visualisations dans l'application |

---

## 📂 Source des données

Les fichiers sont accessibles depuis le bucket public suivant :

```bash
s3://snowflake-lab-bucket/
```

### Fichiers exploités

| Fichier | Format | Description |
|--------|--------|-------------|
| `job_postings.csv` | CSV | Détails des offres d'emploi |
| `benefits.csv` | CSV | Avantages associés aux offres |
| `employee_counts.csv` | CSV | Nombre d'employés et followers par entreprise |
| `job_skills.csv` | CSV | Compétences liées aux postes |
| `companies.json` | JSON | Informations détaillées sur les entreprises |
| `job_industries.json` | JSON | Secteurs associés aux offres |
| `company_specialities.json` | JSON | Spécialités des entreprises |
| `company_industries.json` | JSON | Secteurs d'activité des entreprises |

---

## 🧱 Architecture du projet

```text
S3 Bucket (LinkedIn datasets)
        ↓
External Stage Snowflake
        ↓
Chargement CSV / JSON
        ↓
Tables RAW (VARIANT pour JSON)
        ↓
Transformations SQL
        ↓
Tables analytiques
        ↓
Requêtes métier
        ↓
Dashboard Streamlit
```

---

## 📁 Structure du dépôt

```bash
MBAESG_EVALUATION_ARCHITECTURE_BIGDATA/
│
├── README.md
├── sql/
│   ├── 01_setup_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_load_data.sql
│   ├── 04_transformations.sql
│   └── 05_analyses.sql
│
├── streamlit/
│   └── streamlit_app.py
│
├── screenshots/
│   ├── analyse_1_top_titres.png
│   ├── analyse_2_salaires.png
│   ├── analyse_3_taille_entreprise.png
│   ├── analyse_4_secteurs.png
│   └── analyse_5_types_emploi.png
│
└── Linkedin_Snowflake_Projet_Commente.ipynb
```

---

## 🚀 Mise en place du projet

### 1) Prérequis

Avant de commencer, il faut disposer de :

- un compte **Snowflake** actif ;
- un accès à **Worksheets** ;
- les droits nécessaires pour créer base, schéma, stage et tables ;
- un environnement Snowflake supportant **Streamlit in Snowflake**.

---

### 2) Créer la base de données et le stage

Exécuter le script suivant dans Snowflake :

```sql
sql/01_setup_database.sql
```

Ce script permet de :
- créer la base `linkedin` ;
- créer le schéma `raw_data` ;
- créer le stage externe vers le bucket S3 ;
- définir les formats de fichiers `csv_format` et `json_format`.

---

### 3) Créer les tables

Exécuter ensuite :

```sql
sql/02_create_tables.sql
```

Ce script crée :
- les tables relationnelles pour les fichiers CSV ;
- les tables `RAW` de type `VARIANT` pour les fichiers JSON ;
- les tables finales destinées aux données transformées.

---

### 4) Charger les données

Exécuter :

```sql
sql/03_load_data.sql
```

Le chargement s'effectue avec `COPY INTO` depuis le stage S3.

---

### 5) Transformer les données JSON

Exécuter :

```sql
sql/04_transformations.sql
```

Cette étape extrait les champs JSON vers des colonnes SQL classiques en utilisant la syntaxe Snowflake :

```sql
raw_data:nom_du_champ::TYPE
```

---

### 6) Lancer les analyses

Exécuter :

```sql
sql/05_analyses.sql
```

Ce fichier contient les 5 analyses demandées dans le sujet.

---

## 📊 Analyses réalisées

### 1. Top 10 des titres de postes les plus publiés par industrie
Permet d'identifier les métiers les plus demandés dans chaque secteur.

### 2. Top 10 des postes les mieux rémunérés par industrie
Basé sur le salaire médian moyen (`med_salary`).

### 3. Répartition des offres par taille d'entreprise
Mesure quelles tailles d'entreprises recrutent le plus.

### 4. Répartition des offres par secteur d'activité
Permet d'observer les secteurs les plus dynamiques.

### 5. Répartition des offres par type d'emploi
Analyse la structure des contrats : temps plein, temps partiel, stage, contrat, etc.

---

## 📈 Déploiement de l'application Streamlit

Le fichier suivant contient l'application complète :

```bash
streamlit/streamlit_app.py
```

### Déploiement dans Snowflake

1. Aller dans **Projects** ;
2. Cliquer sur **Streamlit** ;
3. Créer une nouvelle application ;
4. Coller le contenu de `streamlit_app.py` ;
5. Sélectionner la base `linkedin` et le schéma `raw_data` ;
6. Exécuter l'application.

### Fonctionnalités du dashboard

- affichage des KPI globaux ;
- 5 onglets correspondant aux 5 analyses ;
- graphiques interactifs ;
- tableaux de détail ;
- filtres par industrie sur certaines visualisations.

---

## 🖼️ Aperçu attendu des visualisations

Tu peux ajouter dans cette section les captures d'écran une fois le dashboard exécuté.

```markdown
![Analyse 1](screenshots/analyse_1_top_titres.png)
![Analyse 2](screenshots/analyse_2_salaires.png)
![Analyse 3](screenshots/analyse_3_taille_entreprise.png)
![Analyse 4](screenshots/analyse_4_secteurs.png)
![Analyse 5](screenshots/analyse_5_types_emploi.png)
```

> Pense à remplacer cette section par les vraies captures pour rendre le dépôt plus professionnel.

---

## ✅ Ordre recommandé d'exécution

```bash
1. sql/01_setup_database.sql
2. sql/02_create_tables.sql
3. sql/03_load_data.sql
4. sql/04_transformations.sql
5. sql/05_analyses.sql
6. streamlit/streamlit_app.py
```

---

## ⚠️ Difficultés possibles et solutions

| Problème | Cause probable | Solution |
|---------|----------------|----------|
| Le JSON ne se charge pas correctement | tableau JSON racine | utiliser `STRIP_OUTER_ARRAY = TRUE` |
| Certaines jointures ne retournent rien | écart entre `company_name` et `name` | normaliser avec `TRIM(LOWER(...))` |
| Le chargement CSV échoue sur certaines lignes | caractères spéciaux / formats incohérents | utiliser `ON_ERROR = 'CONTINUE'` |
| Beaucoup de salaires sont null | données source incomplètes | filtrer avec `WHERE med_salary IS NOT NULL` |
| Streamlit ne fonctionne pas en local | code prévu pour Snowflake | exécuter dans Streamlit in Snowflake |

---

## 👥 Répartition du travail

| Membre | Responsabilités |
|--------|------------------|
| **[Nom Prénom 1]** | Setup Snowflake, stage, création des tables, chargement |
| **[Nom Prénom 2]** | Transformations, analyses SQL, dashboard Streamlit |

> Remplace ces champs avant la soumission finale.

---

## 📚 Livrables attendus

Le rendu doit inclure :

- les scripts SQL commentés ;
- le code Streamlit ;
- les résultats obtenus ;
- les captures d'écran ;
- les explications de chaque étape ;
- les difficultés rencontrées et les solutions apportées.

---

## 📬 Soumission

- **Objet du mail :** `MBAESG_EVALUATION_ARCHITECTURE_BIGDATA`
- **Destinataire :** `axel@logbrain.fr`

---

## 📝 Personnalisation GitHub recommandée

Avant de publier le dépôt, pense à :

- remplacer les noms des membres ;
- ajouter les captures d'écran du dashboard ;
- ajouter éventuellement le lien vers ton notebook commenté ;
- mettre le dépôt en public si demandé ;
- compléter la section résultats avec une courte interprétation métier.

---

## 🙌 Auteur / Équipe

Projet réalisé dans le cadre du **MBA Big Data & Intelligence Artificielle — MBAESG**.

---

<p align="center">
  <strong>Hawa, si tu veux, je peux maintenant te générer aussi une version encore plus premium :</strong><br>
  avec table des matières cliquable, section résultats, badges personnalisés à ton nom, et emplacements de screenshots déjà intégrés.
</p>
