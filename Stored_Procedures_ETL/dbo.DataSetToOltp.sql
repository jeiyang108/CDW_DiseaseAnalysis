USE [COMP8071_Project]
GO
/****** Object:  StoredProcedure [dbo].[DataSetToOltp] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- tore procedure [dbo].[DataSetToOltp] has been created to extract, transform and load data from the NHANES_DataSet to our new OLTP database.
-- This stored procedure can be reused to add more data to our data warehouse when a new survey outcome is available.
-- =============================================
ALTER     PROCEDURE [dbo].[DataSetToOltp]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Reinitializing tables

	DROP TABLE IF EXISTS Diagnosis;
	DROP TABLE IF EXISTS Disease;
	DROP TABLE IF EXISTS DiseaseCategory;
	DROP TABLE IF EXISTS TobaccoConsumption;
	DROP TABLE IF EXISTS AlcoholConsumption;
	
	DROP TABLE IF EXISTS PatientChart;
	DROP TABLE IF EXISTS Patient;
	
	DROP TABLE IF EXISTS Occupation;
	DROP TABLE IF EXISTS MaritalStatus;
	DROP TABLE IF EXISTS EducationLevel;
	DROP TABLE IF EXISTS Race;



	/*
		1. Race
	*/
	CREATE TABLE Race (
		RaceID INT PRIMARY KEY,
		RaceName  VARCHAR(50) NOT NULL
	);

	INSERT INTO Race (RaceId, RaceName) VALUES
	(1, 'Mexican American'),
	(2, 'Other Hispanic'),
	(3, 'Non-Hispanic White'),
	(4, 'Non-Hispanic Black'),
	(5, 'Non-Hispanic Asian'),
	(6, 'Other Race - Including Multi-Racial'),
	(7, 'Missing/Unknown');


	/*
		2. EducationLevel
	*/
	CREATE TABLE EducationLevel (
		EducationLevelId INT PRIMARY KEY,
		EducationLevelName VARCHAR(50) NOT NULL
	);

	INSERT INTO EducationLevel (EducationLevelId, EducationLevelName)
	VALUES 
	(1, 'Less than 9th grade'),
	(2, '9-11th grade (Includes 12th grade with no diploma)'),
	(3, 'High school graduate/GED or equivalent'),
	(4, 'Some college or AA degree'),
	(5, 'College graduate or above'),
	(7, 'Missing/Unknown');

	/*
		3. MaritalStatus
	*/
	CREATE TABLE MaritalStatus (
		MaritalStatusId INT PRIMARY KEY,
		MaritalStatusName VARCHAR(50)
	);

	INSERT INTO MaritalStatus (MaritalStatusId, MaritalStatusName)
	VALUES (1, 'Married'),
		   (2, 'Divorced'),
		   (3, 'Separated'),
		   (4, 'Widowed'),
		   (5, 'Never married'),
		   (6, 'Living with partner'),
		   (7, 'Missing/Unknown');


	/*
		4. Occupation --OCQ260
	*/
	-- Step 1: Create an Occupation table

	CREATE TABLE Occupation (
		OccupationID INT PRIMARY KEY,
		OccupationCategory VARCHAR(100) NOT NULL
	);

	-- Step 2: Insert the occupation categories and codes for the current NHANES survey

	INSERT INTO Occupation (OccupationID, OccupationCategory)
	VALUES 
		(1, 'An employee of a private company, business, or individual for wages, salary, or commission.'),
		(2, 'A federal government employee'),
		(3, 'A state government employee'),
		(4, 'A local government employee'),
		(5, 'Self-employed in own business, professional practice or farm.'),
		(6, 'Working without pay in family business or farm'),
		(77, 'Refused'),
		(99, 'Unknown');


	-------



	/*
		5. Patient
	*/
	CREATE TABLE Patient (
		PatientID INT PRIMARY KEY,
		Age INT,
		Gender INT,
		RaceID INT,
		EducationLevelID INT,
		OccupationID INT,
		MaritalStatusID INT,
		FOREIGN KEY (RaceID) REFERENCES Race(RaceID),
		FOREIGN KEY (EducationLevelID) REFERENCES EducationLevel(EducationLevelID),
		FOREIGN KEY (MaritalStatusID) REFERENCES MaritalStatus(MaritalStatusID),
		FOREIGN KEY (OccupationID) REFERENCES Occupation(OccupationID)
	);


	-- Grab data from SQLite NHANES open dataset
	INSERT INTO COMP8071_Project.dbo.Patient (
		PatientID, Age, Gender, RaceID, EducationLevelID, OccupationID, MaritalStatusID
	)
	SELECT 
		d.["SEQN"] AS PatientID, 
		["RIDAGEYR"] AS Age, 
		["RIAGENDR"] AS Gender, 
		CASE 
			WHEN ["RIDRETH3"] = 1 THEN 1 -- Mexican American
			WHEN ["RIDRETH3"] = 2 THEN 2 -- Other Hispanic
			WHEN ["RIDRETH3"] = 3 THEN 3 -- Non-Hispanic White
			WHEN ["RIDRETH3"] = 4 THEN 4 -- Non-Hispanic Black
			WHEN ["RIDRETH3"] = 6 THEN 5 -- Non-Hispanic Asian
			WHEN ["RIDRETH3"] = 7 THEN 6 -- Other Race - Including Multi-Racial
			ELSE 7
		END AS RaceID,
		CASE 
			WHEN ["DMDEDUC2"] = 1 THEN 1 -- Less than 9th grade
			WHEN ["DMDEDUC2"] = 2 THEN 2 -- 9-11th grade (Includes 12th grade with no diploma)
			WHEN ["DMDEDUC2"] = 3 THEN 3 -- High school graduate/GED or equivalent
			WHEN ["DMDEDUC2"] = 4 THEN 4 -- Some college or AA degree
			WHEN ["DMDEDUC2"] = 5 THEN 5 -- College graduate or above
			ELSE 
				CASE
					WHEN ["DMDEDUC3"] BETWEEN 1 AND 66 THEN 1 -- Minor - Less than 9th grade
					ELSE 7 --Don'know / Refused
				END
		END AS EducationLevelID,
		CASE 
			WHEN ["OCQ260"] = 1 THEN 1 -- 
			WHEN ["OCQ260"] = 2 THEN 2 -- 
			WHEN ["OCQ260"] = 3 THEN 3 -- 
			WHEN ["OCQ260"] = 4 THEN 4 -- 
			WHEN ["OCQ260"] = 5 THEN 5 -- 
			WHEN ["OCQ260"] = 6 THEN 6 -- 
			WHEN ["OCQ260"] = 77 THEN 77 -- 
			WHEN ["OCQ260"] = 99 THEN 99 -- 
			ELSE 99
		END AS OccupationID,
		CASE 
			WHEN ["DMDMARTL"] = 1 THEN 1 -- Married
			WHEN ["DMDMARTL"] = 2 THEN 2 -- Widowed
			WHEN ["DMDMARTL"] = 3 THEN 3 -- Divorced
			WHEN ["DMDMARTL"] = 4 THEN 4 -- Separated
			WHEN ["DMDMARTL"] = 5 THEN 5 -- Never married
			WHEN ["DMDMARTL"] = 6 THEN 6 -- Living with partner
			WHEN ["DMDMARTL"] = 77 THEN 7 -- Refused
			WHEN ["DMDMARTL"] = 99 THEN 7 -- Don't know
			ELSE 7
		END AS MaritalStatusID
	FROM 
		NHANES_DataSet.dbo.demographic d
	JOIN NHANES_DataSet.dbo.questionnaire q ON d.["SEQN"] = q.["SEQN"]
	WHERE 
		d.["SEQN"] IS NOT NULL;



	-----------------


	/*
	-- 6. PatientChart

	-- Grab data from SQLite NHANES open dataset
	*/
	CREATE TABLE PatientChart ( --Health Variables
		ChartID INT PRIMARY KEY,
		PatientID INT,
		BMI DECIMAL(5, 2),
		Weight DECIMAL(5, 2),
		Height DECIMAL(5, 2),
		HeartRate INT,
		SystolicBP  INT, --DIQ300S 
		DiastolicBP INT, --DIQ300D 
		Note VARCHAR(200),
		FOREIGN KEY (PatientID) REFERENCES [COMP8071_Project].dbo.Patient(PatientID)
	);

	INSERT INTO PatientChart (ChartID,PatientID, BMI, Weight, Height, HeartRate, SystolicBP, DiastolicBP, Note)
	SELECT 
		ROW_NUMBER() OVER (ORDER BY ["SEQN"]) AS ChartID,
		["SEQN"] AS PatientID,
		CONVERT(float, ["BMXBMI"]) AS BMI,
		CONVERT(float, ["BMXWT"]) AS Weight,
		CONVERT(float, ["BMXHT"]) AS Height,
		CONVERT(int, ["BPXPLS"]) AS HeartRate,
		CONVERT(int, ["BPXSY1"]) AS SystolicBP,
		CONVERT(int, ["BPXDI1"]) AS DiastolicBP,
		NULL
	  FROM [NHANES_DataSet].[dbo].[examination]


	-----------------


		
	/*
	7. Tobacco & Alcohol
	*/


	CREATE TABLE TobaccoConsumption (
		TobaccoConsumptionID INT PRIMARY KEY,
		PatientID INT,
		ConsumeStatusID INT, --SMQ040: 1 Current - Everyday, 2 Current - Some days, 3 Not at all, 7 Refused, 9 Don't know
		AvgPerDay INT, --["SMQ720"]: Avg # cigarettes/day  (1-90: range of values, 95: 95 cigaretts or more. 777: refused, 999 don't know)
		FOREIGN KEY (PatientID) REFERENCES Patient(PatientID)
	);

	INSERT INTO TobaccoConsumption (TobaccoConsumptionID, PatientID, ConsumeStatusID, AvgPerDay)
	SELECT 
		ROW_NUMBER() OVER (ORDER BY ["SEQN"]) AS TobaccoConsumptionID,
		["SEQN"] AS PatientID,
		CASE 
			WHEN ["SMQ040"] = 1 THEN 1
			WHEN ["SMQ040"] = 2 THEN 2
			WHEN ["SMQ040"] = 3 THEN 3
			WHEN ["SMQ040"] = 7 THEN 7
			WHEN ["SMQ040"] = 9 THEN 9
			ELSE NULL
		END AS ConsumeStatusID,
		CASE 
			WHEN ["SMQ720"] BETWEEN 1 AND 90 THEN ["SMQ720"]
			WHEN ["SMQ720"] = 95 THEN 95
			WHEN ["SMQ720"] = 777 THEN NULL
			WHEN ["SMQ720"] = 999 THEN NULL
			ELSE NULL
		END AS AvgPerDay
	FROM [NHANES_DataSet].[dbo].[questionnaire]


	---------------

	CREATE TABLE AlcoholConsumption (
		AlcoholConsumptionID INT PRIMARY KEY,
		PatientID INT,
		ConsumeStatusID INT, --ALQ101: 1. at least 12 alcohol drinks/year, 2: no
		Frequency DECIMAL(5, 2), ---- ALQ120Q: avg # days per month
		AvgPerDay INT,  -- ALQ130
		FOREIGN KEY (PatientID) REFERENCES Patient(PatientID)
	);
	-- ALQ120Q how often over past 12 months, ALQ120U units (week, month, year)
	/**
	if ALQ120U = WEEK(1)
		ALQ120Q / 7 * 30
	if ALQ120U = MONTH(2)
		ALQ120Q
	if ALQ120U = YEAR(3)
		ALQ120Q / 12
	Else NULL
	(Unless ALQ120Q = 777,999, or empty )
	**/
	INSERT INTO AlcoholConsumption (AlcoholConsumptionID, PatientID, ConsumeStatusID, Frequency, AvgPerDay)
	SELECT 
		ROW_NUMBER() OVER (ORDER BY ["SEQN"]) AS AlcoholConsumptionID,
		["SEQN"] AS PatientID,
		CASE 
			WHEN ["ALQ101"] = 1 THEN 1
			WHEN ["ALQ101"] = 2 THEN 2
			ELSE NULL 
		END AS ConsumeStatusID, --at least 12 alcohols/yr 1. Yes(Drinker) 2.No 7. Refused 9. Don't know
		CASE 
			WHEN ["ALQ120U"] = 1 THEN --Week
				CASE
					WHEN ["ALQ120Q"] BETWEEN 0 AND 365 THEN 
						CAST(["ALQ120Q"] AS FLOAT) / 7 * 30
					ELSE NULL
				END
			WHEN ["ALQ120U"] = 2 THEN --Month
				CASE
					WHEN ["ALQ120Q"] BETWEEN 0 AND 365 THEN 
						["ALQ120Q"]
					ELSE NULL
				END
			WHEN ["ALQ120U"] = 3 THEN--Year
				CASE
					WHEN ["ALQ120Q"] BETWEEN 0 AND 365 THEN 
						CAST(["ALQ120Q"] AS FLOAT) / 12 
					ELSE NULL --# of days / month. Unless ALQ120Q = 777,999, or empty
				END
			ELSE NULL 
		END AS Frequency,
		CASE 
			WHEN ["ALQ130"] BETWEEN 1 AND 25 THEN ["ALQ130"]
			ELSE NULL 
		END AS AvgPerDay
	FROM [NHANES_DataSet].[dbo].[questionnaire];




	-----------
	/*
		8. DiseaseCategory + Disease
	*/
	CREATE TABLE DiseaseCategory (
		CategoryID INT PRIMARY KEY,
		CategoryName VARCHAR(60)
	);
	INSERT INTO DiseaseCategory (CategoryID, CategoryName) VALUES
	(1, 'Cardiovascular diseases'),
	(2, 'Diabetes'),
	(3, 'Cancer'),
	(4, 'Respiratory diseases'),
	(5, 'Kidney diseases'),
	(6, 'Liver diseases'),
	(7, 'Thyroid diseases'),
	(8, 'Neurological diseases'),
	(9, 'Infectious diseases'),
	(10, 'Autoimmune diseases'),
	(11, 'Gastrointestinal diseases'),
	(12, 'Mental health disorders'),
	(13, 'Skin diseases'),
	(14, 'Musculoskeletal disorders'),
	(15, 'Eye diseases'),
	(16, 'Hearing loss'),
	(17, 'Endocrine disorders'),
	(18, 'Blood disorders'),
	(19, 'Allergic disorders'),
	(20, 'Sleep disorders');

	CREATE TABLE Disease (
		DiseaseID INT PRIMARY KEY,
		DiseaseName VARCHAR(60),
		CategoryID INT,
		ICDCode VARCHAR(60),
		FOREIGN KEY (CategoryID) REFERENCES DiseaseCategory(CategoryID)
	);

	INSERT INTO Disease (DiseaseID, DiseaseName, CategoryID, ICDCode) VALUES 
	(1, 'Coronary artery disease', 1, 'I25.1'),
	(2, 'Stroke', 1, 'I63'),
	(3, 'Type 1 diabetes', 2, 'E10'),
	(4, 'Type 2 diabetes', 2, 'E11'),
	(5, 'Gestational diabetes', 2, 'O24.4'),
	(6, 'Breast cancer', 3, 'C50'),
	(7, 'Lung cancer', 3, 'C34'),
	(8, 'Asthma', 4, 'J45'),
	(9, 'COPD', 4, 'J44'),
	(10, 'Chronic kidney disease', 5, 'N18'),
	(11, 'Cirrhosis', 6, 'K74'),
	(12, 'Hypothyroidism', 7, 'E03'),
	(13, 'Parkinson''s disease', 8, 'G20'),
	(14, 'Alzheimer''s disease', 8, 'G30'),
	(15, 'HIV', 9, 'B20'),
	(16, 'Hepatitis B', 9, 'B18.2'),
	(17, 'Hepatitis C', 9, 'B18.2'),
	(18, 'Rheumatoid arthritis', 10, 'M05'),
	(19, 'Lupus', 10, 'M32'),
	(20, 'Crohn''s disease', 11, 'K50'),
	(21, 'Ulcerative colitis', 11, 'K51'),
	(22, 'Depression', 12, 'F32'),
	(23, 'Anxiety', 12, 'F41'),
	(24, 'Eczema', 13, 'L30'),
	(25, 'Psoriasis', 13, 'L40'),
	(26, 'Osteoporosis', 14, 'M81'),
	(27, 'Osteoarthritis', 14, 'M15'),
	(28, 'Cataracts', 15, 'H25'),
	(29, 'Glaucoma', 15, 'H40'),
	(30, 'Hearing loss', 16, 'H90'),
	(31, 'Hypothyroidism', 17, 'E03'),
	(32, 'Hyperthyroidism', 17, 'E05'),
	(33, 'Anemia', 18, 'D64'),
	(34, 'Hemophilia', 18, 'D66'),
	(35, 'Allergic rhinitis', 19, 'J30.1'),
	(36, 'Food allergies', 19, 'T78.0'),
	(37, 'Sleep apnea', 20, 'G47.3'),
	(38, 'Insomnia', 20, 'F51.0'),
	(39, 'Hypertension', 1, 'I10'),
	(40, 'High cholesterol', 1, 'E78');  



	-------------------
	/*
		9. Diagnosis
	*/
	CREATE TABLE Diagnosis (
		DiagnosisID INT IDENTITY(1,1) PRIMARY KEY,
		PatientID INT,
		DiseaseID INT,
		Note VARCHAR(200),
		FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
		FOREIGN KEY (DiseaseID) REFERENCES Disease(DiseaseID)
	);


	--
	INSERT INTO Diagnosis (PatientID, DiseaseID) --NOTE
	SELECT p.PatientID, d.DiseaseID
	FROM Patient p
	JOIN (SELECT DiseaseID FROM Disease WHERE [DiseaseName] = 'Type 1 diabetes') d ON 1=1
	WHERE p.PatientID IN 
		(SELECT DISTINCT ["SEQN"] FROM NHANES_DataSet.dbo.questionnaire q
			WHERE ["DIQ010"] = 1 AND ["DIQ050"] = 1 AND ["DIQ070"] != 1 ) --DIQ070: pills, 050:insulin. Type 1 must take insuline. Currently there's no oral drugs approved to treat type 1.

	INSERT INTO Diagnosis (PatientID, DiseaseID) --NOTE
	SELECT p.PatientID, d.DiseaseID
	FROM Patient p
	JOIN (SELECT DiseaseID FROM Disease WHERE [DiseaseName] = 'Type 2 diabetes') d ON 1=1
	WHERE p.PatientID IN
		(SELECT DISTINCT ["SEQN"] FROM NHANES_DataSet.dbo.questionnaire q
			WHERE ["DIQ010"] = 1 AND (["DIQ050"] != 1 OR ["DIQ070"] = 1)) --DIQ070: pills, 050:insulin,  --628

	INSERT INTO Diagnosis (PatientID, DiseaseID) --NOTE
	SELECT p.PatientID, d.DiseaseID
	FROM Patient p
	JOIN (SELECT DiseaseID FROM Disease WHERE [DiseaseName] = 'Gestational diabetes') d ON 1=1
	WHERE p.PatientID IN
		(SELECT DISTINCT ["SEQN"] FROM NHANES_DataSet.dbo.questionnaire q
			WHERE ["DIQ175S"] = 28) --DIQ070: pills, 050:insulin --30

	-- Hypertension
	INSERT INTO Diagnosis (PatientID, DiseaseID) --NOTE
	SELECT p.PatientID, d.DiseaseID
	FROM Patient p
	JOIN (SELECT DiseaseID FROM Disease WHERE [DiseaseName] = 'Hypertension') d ON 1=1
	WHERE p.PatientID IN 
		(SELECT DISTINCT ["SEQN"] FROM NHANES_DataSet.dbo.questionnaire q
			WHERE ["BPQ020"] = 1)

	-- High Cholesterol
	INSERT INTO Diagnosis (PatientID, DiseaseID) --NOTE
	SELECT p.PatientID, d.DiseaseID
	FROM Patient p
	JOIN (SELECT DiseaseID FROM Disease WHERE [DiseaseName] = 'High cholesterol') d ON 1=1
	WHERE p.PatientID IN 
		(SELECT DISTINCT ["SEQN"] FROM NHANES_DataSet.dbo.questionnaire q
			WHERE ["BPQ080"] = 1)
			
			
		
		
		
		
		
		
		
		


		
END
