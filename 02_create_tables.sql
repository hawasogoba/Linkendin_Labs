-- ============================================================
-- SCRIPT 02 : CRÉATION DES TABLES
-- Projet : Analyse des Offres d'Emploi LinkedIn avec Snowflake
-- ============================================================

USE DATABASE linkedin;
USE SCHEMA raw_data;

-- ============================================================
-- TABLE 1 : job_postings (source : job_postings.csv)
-- Table principale contenant toutes les offres d'emploi
-- ============================================================
CREATE OR REPLACE TABLE job_postings (
    job_id                     VARCHAR(50)    COMMENT 'Identifiant unique LinkedIn de l offre',
    company_name               VARCHAR(255)   COMMENT 'Nom de l entreprise',
    title                      VARCHAR(255)   COMMENT 'Titre du poste',
    description                TEXT           COMMENT 'Description complète du poste',
    max_salary                 FLOAT          COMMENT 'Salaire maximum proposé',
    med_salary                 FLOAT          COMMENT 'Salaire médian proposé',
    min_salary                 FLOAT          COMMENT 'Salaire minimum proposé',
    pay_period                 VARCHAR(50)    COMMENT 'Périodicité du salaire (HOURLY, MONTHLY, YEARLY)',
    formatted_work_type        VARCHAR(100)   COMMENT 'Type de travail formaté (Full-time, Part-time, Contract...)',
    location                   VARCHAR(255)   COMMENT 'Localisation du poste',
    applies                    INTEGER        COMMENT 'Nombre de candidatures reçues',
    original_listed_time       BIGINT         COMMENT 'Timestamp Unix de la publication initiale',
    remote_allowed             BOOLEAN        COMMENT 'TRUE si le télétravail est autorisé',
    views                      INTEGER        COMMENT 'Nombre de vues de l offre',
    job_posting_url            VARCHAR(500)   COMMENT 'URL de l offre sur LinkedIn',
    application_url            VARCHAR(500)   COMMENT 'URL pour postuler',
    application_type           VARCHAR(100)   COMMENT 'Type de candidature (offsite, onsite simple/complexe)',
    expiry                     BIGINT         COMMENT 'Timestamp Unix d expiration de l offre',
    closed_time                BIGINT         COMMENT 'Timestamp Unix de fermeture',
    formatted_experience_level VARCHAR(100)   COMMENT 'Niveau d expérience (Entry, Associate, Mid-Senior...)',
    skills_desc                TEXT           COMMENT 'Description des compétences requises',
    listed_time                BIGINT         COMMENT 'Timestamp Unix de la mise en ligne',
    posting_domain             VARCHAR(255)   COMMENT 'Domaine du site de candidature',
    sponsored                  BOOLEAN        COMMENT 'TRUE si l offre est sponsorisée',
    work_type                  VARCHAR(100)   COMMENT 'Type de travail brut',
    currency                   VARCHAR(10)    COMMENT 'Devise du salaire (USD, EUR...)',
    compensation_type          VARCHAR(100)   COMMENT 'Type de rémunération'
);

-- ============================================================
-- TABLE 2 : benefits (source : benefits.csv)
-- Avantages liés à chaque offre d'emploi
-- ============================================================
CREATE OR REPLACE TABLE benefits (
    job_id    VARCHAR(50)  COMMENT 'Référence à job_postings.job_id',
    inferred  BOOLEAN      COMMENT 'TRUE si l avantage a été inféré par LinkedIn (non déclaré)',
    type      VARCHAR(100) COMMENT 'Type d avantage (401K, Medical Insurance, Dental...)'
);

-- ============================================================
-- TABLE 3 : employee_counts (source : employee_counts.csv)
-- Statistiques RH des entreprises
-- ============================================================
CREATE OR REPLACE TABLE employee_counts (
    company_id      VARCHAR(50) COMMENT 'Identifiant de l entreprise',
    employee_count  INTEGER     COMMENT 'Nombre d employés',
    follower_count  INTEGER     COMMENT 'Nombre de followers LinkedIn',
    time_recorded   BIGINT      COMMENT 'Timestamp Unix de la collecte des données'
);

-- ============================================================
-- TABLE 4 : job_skills (source : job_skills.csv)
-- Compétences associées aux offres d'emploi
-- ============================================================
CREATE OR REPLACE TABLE job_skills (
    job_id     VARCHAR(50) COMMENT 'Référence à job_postings.job_id',
    skill_abr  VARCHAR(50) COMMENT 'Abréviation de la compétence requise'
);

-- ============================================================
-- TABLES INTERMÉDIAIRES (VARIANT) POUR LES FICHIERS JSON
-- Les fichiers JSON sont d'abord chargés sous forme brute (VARIANT),
-- puis transformés en tables relationnelles (Étape 4).
-- ============================================================

-- Table brute pour companies.json
CREATE OR REPLACE TABLE companies_raw (
    raw_data VARIANT COMMENT 'Données brutes JSON pour companies'
);

-- Table brute pour job_industries.json
CREATE OR REPLACE TABLE job_industries_raw (
    raw_data VARIANT COMMENT 'Données brutes JSON pour job_industries'
);

-- Table brute pour company_specialities.json
CREATE OR REPLACE TABLE company_specialities_raw (
    raw_data VARIANT COMMENT 'Données brutes JSON pour company_specialities'
);

-- Table brute pour company_industries.json
CREATE OR REPLACE TABLE company_industries_raw (
    raw_data VARIANT COMMENT 'Données brutes JSON pour company_industries'
);

-- ============================================================
-- TABLES FINALES POUR LES DONNÉES JSON (après transformation)
-- ============================================================

-- TABLE 5 : companies (source : companies.json)
CREATE OR REPLACE TABLE companies (
    company_id    VARCHAR(50)  COMMENT 'Identifiant LinkedIn de l entreprise',
    name          VARCHAR(255) COMMENT 'Nom de l entreprise',
    description   TEXT         COMMENT 'Description de l entreprise',
    company_size  INTEGER      COMMENT 'Taille (0=<10 employés ... 7=>10000)',
    state         VARCHAR(100) COMMENT 'État du siège social',
    country       VARCHAR(100) COMMENT 'Pays du siège social',
    city          VARCHAR(100) COMMENT 'Ville du siège social',
    zip_code      VARCHAR(20)  COMMENT 'Code postal',
    address       VARCHAR(500) COMMENT 'Adresse complète',
    url           VARCHAR(500) COMMENT 'URL de la page LinkedIn de l entreprise'
);

-- TABLE 6 : job_industries (source : job_industries.json)
CREATE OR REPLACE TABLE job_industries (
    job_id       VARCHAR(50) COMMENT 'Référence à job_postings.job_id',
    industry_id  VARCHAR(50) COMMENT 'Identifiant du secteur d activité'
);

-- TABLE 7 : company_specialities (source : company_specialities.json)
CREATE OR REPLACE TABLE company_specialities (
    company_id  VARCHAR(50)  COMMENT 'Référence à companies.company_id',
    speciality  VARCHAR(255) COMMENT 'Spécialité de l entreprise'
);

-- TABLE 8 : company_industries (source : company_industries.json)
CREATE OR REPLACE TABLE company_industries (
    company_id  VARCHAR(50)  COMMENT 'Référence à companies.company_id',
    industry    VARCHAR(255) COMMENT 'Secteur d activité de l entreprise'
);

-- ============================================================
-- VÉRIFICATION : Liste toutes les tables créées
-- ============================================================
SHOW TABLES IN SCHEMA raw_data;
