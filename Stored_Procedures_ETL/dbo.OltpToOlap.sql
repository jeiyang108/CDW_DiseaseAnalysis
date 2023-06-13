USE [COMP8071_Project]
GO
/****** Object:  StoredProcedure [dbo].[OltpToOlap_DiagnosisCount]    Script Date: 2023-06-13 4:08:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER     PROCEDURE [dbo].[OltpToOlap_DiagnosisCount]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Reinitializing tables
	DROP TABLE IF EXISTS DiagnosisFacts;
	DROP TABLE IF EXISTS PatientDim;
	DROP TABLE IF EXISTS BMIRangeDim;
	DROP TABLE IF EXISTS EducationLevelDim;
	DROP TABLE IF EXISTS AgeRangeDim;
	DROP TABLE IF EXISTS DiseaseDim;
	DROP TABLE IF EXISTS RaceDim;
	DROP TABLE IF EXISTS AlcoholConsDim;
	DROP TABLE IF EXISTS TobaccoConsDim;

	CREATE TABLE TobaccoConsDim (
		TobaccoConsID INT PRIMARY KEY,
		TobaccoConsumption VARCHAR(50)
	);
	CREATE TABLE AlcoholConsDim (
		AlcoholConsID INT PRIMARY KEY,
		AlcoholConsumption VARCHAR(50)
	);
	CREATE TABLE RaceDim (
		RaceID INT PRIMARY KEY,
		Race VARCHAR(50)
	);
	CREATE TABLE DiseaseDim (
		DiseaseID INT PRIMARY KEY,
		Disease VARCHAR(50)
	);
	CREATE TABLE AgeRangeDim (
		AgeRangeID INT PRIMARY KEY,
		AgeRange VARCHAR(50)
	);
	CREATE TABLE EducationLevelDim (
		EduLevelID INT  PRIMARY KEY,
		EducationLevel VARCHAR(50)
	);
	CREATE TABLE BMIRangeDim (
		BMIRangeID INT PRIMARY KEY,
		Label VARCHAR(20),
		BMIRange VARCHAR(50)
	);

	CREATE TABLE DiagnosisFacts (
		RaceID INT,
		DiseaseID INT,
		AgeRangeID INT,
		BMIRangeID INT,
		AlcoholConsID INT,
		TobaccoConsID INT,
		EduLevelID INT,
		NumOfPatients INT,
		CONSTRAINT fk_disease FOREIGN KEY (DiseaseID) REFERENCES DiseaseDim(DiseaseID),
		CONSTRAINT fk_age_range FOREIGN KEY (AgeRangeID) REFERENCES AgeRangeDim(AgeRangeID),
		CONSTRAINT fk_tobacco_cons FOREIGN KEY (TobaccoConsID) REFERENCES TobaccoConsDim(TobaccoConsID),
		CONSTRAINT fk_alcohol_cons FOREIGN KEY (AlcoholConsID) REFERENCES AlcoholConsDim(AlcoholConsID),
		CONSTRAINT fk_race FOREIGN KEY (RaceID) REFERENCES RaceDim(RaceID),
		CONSTRAINT fk_edu_level FOREIGN KEY (EduLevelID) REFERENCES EducationLevelDim(EduLevelID),
		CONSTRAINT fk_bmi_range FOREIGN KEY (BMIRangeID) REFERENCES BMIRangeDim(BMIRangeID)
	);

	INSERT INTO TobaccoConsDim VALUES
		(1, 'Not at all'),
		(2, '1-10 cigarrets/day'),
		(3, '11-20 cigarrets/day'),
		(4, '21-50 cigarrets/day'),
		(5, '51-90 cigarrets/day'),
		(6, 'More than 90 cigarrets/day'),
		(7, 'Refused/unknown');

	INSERT INTO AlcoholConsDim VALUES
		(1, 'Never or rarely (less than 12 times/year)'),
		(2, 'Once a month'),
		(3, '2-3 times/month'),
		(4, 'Once a week'),
		(5, '2-5 times/week'),
		(6, 'Almost everyday'),
		(7, 'Refused/unknown');

	INSERT INTO RaceDim
	SELECT RaceID, RaceName from Race;

	INSERT INTO DiseaseDim
	SELECT DiseaseID, DiseaseName FROM Disease;

	INSERT INTO AgeRangeDim VALUES
		(1, '0-17 years old'),
		(2, '18-30 years old'),
		(3, '31-39 years old'),
		(4, '40-54 years old'),
		(5, '55-70 years old'),
		(6, 'older than 70'),
		(99, 'Unknown');

	INSERT INTO EducationLevelDim
	SELECT EducationLevelId, EducationLevelName FROM EducationLevel;

	INSERT INTO BMIRangeDim VALUES
		(1, 'Underweight', 'Less than 18.5'),
		(2, 'Healthy weight', '18.5-24.9'),
		(3, 'Overweight', '25-29.9'),
		(4, 'Obese', '30.0 or higher'),
		(99, 'Unknown', 'Unknown / Missing');



	-- ETL from OLTP db from OLAP (for Diagnosis facts table).
	INSERT INTO DiagnosisFacts (RaceID, DiseaseID, AgeRangeID, BMIRangeID, AlcoholConsID, TobaccoConsID, EduLevelID, NumOfPatients)
	SELECT t.RaceID, t.DiseaseID, t.AgeRangeID, t.BMIRangeID, t.AlcoholConsID, t.TobaccoConsID, t.EduLevelID, COUNT(DISTINCT t.DiagnosisID) AS NumOfPatients
		FROM (
			SELECT
				p.RaceID,
				d.DiseaseID,
				d.DiagnosisID,
				CASE
					WHEN p.Age < 18 THEN 1
					WHEN p.Age BETWEEN 18 AND 30 THEN 2
					WHEN p.Age BETWEEN 31 AND 39 THEN 3
					WHEN p.Age BETWEEN 40 AND 54 THEN 4
					WHEN p.Age BETWEEN 55 AND 70 THEN 5
					WHEN p.Age > 70 THEN 6
					ELSE 99
				END AS AgeRangeID,
				CASE
					WHEN pc.BMI BETWEEN 0.1 AND 18.4 THEN 1
					WHEN pc.BMI BETWEEN 18.5 AND 24.9 THEN 2
					WHEN pc.BMI BETWEEN 25 AND 29.9 THEN 3
					WHEN pc.BMI >= 30 THEN 4
					ELSE 99 --BMI is 0 (not calculated)
				END AS BMIRangeID,
				CASE
					WHEN ac.ConsumeStatusID = 2 OR ac.Frequency = 0 THEN 1 --Less than 12times/yr
					WHEN ac.Frequency BETWEEN 1 AND 1.99 THEN 2 --Once a month
					WHEN ac.Frequency BETWEEN 2 AND 3.99 THEN 3 --2-3 times/month
					WHEN ac.Frequency BETWEEN 4 AND 7.99 THEN 4 --Once a week
					WHEN ac.Frequency BETWEEN 8 AND 20 THEN 5 --2-5 times/wk
					WHEN ac.Frequency > 20 THEN 6 --Almost everyday
					ELSE 7 --Unknown
				END AS AlcoholConsID,
				CASE
					WHEN tc.ConsumeStatusID = 3 THEN 1 -- Not at all
					WHEN tc.AvgPerDay BETWEEN 1 AND 10 THEN 2 -- 1-10 cigarrets/day
					WHEN tc.AvgPerDay BETWEEN 11 AND 20 THEN 3-- 11-20
					WHEN tc.AvgPerDay BETWEEN 21 AND 50 THEN 4 -- 21-50
					WHEN tc.AvgPerDay BETWEEN 51 AND 90 THEN 5 -- 51-90
					WHEN tc.AvgPerDay = 95 THEN 6 -- More than 90
					ELSE 7 --Unknown
				END AS TobaccoConsID,
				p.EducationLevelID AS EduLevelID
			FROM Patient p
			JOIN PatientChart pc ON p.PatientID = pc.PatientID
			JOIN AlcoholConsumption ac ON ac.PatientID = p.PatientID
			JOIN TobaccoConsumption tc ON tc.PatientID = p.PatientID
			JOIN Diagnosis d ON d.PatientID = p.PatientID
		) as t
		GROUP BY t.RaceID, t.DiseaseID, t.AgeRangeID, t.BMIRangeID, t.AlcoholConsID, t.TobaccoConsID, t.EduLevelID;


		
END
