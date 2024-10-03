
--1 Provide a SQL script that initializes the database for the Pet Adoption Platform ”PetPals”. 
create database PetPals;
use PetPals;

--2 Create tables for pets, shelters, donations, adoption events, and participants.  
--3 Define appropriate primary keys, foreign keys, and constraints.

-- Pets Table
CREATE TABLE Pets (
    PetID INT PRIMARY KEY,
    Name VARCHAR(100),
    Age INT,
    Breed VARCHAR(100),
    Type VARCHAR(50),
    AvailableForAdoption BIT
);

INSERT INTO Pets (PetID, Name, Age, Breed, Type, AvailableForAdoption, ShelterId)
VALUES
(1, 'Buddy', 3, 'Golden Retriever', 'Dog', 1, 1),
(2, 'Whiskers', 2, 'Persian', 'Cat', 1, 1),
(3, 'Rocky', 5, 'Bulldog', 'Dog', 0, 2),
(4, 'Mittens', 1, 'Siamese', 'Cat', 1, 3),
(5, 'Coco', 4, 'Labrador Retriever', 'Dog', 1, 3);

-- Shelter Table

CREATE TABLE Shelters (
    ShelterID INT PRIMARY KEY,
    Name VARCHAR(100),
    Location VARCHAR(255)
);

INSERT INTO Shelters (ShelterID, Name, Location)
VALUES
(1, 'Happy Paws Shelter', '123 Pet Lane, Springfield'),
(2, 'Furry Friends Rescue', '456 Animal St, Rivertown'),
(3, 'Safe Haven Shelter', '789 Rescue Rd, Greenfield'),
(4, 'Paws and Claws Sanctuary', '101 Pet Blvd, Lakeside'),
(5, 'Whiskers & Tails Shelter', '202 Catnip Ave, Pawsville');


-- Donations
CREATE TABLE Donations (
    DonationID INT PRIMARY KEY,
    DonorName VARCHAR(100),
    DonationType VARCHAR(50),
    DonationAmount DECIMAL(10, 2),
    DonationItem VARCHAR(100),
    DonationDate DATETIME
);

INSERT INTO Donations (DonationID, DonorName, DonationType, DonationAmount, DonationItem, DonationDate, shelterId)
VALUES
(1, 'Alice Smith', 'Cash', 100.00, NULL, '2024-10-01 10:30:00', 2),
(2, 'John Doe', 'Item', NULL, 'Dog Food', '2024-10-02 14:45:00', 2),
(3, 'Emily Johnson', 'Cash', 50.50, NULL, '2024-10-03 09:15:00', 1),
(4, 'Michael Brown', 'Item', NULL, 'Cat Toys', '2024-10-04 16:20:00', 3),
(5, 'Sarah Wilson', 'Cash', 75.00, NULL, '2024-10-05 11:00:00', 1);


-- AdoptionsEvents
CREATE TABLE AdoptionEvents (
    EventID INT PRIMARY KEY,
    EventName VARCHAR(100),
    EventDate DATETIME,
    Location VARCHAR(255)
);

INSERT INTO AdoptionEvents (EventID, EventName, EventDate, Location)
VALUES
(1, 'Adopt-a-Pet Day', '2024-10-15 10:00:00', 'City Park Community Center'),
(2, 'Paws for a Cause', '2024-11-01 14:00:00', 'Downtown Pavilion'),
(3, 'Fall Adoption Festival', '2024-11-15 12:00:00', 'Animal Rescue Shelter'),
(4, 'Pet Adoption Extravaganza', '2024-12-05 11:00:00', 'City Hall Plaza'),
(5, 'Winter Warm-Up Adoption Event', '2024-12-20 10:00:00', 'Local Pet Store');


-- Participants Table

CREATE TABLE Participants (
    ParticipantID INT PRIMARY KEY,
    ParticipantName VARCHAR(100),
    ParticipantType VARCHAR(50),
    EventID INT,
    FOREIGN KEY (EventID) REFERENCES AdoptionEvents(EventID)
);

INSERT INTO Participants (ParticipantID, ParticipantName, ParticipantType, EventID)
VALUES
(1, 'Happy Paws Shelter', 'Shelter', 1),
(2, 'Furry Friends Adoption', 'Shelter', 2),
(3, 'John Smith', 'Adopter', 1),
(4, 'Emily Johnson', 'Adopter', 3),
(5, 'Animal Rescue League', 'Shelter', 4);

select * from Pets;
select * from Shelters
select * from Participants
select * from Donations
select * from AdoptionEvents


-- 3. Define appropriate primary keys, foreign keys, and constraints

-- (All constraints have been defined above)

-- 5. SQL query to retrieve a list of available pets
SELECT Name, Age, Breed, Type
FROM Pets
WHERE AvailableForAdoption = 1;

-- 6. SQL query to retrieve participant names for a specific event
-- Replace @EventID with the desired event ID
DECLARE @EventID INT = 1; -- Example parameter
SELECT ParticipantName, ParticipantType
FROM Participants
WHERE EventID = @EventID;

-- 7. Create a stored procedure to update shelter information
CREATE PROCEDURE UpdateShelterInfo
    @ShelterID INT,
    @NewName VARCHAR(100),
    @NewLocation VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT * FROM Shelters WHERE ShelterID = @ShelterID)
    BEGIN
        UPDATE Shelters
        SET Name = @NewName,
            Location = @NewLocation
        WHERE ShelterID = @ShelterID;
    END
    ELSE
    BEGIN
        RAISERROR('Invalid Shelter ID', 16, 1);
    END
END;

-- 8. SQL query to calculate total donations for each shelter
-- there was no Shelterid column int the Donations table, 
-- so i've added shelterId to the Donations table to join the shelter and donations table.
SELECT s.Name AS ShelterName, 
       COALESCE(SUM(d.DonationAmount), 0) AS TotalDonationAmount
FROM Shelters s
LEFT JOIN Donations d ON s.ShelterID = d.ShelterId -- Assuming donor name relates to shelter
GROUP BY s.Name;

select * from shelters
select * from Donations

-- 9. SQL query to retrieve pets without an owner
SELECT Name, Age, Breed, Type
FROM Pets
WHERE OwnerID IS NULL; -- Assuming there's an OwnerID column


-- 10. SQL query to retrieve total donation amount by month and year
SELECT FORMAT(DonationDate, 'MMMM yyyy') AS MonthYear,
       SUM(DonationAmount) AS TotalDonationAmount
FROM Donations
GROUP BY FORMAT(DonationDate, 'MMMM yyyy');

-- 11. Retrieve distinct breeds for pets aged between 1-3 years or older than 5 years
SELECT DISTINCT Breed
FROM Pets
WHERE (Age BETWEEN 1 AND 3) OR (Age > 5);

-- 12. Retrieve pets and their respective shelters available for adoption
-- As there was no 'ShelterId' column in the Pets table, i've added 'ShelterId' in the pets table
Alter table Pets Add ShelterId int;

SELECT p.Name AS PetName, s.Name AS ShelterName
FROM Pets p
JOIN Shelters s ON p.ShelterID = s.ShelterID -- Assuming Pets table has ShelterID
WHERE p.AvailableForAdoption = 1;


-- 13. Total participants in events organized by shelters in a specific city
DECLARE @City VARCHAR(100);
set @City = 'Springfield';-- Example city
SELECT COUNT(*) AS TotalParticipants
FROM Participants p
JOIN Shelters s ON p.ParticipantName = s.Name
WHERE s.Location LIKE '%' + @City + '%';

-- 14. Retrieve unique breeds for pets with ages between 1 and 5 years
SELECT DISTINCT Breed
FROM Pets
WHERE Age BETWEEN 1 AND 5;

-- 15. Find pets that have not been adopted
SELECT *
FROM Pets
WHERE AvailableForAdoption = 1; -- Assuming available means not adopted

-- 16. Retrieve names of adopted pets along with adopter's name
-- Assuming there's an Adoption table and User table
SELECT p.Name AS AdoptedPetName, u.Name AS AdopterName
FROM Adoption a
JOIN Pets p ON a.PetID = p.PetID
JOIN Users u ON a.UserID = u.UserID;

-- 17. List shelters along with the count of pets available for adoption
SELECT s.Name AS ShelterName, 
       COUNT(p.PetID) AS AvailablePetsCount
FROM Shelters s
LEFT JOIN Pets p ON s.ShelterID = p.ShelterID
WHERE p.AvailableForAdoption = 1
GROUP BY s.Name;

-- 18. Find pairs of pets from the same shelter that have the same breed
SELECT p1.Name AS Pet1, p2.Name AS Pet2, p1.Breed
FROM Pets p1
JOIN Pets p2 ON p1.ShelterID = p2.ShelterID AND p1.PetID <> p2.PetID
WHERE p1.Breed = p2.Breed;

-- 19. List all combinations of shelters and adoption events
SELECT s.Name AS ShelterName, e.EventName AS EventName
FROM Shelters s
CROSS JOIN AdoptionEvents e;

-- 20. Determine the shelter with the highest number of adopted pets
SELECT TOP 1 s.Name AS ShelterName, 
             COUNT(p.PetID) AS AdoptedPetsCount
FROM Shelters s
JOIN Pets p ON s.ShelterID = p.ShelterID
WHERE p.AvailableForAdoption = 0 -- Assuming not available means adopted
GROUP BY s.Name
ORDER BY AdoptedPetsCount DESC;
