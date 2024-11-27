
--Izlistati sredju vrednost radnog staza i sve radnike sa radnim stazom manjim od srednje vrednosti, sortirano u opadajucem redosledu--

Select ImePrzZdravRad as 'Ime i Prezime radnika', RadniStaz
from Projekat.ZdravstveniRadnik
group by ImePrzZdravRad, RadniStaz
having RadniStaz < (select avg(RadniStaz) from Projekat.ZdravstveniRadnik)
order by RadniStaz asc;

--Provera srednje vrednosti radnog staza
select avg(RadniStaz) from Projekat.ZdravstveniRadnik;

--Izlistati sve radnike sa platom manjom od srednje vrednosti plate, vazecom licencom i sumom bodova vecom od 0 

select zr.JMBG_ZdravRad as 'JMBG', ImePrzZdravRad as 'Ime i Prezime', DatumIstekaLic as 'Datum Isteka Licence', Plata, SumaBodova as 'Suma Bodova'
from Projekat.ZdravstveniRadnik zr join Projekat.Licenca l on (zr.JMBG_ZdravRad = l.JMBG_ZdravRad)
where DatumIstekaLic > GetDate() and SumaBodova > 0
group by Plata, zr.JMBG_ZdravRad, ImePrzZdravRad, SumaBodova, DatumIstekaLic
having Plata < (select avg(Plata) from Projekat.ZdravstveniRadnik);

--Provera srednje vrednosti plata
select avg(Plata) from Projekat.ZdravstveniRadnik;

--Izlistati sve lekare cija licenca istice ove godine, a pohadjali su seminar koji nosi najvise bodova od institucije 'Bolnica Novi Sad'--

select zr.JMBG_ZdravRad as 'JMBG', ImePrzZdravRad as 'Ime i Prezime', KontaktZdravRad as 'Kontakt', DatumIstekaLic as 'Datum Isteka Licence', SumaBodova as 'Bodovi',  NazivInstitucije as 'Naziv Institucije', BrojBodova as 'Seminar Bodovi'
from Projekat.ZdravstveniRadnik zr join Projekat.Licenca l on (zr.JMBG_ZdravRad = l.JMBG_ZdravRad)
join Projekat.Pohadja p on (zr.JMBG_ZdravRad = p.JMBG_ZdravRad) join Projekat.Seminar s on (p.ID_Seminar = s.ID_Seminar) join Projekat.Organizuje o on (s.ID_Seminar = o.ID_Seminar)
join Projekat.Institucija i on (o.PIB = i.PIB)
where Year(DatumIstekaLic) = Year(GETDATE()) and NazivInstitucije = 'Bolnica Novi Sad' and BrojBodova = (select max(BrojBodova) from Projekat.Seminar where NazivInstitucije = 'Bolnica Novi Sad');

--Izlistati sve lekare i njihov kontakt i broj ordinacije sa specijalizacijom 'Ortopedija' koji imaju slobodan termin u prvoj smeni datuma '2023-09-01'--

Select ImePrzZdravRad as 'Ime i Prezime', KontaktZdravRad as 'Kontakt', BrojOrdinacije as 'Broj Ordinacije', Specijalizacija, cast(max(VremePocetka) as varchar) + ' - ' + cast(max(VremeZavrsetka) as varchar) as 'Poslednji Zakazani Termin'
from Projekat.ZdravstveniRadnik zr join Projekat.Licenca lic on (zr.JMBG_ZdravRad=lic.JMBG_ZdravRad) join Projekat.Lekar l on (zr.JMBG_ZdravRad = l.JMBG_ZdravRad) join Projekat.Radi_Tokom rt on (l.JMBG_ZdravRad = rt.JMBG_ZdravRad)
join Projekat.RadniKalendar rk on (rt.ID_RadniKalendar = rk.ID_RadniKalendar) join Projekat.Pripada_Danu pd on (rk.ID_RadniKalendar = pd.ID_RadniKalendar)
join Projekat.Termin t on (pd.ID_Termin = t.ID_Termin)
where Specijalizacija= 'Kardiologija' and t.RBR_Smena = 1 and Datum = '2023-09-01'
group by ImePrzZdravRad, KontaktZdravRad, BrojOrdinacije, Specijalizacija
having max(VremeZavrsetka) < ((select VremeDo from Projekat.Smena where RBR_Smena=1));

--Izlistati sve institucije koje organizuju seminare, kao i sve radnike sa najvecom platom u svojoj specijalizaciji koji pohadjaju taj seminar, sortirano po datumu odrzavanja seminara--

Select i.PIB, NazivInstitucije as 'Naziv Institucije', NazivSeminara as 'Naziv Seminara', cast(DatumPocetkaSem as varchar) + ' - ' + cast(DatumZavrsetkaSem as varchar) as 'Datum Odrzavanja Seminara', ImePrzZdravRad as 'Ime i Prezime Radnika', l.Specijalizacija, Plata
from Projekat.Institucija i join Projekat.Organizuje o on (i.PIB = o.PIB)
join Projekat.Seminar s on (o.ID_Seminar = s.ID_Seminar)
join Projekat.Pohadja p on (s.ID_Seminar=p.ID_Seminar)
join Projekat.ZdravstveniRadnik zr on (p.JMBG_ZdravRad = zr.JMBG_ZdravRad)
join Projekat.Licenca l on (zr.JMBG_ZdravRad = l.JMBG_ZdravRad)
join (select max(Plata) maksi, Specijalizacija from Projekat.ZdravstveniRadnik zr join Projekat.Licenca l on (zr.JMBG_ZdravRad = l.JMBG_ZdravRad) group by Specijalizacija) speci on (l.Specijalizacija = speci.Specijalizacija)
where zr.Plata = speci.maksi
order by DatumPocetkaSem desc;

--Provera najvecih plata u specijalizacijama
select  max(Plata), Specijalizacija from Projekat.ZdravstveniRadnik zr join Projekat.Licenca l on (zr.JMBG_ZdravRad = l.JMBG_ZdravRad)
group by Specijalizacija

