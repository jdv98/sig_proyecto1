CREATE EXTENSION postgis;

CREATE TABLE bloques (
	ID serial,
	geom geometry(POLYGON,4326)
);

CREATE TABLE terrazas (
	ID serial,
	geom geometry(POLYGON,4326)
);