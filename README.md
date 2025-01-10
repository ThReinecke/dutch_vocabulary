# Daily Vocabulary Email Automation

## Overview
This project automates the daily delivery of an email containing three words (language and difficulty of your choice), their translations, and example sentences.

**Example email for Dutch, C1 level, with English translations**
![Screenshot of Dutch email](/images/email.png)

**Example email for French, B2 level, with German translations**
![Screenshot of French email](/images/frenchEmail.png)

This project leverages ChatGPT as the vocabulary source. Therefore, the quality of words, translations, and examples for each language depends on ChatGPT's familiarity and knowledge of the desired language.


## Motivation
I created this project because I couldn't find a suitable app to improve my C1-level Dutch vocabulary. I discovered that ChatGPT provides good word suggestions and decided to automate the process. Moreover, I check emails more consistently than apps, which makes this method more effective for learning. Of course, this doesn't replace language courses or sophisticated language apps, but it's a good way to stay engaged with a language.


## Simplified Architecture
A CloudWatch Event Rule triggers a Lambda daily. The Lambda retrieves all previously sent words from DynamoDB. It then retrieves three new words from ChatGPT, stores them in DynamoDB, and sends them to SES. SES delivers them to the end user's email.

![Picture of architecture](/images/architecture.jpg)


## Setup

### Prerequisites
To deploy this project, ensure the following tools and configurations are in place:

1. **Tools Installed:**
   - Python (Tested with Python 3.12.8)
   - pip (Tested with pip 24.3.1)
   - Terraform (Tested with Terraform 1.10.3)
   - AWS CLI (Tested with 2.15.58)

   (If you would like to contribute, you'll also need to install the packages in the `requirements.txt` file and tflint: https://github.com/terraform-linters/tflint)

2. **Permissions:**
   Your AWS CLI user must have the appropriate permissions to deploy the resources. Refer to the Terraform files and apply the principle of least privilege.

3. **Amazon SES Verified Email:**
   You need a verified email address in Amazon SES. This email must match the one used in the project.
   Reference: [Verifying Email Addresses in Amazon SES](https://docs.aws.amazon.com/ses/latest/dg/creating-identities.html#verify-email-addresses-procedure).

4. **Optional:**
   If you make changes to the code, you will need to zip the Lambda deployment package again:
   - Use the provided `setup.sh` script, or follow the steps in the script manually (minor modifications might be needed for Mac/Linux users).

### Deployment Steps

1. **Prepare Configuration:**
   - Copy `terraform.tfvars.example` to `terraform.tfvars`.
   - Fill out the required values in `terraform.tfvars`.
   - Fill out the required values in `variables.py`

2. **Run the Terraform Workflow Commands:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Considerations

- The emails don't replace language learning with courses, apps, or dedicated vocabulary training. It's just a great way to stay engaged with the language.
- While the same goal could be achieved with other automation, coding, or no-code tools, I prefer using industry-standard services like AWS and Terraform that are widely known and supported.
