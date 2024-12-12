const express = require('express');
const axios = require('axios');
const dotenv = require('dotenv');
dotenv.config();

const app = express();
const port = process.env.PORT || 8080;

// Middleware to parse JSON requests
app.use(express.json());

const AZURE_OPENAI_ENDPOINT = process.env.AZURE_OPENAI_ENDPOINT;
const AZURE_OPENAI_KEY = process.env.AZURE_OPENAI_KEY;

const MASTER_PROMPT = `You are generating concise, polite, and practical phrases a user can use based on their location, address, name, and category of the place (e.g., restaurant, café, or shop). If not specified they should be Korean.

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
  "phrase": "Can I see the menu?",
  "translation": "메뉴를 보여 주시겠어요?",
  "transliteration": "Menyureul boyeo jusigeseoyo."
}
Remember to return 3 phrases.`;

// Persistent conversation state
let messages = [
    {
      role: "system",
      content: MASTER_PROMPT
    }
];

// API endpoint to handle requests
app.post('/generate-phrases', async (req, res) => {
    const { address, name, category, mode } = req.body; // Extract data from request body
  
    if (!address || !name || !category) {
      return res.status(400).json({ error: "Address, name, and category are required." });
    }
  
    // If mode is "new", reset the conversation
    if (mode === "new") {
      messages = [
        {
          role: "system",
          content: MASTER_PROMPT
        }
      ];
    }
  
    // Add the user input to the conversation context
    messages.push({
      role: "user",
      content: `Address: ${address}, Name: ${name}, Category: ${category}`
    });
  
    try {
      // Prepare the payload for Azure OpenAI
      const payload = {
        messages,
        max_tokens: 2000,
        temperature: 0.7,
        top_p: 1.0
      };
  
      // Make the API request to Azure OpenAI
      const response = await axios.post(AZURE_OPENAI_ENDPOINT, payload, {
        headers: {
            "Content-Type": "application/json",
            "api-key": AZURE_OPENAI_KEY
        }
      });
  
      // Extract the assistant's response
      const assistantResponse = response.data.choices[0].message.content;
  
      // Append the assistant response to the conversation
      messages.push({
        role: "assistant",
        content: assistantResponse
      });
  
      // Return the response to the client
        console.log(response);
      
      res.json({ response: assistantResponse });
    } catch (error) {
      console.error("Error communicating with Azure OpenAI:", error);
      res.status(500).json({ error: "Failed to generate phrases." });
    }
});

// Start the server
app.listen(port, () => {
console.log(`Server running on http://localhost:${port}`);
});
  