IF OBJECT_ID('Projekat.TR_RadniStaz', 'TR') IS NOT NULL
	DROP TRIGGER Projekat.TR_RadniStaz;
GO

SET DATEFORMAT ymd;  
GO

-- Trigger koji prilikom Inserta i Update-a racuna Radni Staz Radnika --

Create Trigger Projekat.TR_RadniStaz
On Projekat.ZdravstveniRadnik
After Insert, Update
AS
Begin

	Declare @radnikJMBG numeric(13);
	set @radnikJMBG = (select JMBG_ZdravRad from inserted);
		
		
	Declare @noviDatumZaposljavanja Date;

	Set @noviDatumZaposljavanja = (select DatumZaposljavanja from inserted);

	IF exists (select * from deleted)
		Begin

		Declare @stariDatumZaposljavanja Date;
		Set @stariDatumZaposljavanja = (select DatumZaposljavanja from deleted);



			IF @stariDatumZaposljavanja != @noviDatumZaposljavanja
			Begin

					
				IF DATEPART(month, GetDate()) < DATEPART(month, @noviDatumZaposljavanja)
					Update Projekat.ZdravstveniRadnik
					Set RadniStaz = DATEDIFF(year, @noviDatumZaposljavanja, GetDate()) - 1
					where JMBG_ZdravRad = @radnikJMBG;

				Else If DATEPART(month, GetDate()) = DATEPART(month, @noviDatumZaposljavanja) and DATEPART(day, GetDate()) < DATEPART(day, @noviDatumZaposljavanja)
						Update Projekat.ZdravstveniRadnik
						Set RadniStaz = DATEDIFF(year, @noviDatumZaposljavanja, GetDate()) - 1
						where JMBG_ZdravRad = @radnikJMBG;

				Else
					Update Projekat.ZdravstveniRadnik
					Set RadniStaz = DATEDIFF(year, @noviDatumZaposljavanja, GetDate())
					where JMBG_ZdravRad = @radnikJMBG;
			End;
			Else
				return;
		End;
	Else
	Begin
		IF DATEPART(month, GetDate()) < DATEPART(month, @noviDatumZaposljavanja)
					Update Projekat.ZdravstveniRadnik
					Set RadniStaz = DATEDIFF(year, @noviDatumZaposljavanja, GetDate()) - 1
					where JMBG_ZdravRad = @radnikJMBG;

				Else If DATEPART(month, GetDate()) = DATEPART(month, @noviDatumZaposljavanja) and DATEPART(day, GetDate()) < DATEPART(day, @noviDatumZaposljavanja)
						Update Projekat.ZdravstveniRadnik
						Set RadniStaz = DATEDIFF(year, @noviDatumZaposljavanja, GetDate()) - 1
						where JMBG_ZdravRad = @radnikJMBG;

				Else
					Update Projekat.ZdravstveniRadnik
					Set RadniStaz = DATEDIFF(year, @noviDatumZaposljavanja, GetDate())
					where JMBG_ZdravRad = @radnikJMBG;
	End;
End;
Go

--Test za TR_RadniStaz
--NAPOMENA: Da bi zaista proverili funckionalnost triggera, moramo kreirati trigger pre insert-ovanja podataka

/*

select ImePrzZdravRad as 'Ime i Prezime', DatumZaposljavanja as 'Datum Zaposljavanja', cast(GetDATE() as DATE) as 'Danasnji Datum', RadniStaz as 'Radni Staz'
from Projekat.ZdravstveniRadnik;

*/

IF OBJECT_ID('Projekat.TR_SumaBodova', 'TR') IS NOT NULL
	DROP TRIGGER Projekat.TR_SumaBodova;
GO

-- Trigger koji prilikom brisanja Seminara dodaje odgovarajuci broj bodova svim radnicima koji su pohadjali seminar --

Create Trigger Projekat.TR_SumaBodova
On Projekat.Seminar
Instead Of Delete
As
Begin

	Declare @ID_Seminar numeric(10),
		@ID_IstorijatSeminara numeric(10),
		@BrojBodova as numeric(2),
		@TemaSeminara as nvarchar(500),
		@NazivSeminara as varchar(50),
		@DatumPocetkaSem as Date,
		@DatumZavrsetkaSem as Date,
		@JMBG_ZdravRad as numeric(13);

	Set @ID_Seminar = (select ID_Seminar from deleted);
	
	Set @BrojBodova = (select BrojBodova from deleted);

	Set @TemaSeminara = (select TemaSeminara from deleted);

	Set @NazivSeminara = (select NazivSeminara from deleted);

	Set @DatumPocetkaSem = (select DatumPocetkaSem from deleted);

	Set @DatumZavrsetkaSem = (select DatumZavrsetkaSem from deleted);

	IF exists (select ID_IstorijatSeminara from Projekat.IstorijatSeminara)
		Set @ID_IstorijatSeminara = (select top 1 ID_IstorijatSeminara from Projekat.IstorijatSeminara) + 1;

	Else
		Set @ID_IstorijatSeminara = 1;
	
	Declare radniciSaSeminara_cursor Cursor For
	Select p.JMBG_ZdravRad
	from Projekat.ZdravstveniRadnik zr
	join Projekat.Pohadja p on(zr.JMBG_ZdravRad = p.JMBG_ZdravRad)
	where p.ID_Seminar = @ID_Seminar;

	Open radniciSaSeminara_cursor;

	Fetch next from radniciSaSeminara_cursor into @JMBG_ZdravRad;

	While @@FETCH_STATUS = 0
	Begin
		
		Print 'Radniku sa JMBG-om: ' +  cast(@JMBG_ZdravRad as varchar) + ' dodajemo ' + cast(@BrojBodova as varchar) + ' bodova.'

		Update Licenca
		Set SumaBodova = SumaBodova + @BrojBodova
		where JMBG_ZdravRad = @JMBG_ZdravRad;
		
		Fetch next from radniciSaSeminara_cursor into @JMBG_ZdravRad;


	End;

	Close radniciSaSeminara_cursor;
	Deallocate radniciSaSeminara_cursor;
	
	INSERT INTO Projekat.IstorijatSeminara (ID_IstorijatSeminara, ID_Seminar, BrojBodova, TemaSeminara, NazivSeminara, DatumPocetkaSem, DatumZavrsetkaSem)
	VALUES (@ID_IstorijatSeminara, @ID_Seminar, @BrojBodova, @TemaSeminara, @NazivSeminara, @DatumPocetkaSem, @DatumZavrsetkaSem);

	Delete from Projekat.Pohadja
	where ID_Seminar = @ID_Seminar;

	Delete from Projekat.Organizuje
	where ID_Seminar = @ID_Seminar;

	Delete from Projekat.Seminar
	where ID_Seminar = @ID_Seminar;

End;
Go

--Test za TR_SumaBodova--

/*

Select ImePrzZdravRad, SumaBodova
from Projekat.ZdravstveniRadnik zr
join Projekat.Licenca l on zr.JMBG_ZdravRad=l.JMBG_ZdravRad
join Projekat.Pohadja p on (zr.JMBG_ZdravRad = p.JMBG_ZdravRad)
where ID_Seminar = 3;

Delete from Projekat.Seminar
where ID_Seminar = 3;

Select ImePrzZdravRad, SumaBodova
from Projekat.ZdravstveniRadnik zr
join Projekat.Licenca l on zr.JMBG_ZdravRad=l.JMBG_ZdravRad
where ImePrzZdravRad = 'Marko Markovic';

select * from Projekat.IstorijatSeminara;

*/