<h1>github-circleci-dbtcloud-databricks-uc-medallion</h1>

<p>
Minimal, production-style portfolio project demonstrating an end-to-end analytics deployment pipeline using:
<b>GitHub</b>, <b>CircleCI</b>, <b>dbt (dbt Cloud compatible workflow)</b>, and <b>Databricks Unity Catalog</b>.
</p>

<h2>Architecture</h2>
<p>This repo implements a Medallion Architecture with dbt:</p>
<ul>
  <li><b>Bronze</b>: dbt seeds (CSV) materialized as tables in schema <b>bronze</b></li>
  <li><b>Silver</b>: cleaned/staged models in schema <b>silver</b></li>
  <li><b>Gold</b>: business-facing view in schema <b>gold</b></li>
</ul>

<p>
Final required business view:
<b>dbt_project_catalog.gold.gold_sales__monthly</b>
</p>

<h3>Why the custom schema macro?</h3>
<p>
Databricks Unity Catalog environments often need consistent schema naming. This project overrides dbt default schema name generation
to avoid unwanted user-prefix patterns and keep schema names exactly as configured (bronze/silver/gold).
</p>

<h2>Prerequisites</h2>
<ul>
  <li>Databricks workspace with Unity Catalog enabled</li>
  <li>A SQL Warehouse (or cluster) HTTP Path for SQL connectivity</li>
  <li>A Databricks Personal Access Token</li>
  <li>CircleCI project connected to your GitHub repo</li>
</ul>

<h2>CircleCI setup</h2>
<p>Create the following environment variables in your CircleCI project settings:</p>
<ul>
  <li><b>DB_HOST</b> (example: adb-1234567890123456.7.azuredatabricks.net)</li>
  <li><b>DB_HTTP_PATH</b> (example: /sql/1.0/warehouses/xxxxxxxxxxxxxxxx)</li>
  <li><b>DB_TOKEN</b> (Databricks PAT)</li>
</ul>

<p>
CircleCI generates <b>profiles.yml</b> at runtime using plain echo statements (no heredoc, no YAML anchors, no orbs).
Catalog is set to <b>dbt_project_catalog</b> and the default schema is <b>dev</b> (dbt routes objects to bronze/silver/gold).
</p>

<h2>Run locally (optional)</h2>
<p>If you want to run dbt locally:</p>
<pre><code>python -m pip install --upgrade pip
pip install dbt-databricks==1.11.4
</code></pre>

<p>Create a local dbt profile at <b>~/.dbt/profiles.yml</b> (example):</p>
<pre><code>dbt_uc_medallion:
  target: prod
  outputs:
    prod:
      type: databricks
      host: "YOUR_DB_HOST"
      http_path: "YOUR_DB_HTTP_PATH"
      token: "YOUR_DB_TOKEN"
      catalog: dbt_project_catalog
      schema: dev
      threads: 4
</code></pre>

<p>Then run:</p>
<pre><code>dbt deps
dbt seed
dbt build
</code></pre>

<h2>Databricks verification SQL</h2>
<p>Run these in Databricks SQL after a successful pipeline run:</p>

<pre><code>-- Confirm the gold view exists
show tables in dbt_project_catalog.gold;

-- Validate final output
select *
from dbt_project_catalog.gold.gold_sales__monthly
order by month_start;

-- Quick sanity checks
select
  count(*) as rows,
  min(month_start) as min_month,
  max(month_start) as max_month
from dbt_project_catalog.gold.gold_sales__monthly;
</code></pre>

<h2>dbt Cloud note</h2>
<p>
This project is intentionally runnable in CI via dbt Core for portability and minimalism.
You can still use dbt Cloud for development (IDE, docs, scheduling) by pointing dbt Cloud to the same repo and Databricks target.
</p>
