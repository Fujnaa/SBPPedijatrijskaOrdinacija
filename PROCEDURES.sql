
--Procedura koja prolazi kroz licence svih radnika, i u zavisnosti od specijalizacije proverava da li imaju odgovarajucu Sumu Bodova za obnavljanje licence, ukoliko da, obnavlja im licencu
--Time sto stavlja DatumObnoveLic na danasnji datum, a DatumIstekaLic na datum 2 godine od danasnjeg datuma

If Object_ID ('Projekat.PR_ObnovaLicenci', 'P') is not null
	Drop Procedure Projekat.PR_ObnovaLicenci;
Go

Create Procedure Projekat.PR_ObnovaLicenci
As
Begin

	Declare licence_cursor Cursor for
	select Specijalizacija, DatumObnove, DatumIstekaLic, SumaBodova, ImePrzZdravRad, l.JMBG_ZdravRad
	from Projekat.Licenca l join Projekat.ZdravstveniRadnik zr on (l.JMBG_ZdravRad = zr.JMBG_ZdravRad);

	Declare @Specijalizacija nvarchar(30),
		@DatumObnove Date,
		@DatumIstekaLic Date,
		@SumaBodova numeric,
		@ImePrzZdravRad nvarchar(40),
		@JMBG_ZdravRad numeric(13),
		@RedniBroj numeric(3);

	Set @RedniBroj = 1;

	Open licence_cursor;

	Fetch next from licence_cursor into @Specijalizacija, @DatumObnove, @DatumIstekaLic, @SumaBodova, @ImePrzZdravRad, @JMBG_ZdravRad;

	While @@FETCH_STATUS = 0
	Begin
		
		IF @SumaBodova < 100
		Begin
			Fetch next from licence_cursor into @Specijalizacija, @DatumObnove, @DatumIstekaLic, @SumaBodova, @ImePrzZdravRad, @JMBG_ZdravRad;
			Continue;
		End;

		Else IF @Specijalizacija = 'Opsta Medicina'
		Begin
			IF @SumaBodova >= 140
			Begin
				Update Licenca
				Set SumaBodova = 0, DatumObnove = GetDate(), DatumIstekaLic = DateAdd(year, 2, GetDate())
				where JMBG_ZdravRad = @JMBG_ZdravRad;

				Print 'Radniku ' + @ImePrzZdravRad + ' je obnovljena licenca';
				Set @RedniBroj = @RedniBroj + 1;
			End;
		End;

		Else If @Specijalizacija = 'Kardiologija'
		Begin
			IF @SumaBodova >= 110
			Begin
				Update Licenca
				Set SumaBodova = 0, DatumObnove = GetDate(), DatumIstekaLic = DateAdd(year, 2, GetDate())
				where JMBG_ZdravRad = @JMBG_ZdravRad;

				Print 'Radniku ' + @ImePrzZdravRad + ' je obnovljena licenca';
				Set @RedniBroj = @RedniBroj + 1;
			End;
		End;

		Else If @Specijalizacija = 'Ortopedija'
		Begin
			IF @SumaBodova >= 100
			Begin
				Update Licenca
				Set SumaBodova = 0, DatumObnove = GetDate(), DatumIstekaLic = DateAdd(year, 2, GetDate())
				where JMBG_ZdravRad = @JMBG_ZdravRad;

				Print 'Radniku ' + @ImePrzZdravRad + ' je obnovljena licenca';
				Set @RedniBroj = @RedniBroj + 1;
			End;
		End;

		Else If @Specijalizacija = 'Dermatologija'
		Begin
			IF @SumaBodova >= 120
			Begin
				Update Licenca
				Set SumaBodova = 0, DatumObnove = GetDate(), DatumIstekaLic = DateAdd(year, 2, GetDate())
				where JMBG_ZdravRad = @JMBG_ZdravRad;

				Print 'Radniku ' + @ImePrzZdravRad + ' je obnovljena licenca';
				Set @RedniBroj = @RedniBroj + 1;
			End;
		End;

		Else If @Specijalizacija = 'Ginekologija'
		Begin
			IF @SumaBodova >= 100
			Begin
				Update Licenca
				Set SumaBodova = 0, DatumObnove = GetDate(), DatumIstekaLic = DateAdd(year, 2, GetDate())
				where JMBG_ZdravRad = @JMBG_ZdravRad;

				Print 'Radniku ' + @ImePrzZdravRad + ' je obnovljena licenca';
				Set @RedniBroj = @RedniBroj + 1;
			End;
		End;

		Fetch next from licence_cursor into @Specijalizacija, @DatumObnove, @DatumIstekaLic, @SumaBodova, @ImePrzZdravRad, @JMBG_ZdravRad;

	End;

	Print 'Ukupno je ' + cast(@RedniBroj - 1 as varchar) + ' radnika obnovilo svoju licencu';

	Close licence_cursor;
	Deallocate licence_cursor;
	
End;
Go

--TEST
/*

select ImePrzZdravRad as 'Ime i Prezime', Specijalizacija, SumaBodova, DatumObnove as 'Datum Obnove', DatumIstekaLic as 'Datum Isteka'
from Projekat.ZdravstveniRadnik zr join Projekat.Licenca l on  zr.JMBG_ZdravRad = l.JMBG_ZdravRad;

EXEC Projekat.PR_ObnovaLicenci

select ImePrzZdravRad as 'Ime i Prezime', Specijalizacija, SumaBodova, DatumObnove as 'Datum Obnove', DatumIstekaLic as 'Datum Isteka'
from Projekat.ZdravstveniRadnik zr join Projekat.Licenca l on  zr.JMBG_ZdravRad = l.JMBG_ZdravRad;

*/

If Object_ID ('Projekat.PR_MenjanjeBodovaSeminara', 'P') is not null
	Drop Procedure Projekat.PR_MenjanjeBodovaSeminara;
Go

--Procedura koja oduzima ili dodaje odredjen broj bodova svim seminarima odredjene institucije, pod uslovom da seminar nije jos zapocet

Create Procedure Projekat.PR_MenjanjeBodovaSeminara
(

	@brojBodova numeric,
	@nazivInstitucije nvarchar(30)

)
As
Begin

	IF(@nazivInstitucije not in (select NazivInstitucije from Projekat.Institucija))
	Begin
		RAISERROR('Uneli ste nepostojecu instituciju', 16, 0);
		Return;
	End;

	Else
	Begin

		Declare @id_Seminar numeric,
		@datumPocetkaSem Date,
		@brojBodovaSeminara numeric;

		Declare seminariInstitucije_cursor Cursor for
			select o.id_seminar, BrojBodova, DatumPocetkaSem
			from Projekat.Seminar s join Projekat.Organizuje o on (s.ID_Seminar = o.ID_Seminar)
			join Projekat.Institucija i on (o.PIB = i.PIB) where NazivInstitucije = @nazivInstitucije;

		Open seminariInstitucije_cursor;

		Fetch next from seminariInstitucije_cursor into @id_seminar, @brojBodovaSeminara, @datumPocetkaSem;

		While @@FETCH_STATUS = 0
		Begin

			If (@datumPocetkaSem > GetDate())
			Begin

				If (@brojBodovaSeminara + @brojBodova <= 0)
					Update Projekat.Seminar
					Set BrojBodova = 0
					where ID_Seminar = @id_Seminar;

				Else
					Update Projekat.Seminar
					Set BrojBodova = BrojBodova + @brojBodova
					where ID_Seminar = @id_Seminar;

			End;

			Fetch next from seminariInstitucije_cursor into @id_seminar, @brojBodovaSeminara, @datumPocetkaSem;

		End;

	End;

	close seminariInstitucije_cursor;
	deallocate seminariInstitucije_cursor;

End;
Go

--TEST
/*

Exec Projekat.PR_MenjanjeBodovaSeminara -3, 'Apoteka Zrenjanin';

select NazivInstitucije as 'Naziv Institucije', NazivSeminara as 'Naziv Seminara', BrojBodova as 'Broj Bodova'
from Projekat.Institucija i join Projekat.Organizuje o on (i.PIB = o.PIB)
join Projekat.Seminar s on (o.ID_Seminar = s.ID_Seminar)
where NazivInstitucije = 'Apoteka Beograd';

Exec Projekat.PR_MenjanjeBodovaSeminara -3, 'Apoteka Beograd';

select NazivInstitucije as 'Naziv Institucije', NazivSeminara as 'Naziv Seminara', BrojBodova as 'Broj Bodova'
from Projekat.Institucija i join Projekat.Organizuje o on (i.PIB = o.PIB)
join Projekat.Seminar s on (o.ID_Seminar = s.ID_Seminar)
where NazivInstitucije = 'Apoteka Beograd';

*/