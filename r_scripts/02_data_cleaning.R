#Loading the required libraries
library(readxl)
library(dplyr)
library(skimr)
library(janitor)
library(naniar)
library(stringr)

#Importing the dataset
tool1_crlp <- read_excel("C:/Users/Dell/Desktop/Portfolio Projects/R Projects/1st_ CRLP Project/CRLP Tool 1 CDC Member List Aanalysis/Tool1_CDC_Members List_12324.xlsx")
head(tool1_crlp)

#Fixing the name of the columns
tool1_crlp <- tool1_crlp %>%
  janitor::clean_names()

#Remove the empty rows where are columns are empty
tool1_crlp <- tool1_crlp %>%
  janitor::remove_empty("rows")

#Removing the rows that are completely duplicates
tool1_crlp <- tool1_crlp %>%
  dplyr::distinct()

#Checking the number of rows and columns
nrow(tool1_crlp)
ncol(tool1_crlp)

#Remove extra spaces from the start/end and between of the words
tool1_crlp <- tool1_crlp %>%
  mutate(
    site_visit_id = str_squish(site_visit_id),
    member_province = str_squish(str_to_title(member_province)),
    member_district = str_squish(str_to_title(member_district)),
    member_cdc_name = str_squish(str_to_title(member_cdc_name)),
    member_name = str_squish(str_to_title(member_name))
  )

#Standardize Gender Values
tool1_crlp%>%
  count(member_gender)

tool1_crlp <- tool1_crlp %>%
  mutate(
    member_gender = str_squish(str_to_lower(member_gender)),
    member_gender = case_when(
      member_gender %in% c("m", "male") ~ "Male",
      member_gender %in% c("f", "female") ~ "Female",
      member_gender %in% c("other") ~ "Other",
      TRUE                          ~ "Unknown"
    )
  )

#check a few cleaned columns
tool1_crlp %>%
  select(member_province, member_district, member_cdc_name,member_name, member_gender) %>%
  head(10)

#Cleaning Yes/No columns and status fields
yes_no_cols <- c(
  "do_you_know_this_member",
  "is_selected_currently_a_member_cdc",
  "was_mem_before",
  "is_position_filled_by_someone_else",
  "available_for_interview_for_at_this_site",
  "do_u_know_why_mem_is_not_present_for_interview_today_at_this_site",
  "is_possible_to_trach_the_mem_in_another_location",
  "can_u_give_mem_contact_number"
)

#Apply standard cleaning of all Yes/No columns
tool1_crlp <- tool1_crlp %>%
  mutate(
    across(
      all_of(yes_no_cols),
      ~case_when(
        str_to_lower(str_squish(.x)) %in% c("yes", "y", "1", "true") ~ "Yes",
        str_to_lower(str_squish(.x)) %in% c("no", "n", "0") ~ "No",
        TRUE ~ "Unkown"
      )
    )
  )

data <- lapply(tool1_crlp[yes_no_cols], function(x) table(x, useNA = "ifany"))
head(data)

#Clean and Normalize "Member Status"
tool1_crlp %>%
  count(member_status)

tool1_crlp <- tool1_crlp %>%
  mutate(
    member_status = str_squish(str_to_title(member_status)),
    member_status = case_when(
      member_status %in% c("Existing", "E", "Old", "1") ~ "Existing",
      member_status %in% c("New", "N",  "O") ~ "New",
      TRUE ~ "Unkown"
    )
  )
#Clean and normalize "role_of_member_in_this_cdc_onsite_view”

tool1_crlp %>%
  count(role_of_member_in_this_cdc_onsite_view)

tool1_crlp <- tool1_crlp %>%
  mutate(
    role_of_member_in_this_cdc_onsite_view = str_squish(str_to_title(role_of_member_in_this_cdc_onsite_view))
  )

#Clean“new member” fields
tool1_crlp <- tool1_crlp %>%
  mutate(
    name_of_new_member = str_squish(str_to_title(name_of_new_member)),
    gender_of_new_member = str_squish(str_to_title(gender_of_new_member)),
    position_of_new_member = str_squish(str_to_title(position_of_new_member))
  )

tool1_crlp %>%
  count(gender_of_new_member)

tool1_crlp <- tool1_crlp %>%
  mutate(
    gender_of_new_member = case_when(
    gender_of_new_member %in% c("Male", "M", "m") ~ "Male",
    gender_of_new_member %in% c("Female", "f", "F") ~ "Female",
    TRUE ~ "Unknown"
  )
)

#Clean Updated fields
tool1_crlp <- tool1_crlp %>%
  mutate(
    updated_name = str_squish(str_to_title(updated_name)),
    updated_gender = str_squish(str_to_title(updated_gender)),
    updated_gender = case_when(
      updated_gender %in% c("Male", "male", "M", "m") ~ "Male",
      updated_gender %in% c("Female", "female", "F", "f") ~ "Female",
      TRUE ~ "Unknown"
    )
  )

#Review the cleaned columns
tool1_crlp %>% 
  select(
    member_status,
    role_of_member_in_this_cdc_onsite_view,
    name_of_new_member,
    gender_of_new_member,
    position_of_new_member,
    updated_name,
    updated_gender
  ) %>%
  head(10)

#Clean Phone Numbers
tool1_crlp <- tool1_crlp %>%
  mutate(
    mem_phone_number_clean = mem_phone_number %>%
      str_squish() %>%
      str_replace_all("[^0-9]", "") %>%
      str_trim()
  )
#Add length  validation
tool1_crlp <- tool1_crlp %>%
  mutate(
    phone_length = nchar(mem_phone_number_clean),
    phone_validity = case_when(
      phone_length == 10 ~ "Valid",
      phone_length >= 11 & phone_length <= 12 ~ "International Format",
      phone_length == 0 ~ "Missing",
      TRUE ~ "Invalid"
    )
  )

#Standardize numbers starting with 7 → 07
tool1_crlp <- tool1_crlp %>%
  mutate(
    mem_phone_number_clean = case_when(
      nchar(mem_phone_number_clean) == 9 ~ paste0("0", mem_phone_number_clean),
      TRUE ~ mem_phone_number_clean
    )
  )

#Basic cleaning of CDC members
tool1_crlp <- tool1_crlp %>%
  mutate(
    cdc_code_clean = member_cdc_code %>%
      str_squish() %>%
      str_to_upper()
  )

#Explore CDC Values
tool1_crlp %>%
  count(cdc_code_clean) %>%
  arrange(desc(n)) %>%
  head(20)

#Add format validation (length + numeric/non-numeric)
tool1_crlp <- tool1_crlp %>%
  mutate(
    cdc_code_length = nchar(cdc_code_clean),
    cdc_code_numeric = str_detect(cdc_code_clean, "^[0-9]+$"), 
    cdc_code_status = case_when(
      is.na(cdc_code_clean) | cdc_code_clean == "" ~ "Missing",
      cdc_code_length < 7 ~ "Too short",
      cdc_code_length > 7 ~ "Too long",
      !cdc_code_numeric   ~ "Non-Numeric / Mixed",
      TRUE                ~ "Valid format"
    )
  )

tool1_crlp %>%
  count(cdc_code_status)

#Check for duplicate CDC codes
cdc_dup_summary <- tool1_crlp %>%
  count(cdc_code_clean, member_province, member_district) %>%
  arrange(desc(n))

head(cdc_dup_summary, 20)

#potential inconsistency):
cdc_multi_loc <- tool1_crlp %>%
  group_by(cdc_code_clean) %>%
  summarize(
    n_members = n(),
    n_provinces = n_distinct(member_province),
    n_districts = n_distinct(member_district),
    .groups = "drop"
  ) %>%
  filter(n_provinces > 1 | n_districts >1)
cdc_multi_loc

#Quick view for manual review
tool1_crlp %>%
  select(member_province, member_district, member_cdc_name, cdc_code_clean, cdc_code_status) %>% 
  head(15)

#Consistency Rule 1
tool1_crlp <- tool1_crlp %>%
  mutate(
    member_status = case_when(
      is_selected_currently_a_member_cdc == "No" & member_status == "Active" ~ "Inactive",
      TRUE ~ member_status
    )
  )
#Consistency Rule 2: if someone was NOT a member before, the reason “Why no longer a member” must be NA
tool1_crlp <- tool1_crlp %>%
  mutate(
    why_no_longer_a_mem = case_when(
      was_mem_before == "No" ~ NA_character_,
      TRUE ~ why_no_longer_a_mem
    )
  )

#Consistency Rule 3: If a member WAS interviewed (available = Yes), then “Why not available” should be empty
tool1_crlp <- tool1_crlp %>%
  mutate(
    why_not_available_for_interview_other = case_when(
      available_for_interview_for_at_this_site == "Yes" ~ NA_character_,
      TRUE ~ why_not_available_for_interview_other
    )
  )

#Consistency Rule 4: If the position is NOT filled by someone else, then new member fields should be NA
tool1_crlp <- tool1_crlp %>%
  mutate(
    name_of_new_member = if_else(is_position_filled_by_someone_else == "No", NA_character_, name_of_new_member),
    gender_of_new_member = if_else(is_position_filled_by_someone_else == "No", NA_character_, gender_of_new_member),
    position_of_new_member = if_else(is_position_filled_by_someone_else == "No", NA_character_, position_of_new_member)
  )

#Consistency Rule 5: Updated values should ONLY exist if original was incorrect
tool1_crlp <- tool1_crlp %>%
  mutate(
    updated_name = case_when(
      updated_name == member_name ~ NA_character_,
      TRUE ~ updated_name
    )
  )

#Consistency Rule 6: If updated_gender exists, but matches original, remove it
tool1_crlp <- tool1_crlp %>%
  mutate(
    updated_gender == case_when(
      updated_gender == member_gender ~ NA_character_,
      TRUE ~ updated_gender
    )
  )




#Clean all character columns (blanks → NA, trim spaces)
#Finding all character columns
char_cols <- names(tool1_crlp)[sapply(tool1_crlp, is.character)]

#Clean: trim spaces + convert placeholders to NA
tool1_crlp <- tool1_crlp %>%
  mutate(
    across(
      all_of(char_cols),
      ~ {
        x <- str_squish(.x)
        x[x %in% c("", "-", "_", "N/A", "n/a", "na", "Na", "NA")] <- NA_character_
        x
      }
    )
  )

#Put important columns into factors (nice for analysis)
tool1_crlp <- tool1_crlp %>%
  mutate(
    member_gender = factor(member_gender,
                           levels = c ("Male", "Female", "Other", "Unknown")),
    member_status = factor(member_status,
                           levels = c("Active", "Inactive", "Unknown")),
    phone_validity = factor(phone_validity,
                            levels = c("Valid", "International Format", "Missing", "Invalid"))
  )

#Final Check
skimr::skim(tool1_crlp)
colSums(is.na(tool1_crlp))

#Export the cleaned dataset
getwd()
setwd("C:/Users/Dell/Desktop/Portfolio Projects/R Projects/1st_ CRLP Project/CRLP Tool 1 CDC Member List Aanalysis")

saveRDS(
  tool1_crlp,
  "tool1_crlp_cleaned.rds"
)
