# ============================================================
# APPLICATION STREAMLIT — LinkedIn Jobs Analysis Dashboard
# Projet : Analyse des Offres d'Emploi LinkedIn avec Snowflake
# MBA Big Data & IA — MBAESG
# Fichier : streamlit_app.py
#
# ⚠️ DÉPLOIEMENT : Cette app doit être déployée directement
#    dans Snowflake via : Projects > Streamlit > + Streamlit App
#    Elle utilise get_active_session() pour se connecter
#    automatiquement à la base linkedin.
# ============================================================

import streamlit as st
import pandas as pd
import altair as alt
from snowflake.snowpark.context import get_active_session

# ============================================================
# CONFIGURATION DE LA PAGE
# ============================================================
st.set_page_config(
    page_title="LinkedIn Jobs Dashboard",
    page_icon="💼",
    layout="wide",
    initial_sidebar_state="collapsed"
)

# ============================================================
# CSS PERSONNALISÉ — Thème LinkedIn
# ============================================================
st.markdown("""
<style>
    /* Fond principal */
    .main { background-color: #F3F2EF; }

    /* Titre principal */
    .main-title {
        font-size: 2.4rem;
        font-weight: 800;
        color: #0077B5;
        text-align: center;
        padding: 10px 0 0 0;
    }
    .sub-title {
        font-size: 1.1rem;
        color: #666;
        text-align: center;
        margin-bottom: 20px;
    }

    /* Cartes métriques */
    [data-testid="metric-container"] {
        background-color: white;
        border: 1px solid #e0e0e0;
        border-radius: 12px;
        padding: 15px;
        box-shadow: 0 2px 6px rgba(0,0,0,0.07);
    }

    /* Onglets */
    .stTabs [data-baseweb="tab-list"] {
        gap: 8px;
    }
    .stTabs [data-baseweb="tab"] {
        background-color: white;
        border-radius: 8px 8px 0 0;
        border: 1px solid #ddd;
        font-weight: 600;
    }

    /* Séparateur */
    hr { border-color: #0077B5; opacity: 0.3; }
</style>
""", unsafe_allow_html=True)

# ============================================================
# CONNEXION SNOWFLAKE (automatique dans Snowflake Streamlit)
# ============================================================
session = get_active_session()

# ============================================================
# EN-TÊTE DU DASHBOARD
# ============================================================
st.markdown('<p class="main-title">💼 LinkedIn Jobs Market Dashboard</p>', unsafe_allow_html=True)
st.markdown('<p class="sub-title">Analyse des offres d\'emploi LinkedIn • MBA Big Data & IA — MBAESG</p>', unsafe_allow_html=True)
st.markdown("---")

# ============================================================
# MÉTRIQUES GLOBALES (KPIs en haut de page)
# ============================================================
@st.cache_data
def get_kpis():
    total_jobs      = session.sql("SELECT COUNT(*) FROM linkedin.raw_data.job_postings").collect()[0][0]
    total_companies = session.sql("SELECT COUNT(DISTINCT company_name) FROM linkedin.raw_data.job_postings").collect()[0][0]
    total_industries= session.sql("SELECT COUNT(DISTINCT industry) FROM linkedin.raw_data.company_industries").collect()[0][0]
    avg_salary_row  = session.sql(
        "SELECT ROUND(AVG(med_salary),0) FROM linkedin.raw_data.job_postings WHERE med_salary IS NOT NULL"
    ).collect()[0][0]
    remote_pct      = session.sql(
        "SELECT ROUND(COUNT(*) FILTER(WHERE remote_allowed=TRUE) * 100.0 / COUNT(*), 1) FROM linkedin.raw_data.job_postings"
    ).collect()[0][0]
    return total_jobs, total_companies, total_industries, avg_salary_row, remote_pct

total_jobs, total_companies, total_industries, avg_salary, remote_pct = get_kpis()

col1, col2, col3, col4, col5 = st.columns(5)
with col1:
    st.metric("📋 Total Offres",       f"{total_jobs:,}")
with col2:
    st.metric("🏢 Entreprises",        f"{total_companies:,}")
with col3:
    st.metric("🏭 Secteurs d'activité",f"{total_industries:,}")
with col4:
    st.metric("💰 Salaire Médian Moy.",f"${avg_salary:,.0f}" if avg_salary else "N/A")
with col5:
    st.metric("🏠 Offres Remote",      f"{remote_pct}%" if remote_pct else "N/A")

st.markdown("---")

# ============================================================
# ONGLETS DES 5 ANALYSES
# ============================================================
tab1, tab2, tab3, tab4, tab5 = st.tabs([
    "🏆 Top 10 Titres / Industrie",
    "💰 Top 10 Salaires / Industrie",
    "🏢 Taille d'Entreprise",
    "🏭 Secteurs d'Activité",
    "⏱️ Types d'Emploi"
])

# ============================================================
# TAB 1 — Top 10 titres de postes par industrie
# ============================================================
with tab1:
    st.subheader("🏆 Top 10 des titres de postes les plus publiés par industrie")
    st.caption("Utilisez le menu déroulant pour explorer chaque secteur d'activité.")

    @st.cache_data
    def get_top_titles():
        query = """
        WITH ranked_jobs AS (
            SELECT
                ci.industry   AS INDUSTRIE,
                jp.title      AS TITRE_POSTE,
                COUNT(*)      AS NB_OFFRES,
                ROW_NUMBER() OVER (PARTITION BY ci.industry ORDER BY COUNT(*) DESC) AS RANG
            FROM linkedin.raw_data.job_postings jp
            JOIN linkedin.raw_data.job_industries     ji ON jp.job_id      = ji.job_id
            JOIN linkedin.raw_data.company_industries ci ON ji.industry_id = ci.industry
            GROUP BY ci.industry, jp.title
        )
        SELECT INDUSTRIE, TITRE_POSTE, NB_OFFRES, RANG
        FROM ranked_jobs
        WHERE RANG <= 10
        ORDER BY INDUSTRIE, RANG
        """
        return session.sql(query).to_pandas()

    df1 = get_top_titles()
    industries1 = sorted(df1['INDUSTRIE'].dropna().unique())

    selected_ind1 = st.selectbox(
        "🔍 Sélectionnez un secteur d'activité :",
        options=industries1,
        key="select_tab1"
    )

    df1_filtered = df1[df1['INDUSTRIE'] == selected_ind1].sort_values('NB_OFFRES', ascending=False)

    # Graphique barres horizontales
    chart1 = alt.Chart(df1_filtered).mark_bar(
        color='#0077B5',
        cornerRadiusTopRight=5,
        cornerRadiusBottomRight=5
    ).encode(
        x=alt.X('NB_OFFRES:Q', title="Nombre d'offres"),
        y=alt.Y('TITRE_POSTE:N', sort='-x', title=""),
        tooltip=[
            alt.Tooltip('TITRE_POSTE:N', title='Poste'),
            alt.Tooltip('NB_OFFRES:Q',   title="Nb d'offres")
        ]
    ).properties(
        title=f"Top 10 postes — {selected_ind1}",
        height=400
    )

    # Annotation du nombre sur chaque barre
    text1 = chart1.mark_text(align='left', dx=5, color='#333').encode(
        text=alt.Text('NB_OFFRES:Q')
    )

    st.altair_chart(chart1 + text1, use_container_width=True)

    with st.expander("📋 Voir le tableau de données"):
        st.dataframe(
            df1_filtered[['RANG', 'TITRE_POSTE', 'NB_OFFRES']].reset_index(drop=True),
            use_container_width=True
        )

# ============================================================
# TAB 2 — Top 10 postes les mieux rémunérés par industrie
# ============================================================
with tab2:
    st.subheader("💰 Top 10 des postes les mieux rémunérés par industrie")
    st.caption("Basé sur le salaire médian moyen annuel. Seules les offres avec salaire renseigné sont incluses.")

    @st.cache_data
    def get_top_salaries():
        query = """
        WITH salary_ranked AS (
            SELECT
                ci.industry                      AS INDUSTRIE,
                jp.title                         AS TITRE_POSTE,
                ROUND(AVG(jp.med_salary), 0)     AS SALAIRE_MEDIAN,
                COUNT(*)                         AS NB_OFFRES,
                ROW_NUMBER() OVER (
                    PARTITION BY ci.industry
                    ORDER BY AVG(jp.med_salary) DESC NULLS LAST
                )                                AS RANG
            FROM linkedin.raw_data.job_postings jp
            JOIN linkedin.raw_data.job_industries     ji ON jp.job_id      = ji.job_id
            JOIN linkedin.raw_data.company_industries ci ON ji.industry_id = ci.industry
            WHERE jp.med_salary IS NOT NULL
            GROUP BY ci.industry, jp.title
        )
        SELECT INDUSTRIE, TITRE_POSTE, SALAIRE_MEDIAN, NB_OFFRES, RANG
        FROM salary_ranked
        WHERE RANG <= 10
        ORDER BY INDUSTRIE, RANG
        """
        return session.sql(query).to_pandas()

    df2 = get_top_salaries()
    industries2 = sorted(df2['INDUSTRIE'].dropna().unique())

    selected_ind2 = st.selectbox(
        "🔍 Sélectionnez un secteur d'activité :",
        options=industries2,
        key="select_tab2"
    )

    df2_filtered = df2[df2['INDUSTRIE'] == selected_ind2].sort_values('SALAIRE_MEDIAN', ascending=False)

    chart2 = alt.Chart(df2_filtered).mark_bar(
        color='#00A0DC',
        cornerRadiusTopRight=5,
        cornerRadiusBottomRight=5
    ).encode(
        x=alt.X('SALAIRE_MEDIAN:Q',
                title="Salaire médian ($)",
                axis=alt.Axis(format='$,.0f')),
        y=alt.Y('TITRE_POSTE:N', sort='-x', title=""),
        tooltip=[
            alt.Tooltip('TITRE_POSTE:N',   title='Poste'),
            alt.Tooltip('SALAIRE_MEDIAN:Q', title='Salaire médian ($)', format='$,.0f'),
            alt.Tooltip('NB_OFFRES:Q',      title="Nb d'offres")
        ]
    ).properties(
        title=f"Top 10 salaires — {selected_ind2}",
        height=400
    )

    text2 = chart2.mark_text(align='left', dx=5, color='#333').encode(
        text=alt.Text('SALAIRE_MEDIAN:Q', format='$,.0f')
    )

    st.altair_chart(chart2 + text2, use_container_width=True)

    with st.expander("📋 Voir le tableau de données"):
        df2_display = df2_filtered.copy()
        df2_display['SALAIRE_MEDIAN'] = df2_display['SALAIRE_MEDIAN'].apply(lambda x: f"${x:,.0f}")
        st.dataframe(
            df2_display[['RANG', 'TITRE_POSTE', 'SALAIRE_MEDIAN', 'NB_OFFRES']].reset_index(drop=True),
            use_container_width=True
        )

# ============================================================
# TAB 3 — Répartition par taille d'entreprise
# ============================================================
with tab3:
    st.subheader("🏢 Répartition des offres d'emploi par taille d'entreprise")
    st.caption("La taille varie de 0 (< 10 employés) à 7 (> 10 000 employés).")

    @st.cache_data
    def get_by_company_size():
        query = """
        SELECT
            CASE c.company_size
                WHEN 0 THEN '0 — Très petite (< 10)'
                WHEN 1 THEN '1 — Petite (10–50)'
                WHEN 2 THEN '2 — PME (51–200)'
                WHEN 3 THEN '3 — Moyenne (201–500)'
                WHEN 4 THEN '4 — Grande (501–1000)'
                WHEN 5 THEN '5 — Très grande (1001–5000)'
                WHEN 6 THEN '6 — Entreprise (5001–10000)'
                WHEN 7 THEN '7 — Multinationale (> 10000)'
                ELSE 'Non renseignée'
            END                AS TAILLE_ENTREPRISE,
            COUNT(jp.job_id)   AS NB_OFFRES
        FROM linkedin.raw_data.job_postings jp
        LEFT JOIN linkedin.raw_data.companies c
               ON TRIM(LOWER(jp.company_name)) = TRIM(LOWER(c.name))
        GROUP BY c.company_size
        ORDER BY c.company_size NULLS LAST
        """
        return session.sql(query).to_pandas()

    df3 = get_by_company_size()
    total3 = df3['NB_OFFRES'].sum()
    df3['POURCENTAGE'] = (df3['NB_OFFRES'] / total3 * 100).round(1)

    col_bar3, col_pie3 = st.columns([3, 2])

    with col_bar3:
        chart3_bar = alt.Chart(df3).mark_bar(color='#0077B5', cornerRadiusTopRight=5).encode(
            x=alt.X('TAILLE_ENTREPRISE:N', sort=None, title="Taille d'entreprise",
                    axis=alt.Axis(labelAngle=-25, labelFontSize=11)),
            y=alt.Y('NB_OFFRES:Q', title="Nombre d'offres"),
            tooltip=[
                alt.Tooltip('TAILLE_ENTREPRISE:N', title='Taille'),
                alt.Tooltip('NB_OFFRES:Q', title="Nb d'offres"),
                alt.Tooltip('POURCENTAGE:Q', title='%', format='.1f')
            ]
        ).properties(title="Offres par taille d'entreprise", height=380)
        st.altair_chart(chart3_bar, use_container_width=True)

    with col_pie3:
        chart3_donut = alt.Chart(df3).mark_arc(innerRadius=60, outerRadius=130).encode(
            theta=alt.Theta('NB_OFFRES:Q'),
            color=alt.Color('TAILLE_ENTREPRISE:N',
                           scale=alt.Scale(scheme='blues'),
                           legend=alt.Legend(title="Taille", orient='bottom', columns=2)),
            tooltip=[
                alt.Tooltip('TAILLE_ENTREPRISE:N', title='Taille'),
                alt.Tooltip('NB_OFFRES:Q',          title="Nb d'offres"),
                alt.Tooltip('POURCENTAGE:Q',         title='%', format='.1f')
            ]
        ).properties(title="Répartition en %", height=380)
        st.altair_chart(chart3_donut, use_container_width=True)

    with st.expander("📋 Voir le tableau de données"):
        df3['POURCENTAGE'] = df3['POURCENTAGE'].astype(str) + '%'
        st.dataframe(df3[['TAILLE_ENTREPRISE','NB_OFFRES','POURCENTAGE']], use_container_width=True)

# ============================================================
# TAB 4 — Répartition par secteur d'activité
# ============================================================
with tab4:
    st.subheader("🏭 Répartition des offres par secteur d'activité")
    st.caption("Top 20 des secteurs d'activité les plus représentés sur LinkedIn.")

    @st.cache_data
    def get_by_industry():
        query = """
        SELECT
            ci.industry                 AS SECTEUR_ACTIVITE,
            COUNT(DISTINCT jp.job_id)   AS NB_OFFRES
        FROM linkedin.raw_data.job_postings jp
        JOIN linkedin.raw_data.job_industries     ji ON jp.job_id      = ji.job_id
        JOIN linkedin.raw_data.company_industries ci ON ji.industry_id = ci.industry
        GROUP BY ci.industry
        ORDER BY NB_OFFRES DESC
        LIMIT 20
        """
        return session.sql(query).to_pandas()

    df4 = get_by_industry()
    total4 = df4['NB_OFFRES'].sum()
    df4['POURCENTAGE'] = (df4['NB_OFFRES'] / total4 * 100).round(1)

    chart4 = alt.Chart(df4).mark_bar(cornerRadiusTopRight=5).encode(
        x=alt.X('NB_OFFRES:Q', title="Nombre d'offres"),
        y=alt.Y('SECTEUR_ACTIVITE:N', sort='-x', title=""),
        color=alt.Color('NB_OFFRES:Q',
                       scale=alt.Scale(scheme='blues', reverse=False),
                       legend=None),
        tooltip=[
            alt.Tooltip('SECTEUR_ACTIVITE:N', title='Secteur'),
            alt.Tooltip('NB_OFFRES:Q',         title="Nb d'offres"),
            alt.Tooltip('POURCENTAGE:Q',        title='%', format='.1f')
        ]
    ).properties(
        title="Top 20 des secteurs d'activité par nombre d'offres",
        height=550
    )

    text4 = chart4.mark_text(align='left', dx=5, fontSize=11, color='#333').encode(
        text=alt.Text('NB_OFFRES:Q', format=',')
    )

    st.altair_chart(chart4 + text4, use_container_width=True)

    with st.expander("📋 Voir le tableau de données"):
        df4['POURCENTAGE'] = df4['POURCENTAGE'].astype(str) + '%'
        st.dataframe(df4[['SECTEUR_ACTIVITE','NB_OFFRES','POURCENTAGE']], use_container_width=True)

# ============================================================
# TAB 5 — Répartition par type d'emploi
# ============================================================
with tab5:
    st.subheader("⏱️ Répartition des offres par type d'emploi")
    st.caption("Distribution entre Full-time, Part-time, Contract, Internship, etc.")

    @st.cache_data
    def get_by_work_type():
        query = """
        SELECT
            COALESCE(formatted_work_type, 'Non spécifié') AS TYPE_EMPLOI,
            COUNT(*)                                       AS NB_OFFRES,
            ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS POURCENTAGE
        FROM linkedin.raw_data.job_postings
        GROUP BY formatted_work_type
        ORDER BY NB_OFFRES DESC
        """
        return session.sql(query).to_pandas()

    df5 = get_by_work_type()

    linkedin_colors = ['#0077B5', '#00A0DC', '#5BC0EB', '#9BC4E2', '#C8E6F5', '#E8F4FD']

    col_donut5, col_bar5 = st.columns(2)

    with col_donut5:
        chart5_donut = alt.Chart(df5).mark_arc(innerRadius=80, outerRadius=150).encode(
            theta=alt.Theta('NB_OFFRES:Q'),
            color=alt.Color('TYPE_EMPLOI:N',
                           scale=alt.Scale(range=linkedin_colors),
                           legend=alt.Legend(title="Type d'emploi", orient='bottom')),
            tooltip=[
                alt.Tooltip('TYPE_EMPLOI:N',  title='Type'),
                alt.Tooltip('NB_OFFRES:Q',     title="Nb d'offres"),
                alt.Tooltip('POURCENTAGE:Q',   title='%')
            ]
        ).properties(
            title="Répartition par type d'emploi",
            height=400
        )
        st.altair_chart(chart5_donut, use_container_width=True)

    with col_bar5:
        chart5_bar = alt.Chart(df5).mark_bar(cornerRadiusTopRight=5).encode(
            x=alt.X('TYPE_EMPLOI:N', sort='-y', title="Type d'emploi",
                    axis=alt.Axis(labelAngle=-20)),
            y=alt.Y('NB_OFFRES:Q', title="Nombre d'offres"),
            color=alt.Color('TYPE_EMPLOI:N',
                           scale=alt.Scale(range=linkedin_colors),
                           legend=None),
            tooltip=[
                alt.Tooltip('TYPE_EMPLOI:N',  title='Type'),
                alt.Tooltip('NB_OFFRES:Q',     title="Nb d'offres"),
                alt.Tooltip('POURCENTAGE:Q',   title='%')
            ]
        ).properties(
            title="Nombre d'offres par type",
            height=400
        )

        text5 = chart5_bar.mark_text(dy=-8, fontSize=12, fontWeight='bold', color='#333').encode(
            text=alt.Text('NB_OFFRES:Q', format=',')
        )
        st.altair_chart(chart5_bar + text5, use_container_width=True)

    with st.expander("📋 Voir le tableau de données"):
        df5['POURCENTAGE'] = df5['POURCENTAGE'].astype(str) + '%'
        st.dataframe(df5[['TYPE_EMPLOI','NB_OFFRES','POURCENTAGE']], use_container_width=True)

# ============================================================
# FOOTER
# ============================================================
st.markdown("---")
st.markdown(
    """
    <div style='text-align:center; color:#888; font-size:0.85rem;'>
        📊 <strong>LinkedIn Jobs Dashboard</strong> — MBA Big Data & IA — MBAESG 2024/2025<br>
        Données : <em>s3://snowflake-lab-bucket/</em> | Construit avec Snowflake + Streamlit
    </div>
    """,
    unsafe_allow_html=True
)
