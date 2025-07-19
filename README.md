# Data Analysis of Bus Service Reliability in Miami
 
 This project conducted an analysis of Miami-Dade Transit’s on-time performance using GTFS static data as well as data acquired from the [Swiftly API](https://github.com/Anran0716/miami-ontime/assets/85720119/46cd392a-0608-4363-b28e-2e7dfc69968c) from October 2022 to March 2023. Then predict the bus delay time based on advanced machine learning models. 

 ## Data Visualization 

[`Miami_bus_SQL.sql`](Miami_bus_SQL.sql): The bus GPS data was first processed with optimized SQL queries in **AWS Redshift**, generating 30+ fact and dimension tables to calculate KPIs, such as delay frequency and route-level reliability.
 
 [`AnalysisReport.pdf`](AnalysisReport.pdf): this provides a detailed report of Miami-Dade Transit on-time performance, which was posted on [Transit Alliance Miami](https://www.transitalliance.miami/mobilityscorecard2023). 

[`Visualization.ipynb`](Visualization.ipynb):  We applied two KPIs for analyzing the service reliability: arrival time differencee and headway difference. 

[`StopAnalysis.ipynb`](StopAnalysis.ipynb): We computed the daily service time for each route and the daily number of transit vehicles serving each transit stop to understand the transit service supply.

![image](https://github.com/Anran0716/miami-ontime/blob/main/flowchart.jpg)

![image](https://github.com/Anran0716/miami-ontime/blob/main/ontime.PNG)

We are now building a real-time reliability dashboard with **PowerBI/JavaScript.** This dashboard will be used for Miami Transit Agency for continuous operational monitoring.

![image](https://github.com/Anran0716/miami-ontime/blob/main/dashboard.jpg)

 ## Statistical Modeling & Machine Learning 

[`Project_Report.pdf`](Project_Report.pdf): This study predicted the bus on-time performance based on several machine learning models, including **decision tree, random forest, support vector machine, and XGBoost**. Through feature engineering and random hyperparameter grid search, the best model can achieve a **20% MAE reduction**.

![image](https://github.com/Anran0716/miami-ontime/blob/main/table.PNG)

[`TRB.pdf`](TRB.pdf): We developed a **space-time regression** model in R to examine the association of service reliability with transit ridership. This paper is presented on the 2024 Transportation Research Conference. 

![image](https://github.com/Anran0716/miami-ontime/blob/main/table2.png)
