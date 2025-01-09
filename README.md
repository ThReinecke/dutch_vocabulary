# Daily Dutch Vocabulary Email Automation

## Overview
This project automates the daily delivery of an email containing three C1-level Dutch words, their English translations, and example sentences. The email looks like this:

![Screenshot of email](/images/email.png)


## Motivation
I created this project because I couldn't find a suitable app to help me build a C1-level Dutch vocabulary. I discovered that ChatGPT provides good word suggestions and decided to automate the process. Additionally, I check emails more consistently than apps, making this method more effective for learning. Of course, this doesn't replace language courses or sophisticated language apps, but it's a good way to stay engaged with a language.


## Simplified Architecture
A CloudWatch Event Rule triggers a Lambda daily. The Lambda retrieves all previously sent Dutch words from DynamoDB. It then retrieves three new words from ChatGPT, stores them in DynamoDB, and sends them to SES. SES delivers them to the end user's email.

![Picture of architecture](/images/architecture.jpg)


## Setup

### Prerequisites
To deploy this project, ensure the following tools and configurations are in place:

1. **Tools Installed:**
   - Python (Tested with Python 3.8)
   - pip (Tested with pip 19.2.3)
   - Terraform (Tested with Terraform 1.10.3)
   - AWS CLI (Tested with 2.15.58)

   (If you would like to contribute, you also need the packages in the requirements.txt file installed as well as tflint: https://github.com/terraform-linters/tflint)

2. **Permissions:**
   Your AWS CLI user must have the appropriate permissions to deploy the resources. Refer to the Terraform files and apply the principle of least privilege.

3. **Amazon SES Verified Email:**
   You need a verified email address in Amazon SES. This email must match the one used in the project.
   Reference: [Verifying Email Addresses in Amazon SES](https://docs.aws.amazon.com/ses/latest/dg/creating-identities.html#verify-email-addresses-procedure).

4. **Optional:**
   If you make changes to the code, you will need to zip the Lambda deployment package again:
   - Use the provided `setup.sh` script or follow the steps in the script manually (might need small modifications if on Mac/Linux)

### Deployment Steps

1. **Prepare Configuration:**
   - Copy `terraform.tfvars.example` to `terraform.tfvars`.
   - Fill out the required values in `terraform.tfvars`.

2. **Run the Terraform Workflow:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Considerations

- The emails don't replace language learning with courses, apps, or dedicated vocabulary training. It's just a great way to stay engaged with the language.
- The same goal might be achievable with other automation, code, or no-code tools, but I prefer having industry-wide known services/tools like AWS and Terraform that more people are familiar with.
