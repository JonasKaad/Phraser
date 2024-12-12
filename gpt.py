import requests

# Your GPT-4o-mini endpoint and API key
endpoint = "key"
api_key = "api"

# Headers for the request
headers = {
    "Content-Type": "application/json",
    "api-key": api_key
}

MESSAGE ='''
You are generating concise, polite, and practical phrases a user can use based on their location, address, name, and category of the place (e.g., restaurant, café, or shop). If not specified they should be Korean.

- Focus on phrases relevant to typical actions for the category (e.g., ordering food in a restaurant, asking for the menu in a café, or inquiring about a product in a shop).
- Use polite language suitable for the cultural context (e.g., formal expressions for Korean settings).

Return 3 phrases in JSON format:
{
 "phrase": "The English version of the phrase.",
  "translation": "The translation phrase in the target language.",
  "transliteration": "The pronunciation guide for the phrase."
}
If transliteration is not applicable, return "N/A".

Examples:
- Input: Name: "Cafe XYZ", Category: "카페"
- Output:
{
  "phrase": "Can I have an Americano?",
  "translation": "아메리카노 하나 주세요.",
  "transliteration": "Amerikano hana juseyo."
}
- Input:  Name: "Restaurant ABC", category: "음식점"
- Output:
{
  "phra": "Can I see the menu?",
  "translation": "메뉴를 보여 주시겠어요?",
  "transliteration": "Menyureul boyeo jusigeseoyo."
}
'''

PAYLOAD = '''
"name": "까오산",
"category": "음식점 > 아시아음식 > 동남아음식 > 태국음식",
"address": "경북 포항시 남구 효자동 253-105"
'''

# Data payload for the request
data = {
    "messages": [
        {"role": "system", "content": MESSAGE},
        {"role": "user", "content": PAYLOAD}
    ],
    "max_tokens": 200,
    "temperature": 0.7,
    "top_p": 1.0,
}

# Send the POST request
response = requests.post(endpoint, headers=headers, json=data)

# Check the response
if response.status_code == 200:
    print("Response:", response.json())
else:
    print("Error:", response.status_code, response.text)
