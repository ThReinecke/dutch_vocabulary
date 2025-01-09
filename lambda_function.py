import json
from typing import Any, List, Dict
import boto3
from openai import OpenAI

# HELPER FUNCTIONS


def get_ssm_parameter(parameter_name: str) -> str:
    try:
        response = ssm_client.get_parameter(
            Name=parameter_name, WithDecryption=True
        )
        return response["Parameter"]["Value"]
    except Exception as e:
        print(f"Error retrieving parameter {parameter_name} from SSM: {e}")
        raise


def get_all_words() -> str:
    try:
        response = table.scan()
        words = [item["word"] for item in response.get("Items", [])]
        formatted_words = ", ".join(words)
        return formatted_words
    except Exception as e:
        print(f"Error retrieving words from DynamoDB: {e}")
        raise


def put_words_in_db_table(words: List[Dict[str, str]]) -> None:
    try:
        with table.batch_writer() as batch:
            for word_entry in words:
                if not all(
                    key in word_entry for key in (
                                            "word",
                                            "translation",
                                            "example"
                                        )
                ):
                    raise ValueError(
                        f"Invalid word entry: {word_entry}. "
                        "Must contain 'word', 'translation', and "
                        "'example' keys."
                    )
                batch.put_item(
                    Item={
                        "word": word_entry["word"],
                        "translation": word_entry["translation"],
                        "example": word_entry["example"],
                    }
                )
        print("All words successfully inserted into the db table.")
    except Exception as e:
        print(f"Error inserting words into the DynamoDB table: {e}")
        raise


def create_prompt(existing_words: str) -> str:
    return (
        f"Provide exactly 3 words in Dutch at the C1 level, but none of "
        f"those: {existing_words}. Return them as an array of dictionaries. "
        f"Each dictionary should include the fields: 'word' (the Dutch word), "
        f"'translation' (the English translation), and 'example' (a sentence "
        f"using the word in context). Example format: "
        "[{\"word\": \"word1\", \"translation\": \"example1\", "
        "\"example\": \"sentence1\"}, {\"word\": \"word2\", "
        "\"translation\": \"example2\", \"example\": \"sentence2\"}, "
        "{\"word\": \"word3\", \"translation\": \"example3\", "
        "\"example\": \"sentence3\"}]. Do not add any additional words, "
        "explanations, or introductions in your reply."
    )


# Initialize -------------------------------
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("WordsTable")
ssm_client = boto3.client("ssm")
ses_client = boto3.client("ses")
ses_email = get_ssm_parameter("EMAIL_FOR_SES")
client = OpenAI(api_key=get_ssm_parameter("OPEN_AI_API_KEY"))


# Lambda code -------------------------------
def lambda_handler(event: Any, context: Any) -> Dict[str, Any]:
    """
    Lambda function handler that retrieves words from the DynamoDB table, calls
    the OpenAI API to generate new words, stores the words in DynamoDB, and
    sends an email with the words using AWS SES.
    """
    try:
        words = get_all_words()
        prompt = create_prompt(words)

        response = client.chat.completions.create(
            model="gpt-4", messages=[{"role": "user", "content": prompt}]
        )

        response_content = response.choices[0].message.content
        json_response = json.loads(response_content)

        put_words_in_db_table(json_response)

        # Format email for SES
        formatted_html = "<html><body>"
        formatted_html += "<h2>🇳🇱 Jouw woorden voor "
        formatted_html += "vandaag</h2>"
        formatted_html += (
            "<table border='1' cellpadding='10' style='border-collapse: "
            "collapse;'>"
        )
        formatted_html += (
            "<tr><th>Word</th><th>Translation</th>"
            "<th>Example</th></tr>"
        )

        for item in json_response:
            formatted_html += (
                f"<tr><td>{item['word']}</td><td>{item['translation']}</td>"
                f"<td>{item['example']}</td></tr>"
            )

        formatted_html += "</table>"
        formatted_html += "</body></html>"

        ses_client.send_email(
            Source=ses_email,
            Destination={"ToAddresses": [ses_email]},
            Message={
                "Subject": {"Data": "📚 Jouw dagelijkse woordenschat"
                            },
                "Body": {"Html": {"Data": formatted_html}},
            },
        )

        return {"statusCode": 200, "body": "Email sent successfully."}

    except Exception as e:
        print(f"Error during execution: {e}")
        return {"statusCode": 500, "body": str(e)}
