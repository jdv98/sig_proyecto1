CREATE EXTENSION postgis;

CREATE TABLE bloques (
	ID serial PRIMARY KEY,
	geom3857 geometry(POLYGON,3857),
	geom5367 geometry(POLYGON,5367)
);

CREATE TABLE terrazas (
	ID serial PRIMARY KEY,
	geom3857 geometry(POLYGON,3857),
	geom5367 geometry(POLYGON,5367)
);