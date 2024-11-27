# SBPPedijatrijskaOrdinacija
A project in the segment of Pediatrics which enables users control over pediatric licenses of workers and manipulation of reserved appointments.
The project was entirely implemented using MSSQL Server, and ofcourse the SQL language.

In short, there are multiple .sql files divided by their content.

**DDL.sql** for DATA DEFINITION, as in to create the needed tables with requested constraints.

**INSERT.sql** for storing test data, in order to test the realization of the project.

**SELECT.sql** for a few select queries that could be used in the Pediatric Information System.
- The first select query lists the average work experience and all employees with work experience below the average, sorted in descending order.
- The second select query lists all employees with a salary below the average salary, a valid license, and a score sum greater than 0.
- The third select query lists all doctors whose license expires this year and who attended the seminar with the highest points from the institution 'Bolnica Novi Sad'.
- The fourth select query lists all doctors, their contact information, and clinic numbers specializing in 'Orthopedics' who have an available appointment in the first shift on '2023-09-01'.
- The fifth select query lists all institutions that organize seminars, as well as all employees with the highest salary in their specialization attending the seminar, sorted by the seminar's date.

**FUNCTIONS.sql** for two functions and appropriate tests.
- One function which for a certain specialization of a pediatric worker returns the minimum, average and maximum wage
  contained in the information system.
- Another function which for a specified date, shift and number of days returns all the appointments and doctors that reserved those appointments on the specified date and for the next X specified number of days.

**PROCEDURES.sql** which contains procedures that could help the pediatric information system in daily work. Each procedure is accompanied with a test query.
- A procedure that goes through all employees' licenses and, depending on the specialization, checks if they have the required points sum to renew the license. If yes, it renews the license by setting the RenewalDate to today's date and the LicenseExpiryDate to the date two years from today.
- A procedure that adds or deducts a specified number of points from all seminars of a specific institution, provided the seminar has not yet started.

**TRIGGER.sql** with triggers that serve as a good addition to the organization. Each trigger has it's appropriate test query.
- A trigger that calculates the work experience of an employee during INSERT and UPDATE.
- A trigger that, upon the deletion of a seminar, adds the corresponding points to all employees who attended the seminar.

An ER diagram of the pediatrics Information System:
![PedijatrijskaOrdinacija_ER_Ver6](https://github.com/user-attachments/assets/a0f2b26e-e61b-42c2-a1f5-b6acb84a1d79)


An ER diagram of the subscheme of the entire pediatrics system that this project is based on:
![PodsemaProcesObnavljanjeLicence](https://github.com/user-attachments/assets/14cbc85b-fe1b-4576-b5ef-8fd59fb7e7c4)


*A thorough explanation of the project can be read in the project documentation within the repository.*
