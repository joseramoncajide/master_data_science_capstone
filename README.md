XXX project for the Kschool Master in Data Science
===================

Introduction

## Objetive ##
The goal of the Capstone Project is to answer this business questions:

 - List item
 - Otro
## About the methodology ##

### Data acquisition

Sample data
####  Variable and data type identification
#### Variable transformation

### Exploratory data analysis (EDA)

#### Missing values and outliers
**Missing values**

**Outlier detection**
No outliers were detected during the EDA phase where most relevant variables were the most important variables were visualized. We found some big amount operations but no to be classified as extreme values that could affect the result of the analysis. 

### Feature engineering
New variables where generated based on existing ones in order to derive relevant information for the analysis.
This was a reiterative process consisting in:

 1. Create a set of new variables or predictors that could help to test our hypothesis
 2. Diagnose the predictors for high correlation or zero and near-zero values
 3. Run the analysis
 4. Remove uninformative predictors from the dataset
 5. Data transformation: leaving variances unequal is equivalent to putting more weight on variables with smaller variance, so clusters will tend to be separated along variables with greater variance. To avoid this all variables were normalized around the mean.

> **Files**:
> [exploratory_data_analysis.Rmd](www.es.es "sdsd"): a R Markdown document
> [data_preparation.R](www.es.es "sdsd"): a R script that reads the data source file, performs data cleaning, wrangling and the feature engineering process. As a result a CSV file is created and ready to be analyzed.
> [data_preparation.ipnyb](www.es.es "sdsd"): a Jupyter Notebook that explains the data preparation process using R 

### Modelling

This is the core activity of the data science project. In order to get insight from the data a Machine Learning algorithm was applied to the selected variables.

> **FIles**:
> [clustering.ipnyb](www.es.es "sdsd"): a Jupyter Notebook that perform data modeling phase over the sample dataset using Python and Spark
> [clustering.py](www.es.es "sdsd"): the final application created to run the K-means machine learning algorithm over the full dataset.
> > [data_merging.R](www.es.es "sdsd"): a R script that joins clustering results with the original dataset and derive new datasets needed to perform the data analysis phase.

### Data analysis

## About the technology ##
**Programming Languages**

**Libraries**

**Hardware and Resources**




## How to re-run this analysis ##

    
    
    
