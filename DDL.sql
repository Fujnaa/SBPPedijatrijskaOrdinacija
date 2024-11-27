--PRAVLJENJE SEME--

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Projekat')
	EXEC ('CREATE SCHEMA [Projekat]')
Go

--BRISANJE TABELA--

IF Object_Id ('Projekat.Pohadja', 'U') is not null
Drop Table Projekat.Pohadja;

IF Object_Id ('Projekat.Organizuje', 'U') is not null
Drop Table Projekat.Organizuje;

IF Object_Id ('Projekat.Radi_Tokom', 'U') is not null
Drop Table Projekat.Radi_Tokom;

IF Object_Id ('Projekat.Pripada_Danu', 'U') is not null
Drop Table Projekat.Pripada_Danu;

IF Object_Id ('Projekat.Licenca', 'U') is not null
Drop Table Projekat.Licenca;

IF Object_Id ('Projekat.MedicinskiTehnicar', 'U') is not null
Drop Table Projekat.MedicinskiTehnicar;
Go

IF Object_Id ('Projekat.Lekar', 'U') is not null
Drop Table Projekat.Lekar;
Go

IF Object_Id ('Projekat.ZdravstveniRadnik', 'U') is not null
Drop Table Projekat.ZdravstveniRadnik;
Go

IF Object_Id ('Projekat.Institucija', 'U') is not null
Drop Table Projekat.Institucija;

IF Object_Id ('Projekat.IstorijatSeminara', 'U') is not null
Drop Table Projekat.IstorijatSeminara;
Go

IF Object_Id ('Projekat.Seminar', 'U') is not null
Drop Table Projekat.Seminar;
Go

IF Object_Id ('Projekat.Organizuje', 'U') is not null
Drop Table Projekat.Organizuje;
Go

IF Object_Id ('Projekat.RadniKalendar', 'U') is not null
Drop Table Projekat.RadniKalendar;
Go

IF Object_Id ('Projekat.Termin', 'U') is not null
Drop Table Projekat.Termin;
Go

IF Object_Id ('Projekat.Smena', 'U') is not null
Drop Table Projekat.Smena;
Go

--SEKVENCE--

if exists (select * from sys.sequences where name = 'seq_lic')
	drop sequence seq_lic;
go

if exists (select * from sys.sequences where name = 'seq_sem')
	drop sequence seq_sem;
go

if exists (select * from sys.sequences where name = 'seq_istSem')
	drop sequence seq_istSem;
go

if exists (select * from sys.sequences where name = 'seq_radniKal')
	drop sequence seq_radniKal;
go

if exists (select * from sys.sequences where name = 'seq_term')
	drop sequence seq_term;
go

if exists (select * from sys.sequences where name = 'seq_sm')
	drop sequence seq_sm;
go

--BRISANJE SEKVENCI--

create sequence seq_lic as int
start with 1
minvalue 1
increment by 1
no cycle;

create sequence seq_sem as int
start with 1
minvalue 1
increment by 1
no cycle;

create sequence seq_istSem as int
start with 1
minvalue 1
increment by 1
no cycle;

create sequence seq_radniKal as int
start with 1
minvalue 1
increment by 1
no cycle;

create sequence seq_term as int
start with 1
minvalue 1
increment by 1
no cycle;

create sequence seq_sm as int
start with 1
minvalue 1
increment by 1
no cycle;


--KREIRANJE TABELA--

Create Table Projekat.ZdravstveniRadnik (

	JMBG_ZdravRad numeric(13),
	ImePrzZdravRad varchar(20) not null,
	KontaktZdravRad varchar(20) not null,
	EmailZdravRad varchar(30) not null,
	Plata numeric(10),
	DatumRodjZdravRad Date not null,
	MestoBoravka varchar(30),
	DatumZaposljavanja Date not null Default(GetDate()),
	RadniStaz int,

	Constraint PK_ZdravstveniRadnik primary key (JMBG_ZdravRad),
	Constraint UQ_ZdravstveniRadnik_KontaktZdravRad Unique(KontaktZdravRad),
	Constraint UQ_ZdravstveniRadnik_EmailZdravRad Unique(EmailZdravRad)

);

Create Table Projekat.MedicinskiTehnicar (

	JMBG_ZdravRad numeric(13),
	OblastDelatnosti varchar(50) not null

	Constraint PK_MedicinskiTehnicar primary key (JMBG_ZdravRad),
	Constraint FK_MedicinskiTehnicar_ZdravstveniRadnik Foreign Key (JMBG_ZdravRad)
	references Projekat.ZdravstveniRadnik(JMBG_ZdravRad)

);

Create Table Projekat.Lekar (

	JMBG_ZdravRad numeric(13),
	BrojOrdinacije numeric(3) not null

	Constraint PK_Lekar primary key (JMBG_ZdravRad),
	Constraint FK_Lekar_ZdravstveniRadnik Foreign Key (JMBG_ZdravRad)
	references Projekat.ZdravstveniRadnik(JMBG_ZdravRad),

	Constraint CH_Lekar_BrojOrdinacije Check (BrojOrdinacije > 0),

);

Create table Projekat.Licenca (

	ID_Lic numeric(14),
	JMBG_ZdravRad numeric(13),
	DatumObnove Date not null,
	DatumIstekaLic Date not null,
	Zvanje varchar(50) not null,
	Specijalizacija varchar(30) not null,
	SumaBodova numeric(3) not null DEFAULT(0),
	SubSpecijalizacija varchar(30),

	Constraint PK_Licenca primary key (ID_Lic, JMBG_ZdravRad),
	Constraint FK_JMBG_ZdravRad foreign key (JMBG_ZdravRad)
	references Projekat.ZdravstveniRadnik (JMBG_ZdravRad),
	Constraint CH_Licenca_SumaBodova Check (SumaBodova > -1),
	Constraint CH_Licenca_DatumObnove_DatumIstekaLic Check (DatumObnove < DatumIstekaLic)

);

Alter Table Projekat.Licenca Add Constraint SEQ_lic default(next value for seq_lic) for ID_Lic;

Create Table Projekat.Institucija (

	PIB numeric(9),
	NazivInstitucije varchar(50) not null,
	DelatnostInstitucije varchar(30) not null,
	KontaktInstitucije numeric(10) not null,
	AdresaInstitucije varchar(30) not null,

	Constraint PK_Institucija primary key (PIB),
	Constraint UQ_Institucija_NazivInstitucije Unique(NazivInstitucije),
	Constraint UQ_Institucija_KontaktInstitucije Unique(KontaktInstitucije)

);

Create Table Projekat.Seminar (

	ID_Seminar numeric(10),
	BrojBodova numeric(2) not null DEFAULT(5),
	TemaSeminara nvarchar(500) not null,
	NazivSeminara varchar(50) not null,
	DatumPocetkaSem Date not null,
	DatumZavrsetkaSem Date not null,

	Constraint PK_Seminar primary key (ID_Seminar),
	Constraint CH_Seminar_DatumPocetkaZavrsetkaSem Check (DatumPocetkaSem < DatumZavrsetkaSem)

);

Alter Table Projekat.Seminar Add Constraint SEQ_sem default(next value for seq_sem) for ID_Seminar;

Create Table Projekat.IstorijatSeminara (

	ID_IstorijatSeminara numeric(10),
	ID_Seminar numeric(10),
	BrojBodova numeric(2) DEFAULT(5),
	TemaSeminara nvarchar(500),
	NazivSeminara varchar(50),
	DatumPocetkaSem Date,
	DatumZavrsetkaSem Date,

	Constraint PK_IstorijatSeminara primary key (ID_IstorijatSeminara)

)

Alter Table Projekat.IstorijatSeminara Add Constraint SEQ_IstSem default(next value for seq_istSem) for ID_IstorijatSeminara;

Create Table Projekat.Organizuje (

	ID_Seminar numeric(10),
	PIB numeric(9)

	Constraint PK_Organizuje primary key (ID_Seminar, PIB),
	Constraint FK_Organizuje_Seminar foreign key (ID_Seminar)
	references Projekat.Seminar (ID_Seminar),
	Constraint FK_Organizuje_Institucija foreign key (PIB)
	references Projekat.Institucija (PIB)

);

Create Table Projekat.RadniKalendar (

	ID_RadniKalendar numeric(10),
	Datum Date not null,

	Constraint PK_RadniKalendar Primary Key (ID_RadniKalendar)

);

Alter Table Projekat.RadniKalendar Add Constraint SEQ_radniKal default(next value for seq_radniKal) for ID_RadniKalendar;

Create Table Projekat.Smena (

	RBR_Smena numeric(10),
	VremeOd Time not null,
	VremeDo Time not null,

	Constraint PK_Smena Primary Key (RBR_Smena)
);

Alter Table Projekat.Smena Add Constraint SEQ_sm default(next value for seq_sm) for RBR_Smena;

Create Table Projekat.Termin (

	ID_Termin numeric(10),
	RBR_Smena numeric(10),
	DatumZakazivanja Date not null,
	VremePocetka Time not null,
	VremeZavrsetka Time not null,

	Constraint PK_Termin Primary Key (ID_Termin, RBR_Smena),
	Constraint FK_Smena_Termin Foreign Key (RBR_Smena)
	references Projekat.Smena(RBR_Smena)
);

Alter Table Projekat.Termin Add Constraint SEQ_term default(next value for seq_term) for ID_Termin;

Create Table Projekat.Pohadja (

	JMBG_ZdravRad numeric(13),
	ID_Seminar numeric(10),

	Constraint PK_Pohadja primary key (JMBG_ZdravRad, ID_Seminar),
	Constraint FK_ZdravRad_Pohadja foreign key (JMBG_ZdravRad)
	references Projekat.ZdravstveniRadnik(JMBG_ZdravRad),
	Constraint FK_Seminar_Pohadja foreign key (ID_Seminar)
	references Projekat.Seminar (ID_Seminar)

);

Create Table Projekat.Radi_Tokom (

	JMBG_ZdravRad numeric(13),
	ID_RadniKalendar numeric(10),

	Constraint PK_Radi_Tokom primary key (JMBG_ZdravRad, ID_RadniKalendar),
	Constraint FK_Lekar_Radi_Tokom foreign key (JMBG_ZdravRad)
	references Projekat.Lekar(JMBG_ZdravRad),
	Constraint FK_RadniKalendar_Radi_Tokom foreign key (ID_RadniKalendar)
	references Projekat.RadniKalendar(ID_RadniKalendar)

)

Create Table Projekat.Pripada_Danu (

	ID_RadniKalendar numeric(10),
	ID_Termin numeric(10),
	RBR_Smena numeric(10)

	Constraint PK_Pripada_Danu primary key (ID_RadniKalendar, RBR_Smena, ID_Termin),
	Constraint FK_RadniKalendar_Pripada_Danu foreign key (ID_RadniKalendar)
	references Projekat.RadniKalendar(ID_RadniKalendar),
	Constraint FK_Termin_Pripada_Danu foreign key (ID_Termin, RBR_Smena)
	references Projekat.Termin (ID_Termin, RBR_Smena)

)

