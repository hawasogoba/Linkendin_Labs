-- ============================================================
-- SCRIPT 03 : CHARGEMENT DES DONNÉES (COPY INTO)
-- Projet : Analyse des Offres d'Emploi LinkedIn avec Snowflake
-- ============================================================
-- Ce script importe les données depuis le bucket S3 vers Snowflake.
-- ON_ERROR = 'CONTINUE' : ignore les lignes mal formées sans bloquer.
-- ============================================================

USE DATABASE linkedin;
USE SCHEMA raw_data;

-- ============================================================
-- CHARGEMENT DES FICHIERS CSV
-- ============================================================

-- 1. Chargement de job_postings.csv
-- Fichier principal : toutes les offres d'emploi LinkedIn
COPY INTO job_postings
FROM @linkedin_stage/job_postings.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_format')
ON_ERROR    = 'CONTINUE';

-- Vérification rapide
SELECT COUNT(*) AS nb_offres_chargees FROM job_postings;

-- -------------------------------------------------------

-- 2. Chargement de benefits.csv
-- Avantages par offre d'emploi
COPY INTO benefits
FROM @linkedin_stage/benefits.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_format')
ON_ERROR    = 'CONTINUE';

SELECT COUNT(*) AS nb_avantages_charges FROM benefits;

-- -------------------------------------------------------

-- 3. Chargement de employee_counts.csv
-- Nombre d'employés et de followers par entreprise
COPY INTO employee_counts
FROM @linkedin_stage/employee_counts.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_format')
ON_ERROR    = 'CONTINUE';

SELECT COUNT(*) AS nb_entreprises_rh FROM employee_counts;

-- -------------------------------------------------------

-- 4. Chargement de job_skills.csv
-- Compétences requises par offre d'emploi
COPY INTO job_skills
FROM @linkedin_stage/job_skills.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_format')
ON_ERROR    = 'CONTINUE';

SELECT COUNT(*) AS nb_competences_chargees FROM job_skills;

-- ============================================================
-- CHARGEMENT DES FICHIERS JSON (dans les tables RAW/VARIANT)
-- Les fichiers JSON sont chargés dans des tables intermédiaires
-- puis transformés en tables relationnelles dans le script 04.
-- ============================================================

-- 5. Chargement de companies.json
-- Informations détaillées sur chaque entreprise
COPY INTO companies_raw
FROM @linkedin_stage/companies.json
FILE_FORMAT = (FORMAT_NAME = 'json_format')
ON_ERROR    = 'CONTINUE';

SELECT COUNT(*) AS nb_entreprises_raw FROM companies_raw;

-- -------------------------------------------------------

-- 6. Chargement de job_industries.json
-- Secteurs d'activité par offre d'emploi
COPY INTO job_industries_raw
FROM @linkedin_stage/job_industries.json
FILE_FORMAT = (FORMAT_NAME = 'json_format')
ON_ERROR    = 'CONTINUE';

SELECT COUNT(*) AS nb_job_industries_raw FROM job_industries_raw;

-- -------------------------------------------------------

-- 7. Chargement de company_specialities.json
-- Spécialités par entreprise
COPY INTO company_specialities_raw
FROM @linkedin_stage/company_specialities.json
FILE_FORMAT = (FORMAT_NAME = 'json_format')
ON_ERROR    = 'CONTINUE';

SELECT COUNT(*) AS nb_specialites_raw FROM company_specialities_raw;

-- -------------------------------------------------------

-- 8. Chargement de company_industries.json
-- Secteurs d'activité par entreprise
COPY INTO company_industries_raw
FROM @linkedin_stage/company_industries.json
FILE_FORMAT = (FORMAT_NAME = 'json_format')
ON_ERROR    = 'CONTINUE';

SELECT COUNT(*) AS nb_industries_raw FROM company_industries_raw;

-- ============================================================
-- VÉRIFICATION GLOBALE DU CHARGEMENT
-- Affiche le nombre de lignes chargées pour chaque table brute
-- ============================================================
SELECT 'job_postings'            AS table_name, COUNT(*) AS nb_lignes FROM job_postings
UNION ALL
SELECT 'benefits',                COUNT(*) FROM benefits
UNION ALL
SELECT 'employee_counts',         COUNT(*) FROM employee_counts
UNION ALL
SELECT 'job_skills',              COUNT(*) FROM job_skills
UNION ALL
SELECT 'companies_raw',           COUNT(*) FROM companies_raw
UNION ALL
SELECT 'job_industries_raw',      COUNT(*) FROM job_industries_raw
UNION ALL
SELECT 'company_specialities_raw',COUNT(*) FROM company_specialities_raw
UNION ALL
SELECT 'company_industries_raw',  COUNT(*) FROM company_industries_raw
ORDER BY table_name;
