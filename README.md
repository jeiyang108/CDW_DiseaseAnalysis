# Clinical Data Warehouse project - Disease Registry based on CDC NHNAES open dataset (COMP8071)

For this project, I have created a new OLAP schema for a Clinical Data Warehouse, which can be used by health professionals in the medical decision making process and improve patient outcomes.
This project suggests the process of building a Clinical Data Warehouse based on the NHANES(National Health and Nutrition Examination Survey) data provided by CDC(Centers for Disease Control and Prevention). 
The application demonstrates possible use of the data warehouse with a few examples of analysis we can do using the OLAP database created based on the NHANES dataset.


# Dataset (National Health and Nutrition Examination Survey conducted by CDC between 2013-2014)
CDC performs an annual survey called NHANES(National Health and Nutrition Examination Survey), which is designed to assess the health and nutritional status of adults and children in the United States. The survey is unique in that it combines interviews, physical examinations, and administers tests of physical activity and fitness that include children and adolescents.
The NHANES dataset is open to the public and it contains a lot of demographic data as well as health factors. Most of private information (ie. Date of Birth, Name) are excluded but there is still quite a lot of valuable data that holds potential for various statistical studies in the medical field.

# ETL Process
The NHANES dataset consists of 5 tables; demographic, diet, examination, labs and questionnaire. The tables include 1816 columns in total, and each column name can be searched via NHANES Variable List web page.

(1) Dataset to OLTP:

For example, “RIDRETH3” is a column in the ‘demographic’ table of the NHANES(2013-2014) dataset. The CDC provides documentations and web pages that include the definition of the column ‘RIDRETH3’ and its possible values.
And based on this analysis, we can define our new OLTP schema and populate the tables. Store procedure [dbo].[DataSetToOltp] has been created to extract, transform and load data from the NHANES_DataSet to our new OLTP database. This stored procedure can be reused to add more data to our data warehouse when a new survey outcome is available.

(2) OLTP to OLAP:

For this project, 7 dimensions and a fact table were created to analyze the associations between common chronic diseases and demographic/health factors.
* AgeRangeDIm
* RaceDim
* EducationLevelDim
* DiseaseDim
* TobaccoConsDim
* AlcoholConsDim
* BMIRangeDim
* DiagnosisFacts

By using this OLAP schema, we can generate reports that compare the number of patients(diagnosed survey participants) of each race, education level, BMI range, etc.
Store procedure [dbo].[OltpToOlap] has been created to extract, transform and load data from the OLTP database to the OLAP database for this particular analysis.


# Used technologies/tools: 
Azure, Microsoft SQL Server, T-SQL, OLAP, Stored Procedures, Visual Studio, Analysis Services, ASP.NET Core, ODBC, Chart.js


# References
* NHANES Variable List (used as a dictionary to interpret column names and possible values) https://wwwn.cdc.gov/nchs/nhanes/search/DataPage.aspx?Cycle=2013-2014 
* NHANES Dataset (2013-2014) https://www.kaggle.com/datasets/knpwarrior/selected-datasets-from-nhanes-20132014
* CDC Application: https://gis.cdc.gov/grasp/diabetes/diabetesatlas-surveillance.html
* Article: https://deliverypdf.ssrn.com/delivery.php?ID=656004084115000031071126013022000071023008077017062005096023077096116104106003078000024056016012056112062067112076104116008104105083064042055007018083073026126085003010021000093021125114086000066078116031031094078031028027065031106087114022097117083074&EXT=pdf&INDEX=TRUE
