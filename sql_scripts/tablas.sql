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

create table productos
(
	id 			serial primary key,
	tipo		varchar(50) not null,
	ingrediente	varchar(200) not null,
	cultivo		varchar(50) not null,
	dosis_min	float,
	dosis_max	float,
	dosis_media	float,
	metrica		varchar(50) not null
);

create table drones
(
	id 					serial primary key,
	marca				varchar(100) null,
	modelo				varchar(100) null,
	duracion_bateria	float not null,
	capacidad_tanque	float not null
);

create table configuraciones 
(
	id 					serial primary key,
	drone				int not null,
	altitud				float not null,
	ancho_cobertura		float not null,
	velocidad_drone		float not null,
	volumen_descarga	float not null,
	baterias_x_ha		float not null,
	foreign key (drone) references drones
);