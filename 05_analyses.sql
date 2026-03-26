-- ============================================================
-- SCRIPT 05 : ANALYSES DES DONNÉES
-- Projet : Analyse des Offres d'Emploi LinkedIn avec Snowflake
-- ============================================================

USE DATABASE linkedin;
USE SCHEMA raw_data;

-- ============================================================
-- ANALYSE 1 : Top 10 des titres de postes les plus publiés
--             par industrie
-- ============================================================
-- Objectif : Identifier les postes les plus demandés dans
--            chaque secteur d'activité.
-- Technique : CTE + ROW_NUMBER() partitionné par industrie
-- ============================================================
WITH ranked_jobs AS (
    SELECT
        ci.industry                   AS industrie,
        jp.title                      AS titre_poste,
        COUNT(*)                      AS nb_offres,
        ROW_NUMBER() OVER (
            PARTITION BY ci.industry
            ORDER BY COUNT(*) DESC
        )                             AS rang
    FROM job_postings  jp
    JOIN job_industries     ji ON jp.job_id      = ji.job_id
    JOIN company_industries ci ON ji.industry_id = ci.industry
    GROUP BY ci.industry, jp.title
)
SELECT
    industrie,
    rang,
    titre_poste,
    nb_offres
FROM ranked_jobs
WHERE rang <= 10
ORDER BY industrie, rang;

-- ============================================================
-- ANALYSE 2 : Top 10 des postes les mieux rémunérés
--             par industrie
-- ============================================================
-- Objectif : Identifier les postes les plus rémunérateurs
--            dans chaque secteur.
-- Note : Basé sur le salaire médian moyen (med_salary).
--        Les offres sans salaire sont exclues (WHERE IS NOT NULL).
-- ============================================================
WITH salary_ranked AS (
    SELECT
        ci.industry                          AS industrie,
        jp.title                             AS titre_poste,
        ROUND(AVG(jp.med_salary), 0)         AS salaire_median_moyen,
        COUNT(*)                             AS nb_offres,
        ROW_NUMBER() OVER (
            PARTITION BY ci.industry
            ORDER BY AVG(jp.med_salary) DESC NULLS LAST
        )                                    AS rang
    FROM job_postings  jp
    JOIN job_industries     ji ON jp.job_id      = ji.job_id
    JOIN company_industries ci ON ji.industry_id = ci.industry
    WHERE jp.med_salary IS NOT NULL
    GROUP BY ci.industry, jp.title
)
SELECT
    industrie,
    rang,
    titre_poste,
    salaire_median_moyen,
    nb_offres
FROM salary_ranked
WHERE rang <= 10
ORDER BY industrie, rang;

-- ============================================================
-- ANALYSE 3 : Répartition des offres d'emploi
--             par taille d'entreprise
-- ============================================================
-- Objectif : Savoir si les grandes ou les petites entreprises
--            publient le plus d'offres sur LinkedIn.
-- Note : company_size va de 0 (très petite) à 7 (multinationale)
-- ============================================================
SELECT
    CASE c.company_size
        WHEN 0 THEN '0 — Très petite   (< 10 emp.)'
        WHEN 1 THEN '1 — Petite        (10–50 emp.)'
        WHEN 2 THEN '2 — PME           (51–200 emp.)'
        WHEN 3 THEN '3 — Moyenne       (201–500 emp.)'
        WHEN 4 THEN '4 — Grande        (501–1 000 emp.)'
        WHEN 5 THEN '5 — Très grande   (1 001–5 000 emp.)'
        WHEN 6 THEN '6 — Entreprise    (5 001–10 000 emp.)'
        WHEN 7 THEN '7 — Multinationale(> 10 000 emp.)'
        ELSE        'Non renseignée'
    END                                                          AS taille_entreprise,
    COUNT(jp.job_id)                                             AS nb_offres,
    ROUND(COUNT(jp.job_id) * 100.0 / SUM(COUNT(jp.job_id)) OVER(), 2) AS pourcentage
FROM job_postings jp
LEFT JOIN companies c
       ON TRIM(LOWER(jp.company_name)) = TRIM(LOWER(c.name))
GROUP BY c.company_size
ORDER BY c.company_size NULLS LAST;

-- ============================================================
-- ANALYSE 4 : Répartition des offres par secteur d'activité
-- ============================================================
-- Objectif : Identifier les secteurs les plus actifs
--            en recrutement sur LinkedIn.
-- ============================================================
SELECT
    ci.industry                                                  AS secteur_activite,
    COUNT(DISTINCT jp.job_id)                                    AS nb_offres,
    ROUND(
        COUNT(DISTINCT jp.job_id) * 100.0
        / SUM(COUNT(DISTINCT jp.job_id)) OVER(),
        2
    )                                                            AS pourcentage
FROM job_postings  jp
JOIN job_industries     ji ON jp.job_id      = ji.job_id
JOIN company_industries ci ON ji.industry_id = ci.industry
GROUP BY ci.industry
ORDER BY nb_offres DESC
LIMIT 20;

-- ============================================================
-- ANALYSE 5 : Répartition des offres par type d'emploi
-- ============================================================
-- Objectif : Connaître la répartition CDI / CDD /
--            Temps partiel / Stage / Contrat sur LinkedIn.
-- ============================================================
SELECT
    COALESCE(formatted_work_type, 'Non spécifié')               AS type_emploi,
    COUNT(*)                                                     AS nb_offres,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)           AS pourcentage
FROM job_postings
GROUP BY formatted_work_type
ORDER BY nb_offres DESC;
