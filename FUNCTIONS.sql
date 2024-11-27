--Funkcija koja za odredjenu specijalizaciju vraca minimalnu, srednju i maksimalnu platu radnika--

If Object_ID ('Projekat.FN_PlatePoSpecijalizaciji', 'TF') is not null
	Drop Function Projekat.FN_PlatePoSpecijalizaciji;
Go

Create Function Projekat.FN_PlatePoSpecijalizaciji
(
	@specijalizacija as nvarchar(30)
)
Returns @returntable Table
(
	minPlata numeric,
	avgPlata numeric,
	maxPlata numeric
)
AS
Begin

	DECLARE @error INT

	IF(@specijalizacija not in (select Specijalizacija from Projekat.Licenca))
	Begin
		SELECT @error = 'Uneli ste nepostojecu specijalizaciju';
		Return;
	End;
	
	Insert @returntable
		Select min(Plata), avg(Plata), max(Plata)
		from Projekat.ZdravstveniRadnik zr join Projekat.Licenca l on (zr.JMBG_ZdravRad = l.JMBG_ZdravRad)
		where Specijalizacija = @specijalizacija;

	Return;

End;
Go

--Testovi


/*select * from Projekat.FN_PlatePoSpecijalizaciji('Ortopedija');
Go

select ImePrzZdravRad as 'Ime i prezime', Specijalizacija, Plata from Projekat.ZdravstveniRadnik zr join Projekat.Licenca l on (zr.JMBG_ZdravRad = l.JMBG_ZdravRad)
where Specijalizacija = 'Ortopedija'

select * from Projekat.FN_PlatePoSpecijalizaciji('Opšta medicina');
Go

select ImePrzZdravRad as 'Ime i prezime', Specijalizacija, Plata from Projekat.ZdravstveniRadnik zr join Projekat.Licenca l on (zr.JMBG_ZdravRad = l.JMBG_ZdravRad)
where Specijalizacija = 'Opšta Medicina'

select * from Projekat.FN_PlatePoSpecijalizaciji('aaa');
Go*/

--Za prosledjenu smenu i datum vratiti sve zakazane termine za navedeni broj dana i lekare koji su zakazali te termine--

If Object_ID ('Projekat.FN_TerminiUSmeni', 'TF') is not null
	Drop Function Projekat.FN_TerminiUSmeni;
Go

Create Function Projekat.FN_TerminiUSmeni
(
	@rbr_Smena as numeric(1),
	@datum as Date,
	@brojDana as int
)
Returns @returnTable Table
(

	ID_Termin numeric,
	RBR_Smena numeric,
	VremePocetka Time,
	VremeZavrsetka Time,
	Datum Date,
	ImePrez varchar(50)

)
As
Begin

	DECLARE @error INT

	IF(@rbr_Smena not in (select RBR_Smena from Projekat.Smena))
	Begin
		SELECT @error = 'Uneli ste nepostojecu smenu';
		Return;
	End;
	
	While @brojDana > 0
	Begin

		Insert @returnTable
		Select t.ID_Termin, t.RBR_Smena, VremePocetka, VremeZavrsetka, Datum, ImePrzZdravRad
		from Projekat.Termin t join Projekat.Pripada_Danu pd on (t.ID_Termin = pd.ID_Termin)
		join Projekat.RadniKalendar rk on (pd.ID_RadniKalendar = rk.ID_RadniKalendar)
		join Radi_Tokom rt on (rk.ID_RadniKalendar = rt.ID_RadniKalendar)
		join Lekar l on (rt.JMBG_ZdravRad = l.JMBG_ZdravRad)
		join ZdravstveniRadnik zr on (l.JMBG_ZdravRad = zr.JMBG_ZdravRad)
		where t.RBR_Smena = @rbr_Smena and Datum = DateAdd(day, @brojDana - 1, @datum);

		set @brojDana = @brojDana - 1;

	End;

	Return;
End;
Go

/*Test

Select * from Projekat.FN_TerminiUSmeni(5, '2023-09-01', 3);
Go

Select * from Projekat.FN_TerminiUSmeni(1, '2023-09-01', 3);
Go

Select * from Projekat.FN_TerminiUSmeni(1, '2023-09-01', 1);
Go
*/