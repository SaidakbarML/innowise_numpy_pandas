-- creating tabel shcema and we later insert our table data to it 
CREATE TABLE bom (
    year                                INTEGER,
    month                               INTEGER,
    produced_material                   INTEGER,
    produced_material_production_type   INTEGER,
    produced_material_release_type      TEXT,
    produced_material_quantity          REAL,
    component_material                  INTEGER,
    component_material_production_type  INTEGER,
    component_material_release_type     TEXT,
    component_material_quantity         REAL,
    plant_id                            TEXT
);
-- we created 2 anchor view fin,recipes which we use while doing recursive join later
CREATE VIEW fin AS
SELECT DISTINCT plant_id, year, produced_material, component_material
FROM bom
WHERE produced_material_release_type = 'FIN';

CREATE VIEW recipes AS
SELECT DISTINCT plant_id, year, produced_material,
       component_material, component_material_release_type
FROM bom;
-- this recursive ends when htere is no data left 
WITH RECURSIVE chain AS (
    SELECT f.plant_id, f.year,
           f.produced_material  AS fin_material_id,
           r.produced_material  AS prod_material_id,
           r.component_material AS component_id,
           r.component_material_release_type AS component_type
    FROM fin f
    JOIN recipes r
      ON  r.plant_id = f.plant_id
      AND r.year = f.year
      AND r.produced_material = f.component_material
    UNION ALL --combine two tables 
    SELECT c.plant_id, c.year,
           c.fin_material_id,
           r.produced_material,
           r.component_material,
           r.component_material_release_type
    FROM chain c
    JOIN recipes r
      ON  r.plant_id = c.plant_id
      AND r.year = c.year
      AND r.produced_material = c.component_id
    WHERE c.component_type = 'PROD'
)
SELECT * FROM chain;
