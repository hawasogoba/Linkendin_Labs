-- ============================================================
-- SCRIPT 01 : SETUP DE LA BASE DE DONNÉES LINKEDIN
-- Projet : Analyse des Offres d'Emploi LinkedIn avec Snowflake
-- MBA Big Data & IA — MBAESG
-- ============================================================

-- ============================================================
-- 1. CRÉATION DE LA BASE DE DONNÉES ET DU SCHÉMA
-- ============================================================

-- Crée la base de données principale du projet
CREATE DATABASE IF NOT EXISTS linkedin;

-- On se place dans la base linkedin
USE DATABASE linkedin;

-- Crée le schéma raw_data qui contiendra toutes nos tables
CREATE SCHEMA IF NOT EXISTS raw_data;

-- On se place dans le schéma raw_data
USE SCHEMA raw_data;

-- ============================================================
-- 2. CRÉATION DU STAGE EXTERNE (S3)
-- Un "stage" est un pointeur vers une source de données externe.
-- Ici, il pointe vers le bucket S3 public fourni.
-- ============================================================

CREATE STAGE IF NOT EXISTS linkedin_stage
  URL = 's3://snowflake-lab-bucket/'
  COMMENT = 'Stage externe pointant vers le bucket S3 LinkedIn public';

-- Vérification : liste les fichiers disponibles dans le stage
LIST @linkedin_stage;

-- ============================================================
-- 3. DÉFINITION DES FORMATS DE FICHIERS
-- ============================================================

-- Format CSV :
-- - SKIP_HEADER = 1 : ignore la première ligne (en-tête)
-- - FIELD_OPTIONALLY_ENCLOSED_BY = '"' : gère les champs entre guillemets
-- - NULL_IF : traite ces valeurs comme NULL
-- - EMPTY_FIELD_AS_NULL : champ vide = NULL
-- - TRIM_SPACE : supprime les espaces autour des valeurs
CREATE OR REPLACE FILE FORMAT csv_format
  TYPE                      = 'CSV'
  FIELD_DELIMITER           = ','
  RECORD_DELIMITER          = '\n'
  SKIP_HEADER               = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  NULL_IF                   = ('NULL', 'null', '', 'N/A', 'n/a')
  EMPTY_FIELD_AS_NULL       = TRUE
  TRIM_SPACE                = TRUE
  COMMENT                   = 'Format pour fichiers CSV avec en-tête';

-- Format JSON :
-- - STRIP_OUTER_ARRAY = TRUE : retire le tableau racine [...] pour lire objet par objet
-- - IGNORE_UTF8_ERRORS : évite les erreurs d'encodage
CREATE OR REPLACE FILE FORMAT json_format
  TYPE               = 'JSON'
  STRIP_OUTER_ARRAY  = TRUE
  IGNORE_UTF8_ERRORS = TRUE
  COMMENT            = 'Format pour fichiers JSON avec tableau racine';

-- ============================================================
-- VÉRIFICATION : Affiche les formats créés
-- ============================================================
SHOW FILE FORMATS IN SCHEMA raw_data;
