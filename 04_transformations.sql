-- ============================================================
-- SCRIPT 04 : TRANSFORMATIONS JSON → TABLES RELATIONNELLES
-- Projet : Analyse des Offres d'Emploi LinkedIn avec Snowflake
-- ============================================================
-- Ce script extrait les champs des colonnes VARIANT (JSON brut)
-- et les insère dans les tables relationnelles structurées.
-- Syntaxe Snowflake : raw_data:nom_du_champ::TYPE_DE_DONNÉE
-- ============================================================

USE DATABASE linkedin;
USE SCHEMA raw_data;

-- ============================================================
-- TRANSFORMATION 1 : companies_raw → companies
-- ============================================================
-- On extrait chaque champ JSON et on le convertit au bon type SQL
INSERT INTO companies
SELECT
    raw_data:company_id::VARCHAR(50)   AS company_id,
    raw_data:name::VARCHAR(255)        AS name,
    raw_data:description::TEXT         AS description,
    raw_data:company_size::INTEGER     AS company_size,
    raw_data:state::VARCHAR(100)       AS state,
    raw_data:country::VARCHAR(100)     AS country,
    raw_data:city::VARCHAR(100)        AS city,
    raw_data:zip_code::VARCHAR(20)     AS zip_code,
    raw_data:address::VARCHAR(500)     AS address,
    raw_data:url::VARCHAR(500)         AS url
FROM companies_raw;

-- Vérification
SELECT COUNT(*) AS nb_companies FROM companies;
SELECT * FROM companies LIMIT 5;

-- ============================================================
-- TRANSFORMATION 2 : job_industries_raw → job_industries
-- ============================================================
INSERT INTO job_industries
SELECT
    raw_data:job_id::VARCHAR(50)       AS job_id,
    raw_data:industry_id::VARCHAR(50)  AS industry_id
FROM job_industries_raw;

-- Vérification
SELECT COUNT(*) AS nb_job_industries FROM job_industries;
SELECT * FROM job_industries LIMIT 5;

-- ============================================================
-- TRANSFORMATION 3 : company_specialities_raw → company_specialities
-- ============================================================
INSERT INTO company_specialities
SELECT
    raw_data:company_id::VARCHAR(50)   AS company_id,
    raw_data:speciality::VARCHAR(255)  AS speciality
FROM company_specialities_raw;

-- Vérification
SELECT COUNT(*) AS nb_specialities FROM company_specialities;
SELECT * FROM company_specialities LIMIT 5;

-- ============================================================
-- TRANSFORMATION 4 : company_industries_raw → company_industries
-- ============================================================
INSERT INTO company_industries
SELECT
    raw_data:company_id::VARCHAR(50)   AS company_id,
    raw_data:industry::VARCHAR(255)    AS industry
FROM company_industries_raw;

-- Vérification
SELECT COUNT(*) AS nb_company_industries FROM company_industries;
SELECT * FROM company_industries LIMIT 5;

-- ============================================================
-- VÉRIFICATION GLOBALE FINALE
-- Toutes les tables doivent avoir des données non nulles
-- ============================================================
SELECT 'job_postings'          AS table_name, COUNT(*) AS nb_lignes FROM job_postings
UNION ALL
SELECT 'benefits',              COUNT(*) FROM benefits
UNION ALL
SELECT 'employee_counts',       COUNT(*) FROM employee_counts
UNION ALL
SELECT 'job_skills',            COUNT(*) FROM job_skills
UNION ALL
SELECT 'companies',             COUNT(*) FROM companies
UNION ALL
SELECT 'job_industries',        COUNT(*) FROM job_industries
UNION ALL
SELECT 'company_specialities',  COUNT(*) FROM company_specialities
UNION ALL
SELECT 'company_industries',    COUNT(*) FROM company_industries
ORDER BY nb_lignes DESC;

-- ============================================================
-- CONTRÔLE QUALITÉ DES DONNÉES
-- ============================================================

-- Vérifie les valeurs NULL dans les colonnes clés de job_postings
SELECT
    COUNT(*)                                      AS total_offres,
    COUNT(job_id)                                 AS avec_job_id,
    COUNT(title)                                  AS avec_titre,
    COUNT(company_name)                           AS avec_entreprise,
    COUNT(med_salary)                             AS avec_salaire_median,
    COUNT(formatted_work_type)                    AS avec_type_emploi,
    ROUND(COUNT(med_salary) * 100.0 / COUNT(*), 1) AS pct_offres_avec_salaire
FROM job_postings;

-- Vérifie les types d'emploi distincts
SELECT formatted_work_type, COUNT(*) AS nb
FROM job_postings
GROUP BY formatted_work_type
ORDER BY nb DESC;

-- Vérifie la distribution des tailles d'entreprise
SELECT company_size, COUNT(*) AS nb_entreprises
FROM companies
GROUP BY company_size
ORDER BY company_size;
