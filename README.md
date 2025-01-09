# Daily Dutch Vocabulary Email Automation

## Overview
This project automates the daily delivery of an email containing three C1-level Dutch words, their English translations, and example sentences. The email looks like this:

![Screenshot of email](/images/email.png)


## Motivation
I created this project because I couldn't find a suitable app to help me build a C1-level Dutch vocabulary. I discovered that ChatGPT provides good word suggestions and decided to automate the process. Additionally, I know that I check emails more consistently than apps, making this method more effective for learning.

This project also provided an opportunity to refresh my skills in **Terraform** and **Python**.


## Simplified Architecture
A CloudWatch Event Rule triggers a Lambda each morning at 7:00. The Lambda retrieves all previously sent Dutch words from DynamoDB. It then retrieves three new words from ChatGPT, stores them in DynamoDB, and sends them to SES. SES delivers them to the end user's email.

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
   You can zip the Lambda deployment package manually if you like:
   - Use the provided `setup.sh` script or follow the steps in the script manually (might need small modifications if on Mac/Linux)
   - Alternatively, use the pre-zipped package: `deployment_package.zip`.

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

This project was intended as a **weekend project**, so there is room for improvement. Potential enhancements include:
- Refactoring the Python code to be asynchronous for better performance and robustness.
- Splitting the `lambda_function.py` file into smaller modules for better organization and maintainability.

However, since the project fulfills its purpose and is unlikely to grow further, I kept the implementation simple.
