UNOPS’ AFGHANISTAN COMMUNITY RESILIENCE AND LIVELIHOODS (CRLP) PROJECT

CRLP Member Verification – Data Cleaning Report

PROJECT OVERVIEW

This data-cleaning report supports Activity 1 and Activity 2 of the CRL Project’s Community Member Verification work. The purpose of this exercise is to prepare a fully accurate, standardized, and analysis-ready dataset of CDC members so the Monitoring Agent can effectively verify community structures, assess entry criteria, and ensure that established CDCs are functioning in line with project requirements.

Under the CRL Project, the Monitoring Agent is responsible for validating the status of CDCs, confirming women’s participation, and ensuring community governance structures are active and eligible to operate. To perform these verification activities reliably, the underlying member list must be complete, consistent, and free of errors. This cleaning process strengthens the quality and credibility of downstream physical and financial monitoring by ensuring that member information used for sampling and verification reflects the true situation on ground.

KEY GOALS OF THIS CLEANING

- Prepare a clean and verified CDC member dataset
Remove duplicates, correct inconsistencies, and standardize all fields to support reliable verification activities.
- Ensure data readiness for community-level validation
Clean member names, genders, roles, CDC codes, phone numbers, and membership status to ensure accurate identity tracing during site visits.
- Apply CRL business rules to enforce logical consistency
Align membership status, availability, updated fields, and new-member replacements with project requirements and verification logic.
- Support accurate sampling and monitoring
Provide a high-quality dataset so field teams and the Monitoring Agent can confirm CDC activity, women’s involvement, and beneficiary presence efficiently and correctly.
- Improve reliability of reporting to UNOPS and the World Bank
Produce a standardized dataset that feeds into monitoring dashboards, monthly briefs, and quarterly reports with confidence.

DATA IMPORT & CLEANING
We imported the dataset from Tool1_CDC_Members List_12324, and ran a dedicated R script to perform data cleaning. This script standardizes columns, removes duplicates, and formats text fields. Below is a quick preview of the cleaning steps to ensure everything is ready for analysis.

CLEANING STEPS
•	Column Name Standardization: We used the janitor::clean_names() function to ensure all column names were in a consistent format.

•	Removing Empty Rows and Duplicates: We removed any rows that were entirely empty and eliminated duplicate records to clean up the dataset.

•	Text Field Cleaning: We standardized text fields by trimming extra spaces and converting names and locations to title case for consistency.

•	 Standardizing Gender Values: We converted all gender fields to a consistent set of categories (Male, Female, Other, Unknown) using case_when().

•	Yes/No Column Cleaning: We standardized yes/no columns to a uniform format, converting various inputs like "y," "yes," or "1" into a consistent "Yes" or "No."

•	 Phone Number Validation: We cleaned and validated phone numbers, ensuring correct length and format, and classified them as valid or invalid.

•	 Consistency Rules: We applied several consistency rules, such as ensuring that if a member was available for an interview, the “Why not available” field was cleared.

CONCLUSION
In conclusion, this report documented the steps taken to clean and standardize the CDC member dataset. By removing duplicates, standardizing fields, and ensuring consistency, we have prepared a reliable dataset ready for analysis. This cleaned data will support more accurate reporting and decision-making.

