const express = require('express');
const axios = require('axios');
const dotenv = require('dotenv');
dotenv.config();

const app = express();
const port = process.env.PORT || 8080;

// Middleware to parse JSON bodies
app.use(express.json());
// Constants for place detection
const PLACE_DETECTION_RADIUS = 40; // meters
const PLACE_CATEGORIES = [
    'MT1', // Mart
    'CS2', // Convenience Store
    'FD6', // Restaurant
    'CE7', // Cafe
    'HP8', // Hospital
    'PM9'  // Pharmacy
];

const AZURE_OPENAI_ENDPOINT = process.env.AZURE_OPENAI_ENDPOINT;
const AZURE_OPENAI_KEY = process.env.AZURE_OPENAI_KEY;

// Custom locations
const CUSTOM_LOCATIONS = [
    {
        name: "포항공과대학교 생활관 16동",
        coordinates: { lat: 36.017140, lng: 129.322108 },
        category: "학교 > 기숙사",
        address: "경상북도 포항시 남구 청암로 77, 지곡동 포항공과대학교 기숙사16동",
    },
    {
        name: "포항공과대학교 생활관 13동",
        coordinates: { lat: 36.016900, lng: 129.322720 },
        category: "학교 > 기숙사",
        address: "경상북도 포항시 남구 청암로 77, 지곡동 포항공과대학교 기숙사16동",
    },
    {
        name: "포항공과대학교 제2공학관",
        coordinates: { lat: 36.012430, lng: 129.321970 },
        category: "학교 > 공학관",
        address: "경상북도 포항시 남구 청암로 77",

    }
];

function calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371e3; // Earth's radius in meters
    const length1 = lat1 * Math.PI / 180;
    const length2 = lat2 * Math.PI / 180;
    const distance1 = (lat2 - lat1) * Math.PI / 180;
    const distance2 = (lon2 - lon1) * Math.PI / 180;

    const a = Math.sin(distance1 / 2) * Math.sin(distance1 / 2) +
        Math.cos(length1) * Math.cos(length2) *
        Math.sin(distance2 / 2) * Math.sin(distance2 / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c;
}



app.post('/geocode', async (req, res) => {
    try {
        const { latitude, longitude } = req.body;

        if (!latitude || !longitude) {
            return res.status(400).json({
                error: 'Missing required parameters: latitude and longitude'
            });
        }

        // Check custom locations first
        const customLocationDistances = CUSTOM_LOCATIONS.map(location => ({
            ...location,
            distance: Math.round(calculateDistance(
                latitude,
                longitude,
                location.coordinates.lat,
                location.coordinates.lng
            ))
        }));

        const nearestCustomLocation = customLocationDistances
            .filter(loc => loc.distance <= PLACE_DETECTION_RADIUS)
            .sort((a, b) => a.distance - b.distance)[0];
    

        // If we're within range of a custom location, return it
        if (nearestCustomLocation) {
            return res.json({
                isInPlace: true,
                place: {
                    name: nearestCustomLocation.name,
                    category: nearestCustomLocation.category,
                    distance: nearestCustomLocation.distance,
                    address: nearestCustomLocation.address,
                    isCustomLocation: true
                }
            });
        }

        // If no custom location found, check Kakao API
            const placesResponse = await axios.get('https://dapi.kakao.com/v2/local/search/category.json', {
                params: {
                    category_group_code: PLACE_CATEGORIES.join(','),
                    x: longitude,
                    y: latitude,
                    radius: PLACE_DETECTION_RADIUS,
                    sort: 'distance'
                },
                headers: {
                    'Authorization': `KakaoAK ${process.env.KAKAO_API_KEY}`
                }
            });

            const nearestPlace = placesResponse.data.documents[0];

            if (nearestPlace && parseInt(nearestPlace.distance) <= PLACE_DETECTION_RADIUS) {
                return res.json({
                    isInPlace: true,
                    place: {
                        name: nearestPlace.place_name,
                        category: nearestPlace.category_name,
                        distance: parseInt(nearestPlace.distance),
                        address: nearestPlace.address_name,
                        phone: nearestPlace.phone,
                        isCustomLocation: false
                    }
                });
            }
        // If no place is found within radius, return nearest custom location for debugging
        res.json({
            isInPlace: false,
            message: "Not currently in any detected place"
        });
    } catch (error) {
      //  activeRequests.delete(clientId); // Clear request status on error
        console.error('Error:', error.response?.data || error.message);
        res.status(500).json({
            error: 'Failed to fetch location information',
            details: error.response?.data || error.message
        });
    }
});

app.post('/phrases', async (req, res) => {
    try {
        const { name, category, address, time, mode } = req.body;

        if (!name || !category) {
            return res.status(400).json({
                error: 'Missing required parameters: name and category'
            });
        }

        console.log("was called with name: ", name, " category: ", category, " address: ", address, "time: ", time, " mode: ", mode);

        try {
            // Reset
            if (mode !== 'refresh') {
                messages = [{ role: "system", content: MASTER_PROMPT }];
            }
        

            // Add user input to conversation
            messages.push({
                role: "user",
                content: `Address: ${address || 'N/A'}, Name: ${name}, Category: ${category}, Date/Time: ${time || 'N/A'}`
            });

            const payload = {
                messages,
                max_tokens: 3000,
                temperature: 0.7,
                top_p: 1.0
            };

            const response = await axios.post(AZURE_OPENAI_ENDPOINT, payload, {
                headers: {
                    "Content-Type": "application/json",
                    "api-key": AZURE_OPENAI_KEY
                }
            });

            const assistantResponse = response.data.choices[0].message.content;
            console.log('Assistant response:', assistantResponse);
            messages.push({
                role: "assistant",
                content: assistantResponse
            });
            phrases = cleanGPTResponse(assistantResponse);
            if (!phrases) {
                return res.status(500).json({
                    error: 'Failed to generate phrases',
                    details: 'Invalid response from GPT'
                });
            }
            return res.json({ phrases });

        } catch (error) {
            console.error('Phrase error:', error.response?.data || error.message);
            return res.status(500).json({
                error: 'Failed to generate phrases',
                details: error.response?.data || error.message
            });
        }
    } catch (error) {
        console.error('Endpoint error:', error.response?.data || error.message);
        res.status(500).json({
            error: 'Error on endpoint',
            details: error.response?.data || error.message
        });
    }
    
});

app.get('/health', (req, res) => {
    res.json({ status: 'ok' });
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});

const MASTER_PROMPT = `You are generating concise, polite, and practical phrases a user can use based on their location, date, address, name, and category of the place (e.g., restaurant, café, or shop). If not specified they should be Korean.

- Focus on phrases relevant to typical actions for the category (e.g., ordering food in a restaurant, asking for the menu in a café, or inquiring about a product in a shop).
- Take holidays, weekends, and time of day into account (e.g., "Good morning" or "Merry Christmas").
- Use polite language suitable for the cultural context (e.g., formal expressions for Korean settings).

Return 3 phrases in JSON format:
{
 "phrase": "The English version of the phrase.",
  "translation": "The translation phrase in the target language.",
  "transliteration": "The pronunciation guide for the phrase."
}

Examples:
- Input: name: "Cafe XYZ", category: "카페"
- Output:
{
  "phrase": "Can I have an Americano?",
  "translation": "아메리카노 하나 주세요.",
  "transliteration": "Amerikano hana juseyo."
}
- Input:  name: "Restaurant ABC", category: "음식점"
- Output:
{
  "phrase": "Can I see the menu?",
  "translation": "메뉴를 보여 주시겠어요?",
  "transliteration": "Menyureul boyeo jusigeseoyo."
}
Remember to return 3 phrase as structured JSON data.`;

// Persistent conversation state
let messages = [
    {
        role: "system",
        content: MASTER_PROMPT
    }
];
function cleanGPTResponse(response) {
    // Remove markdown code blocks if present
    response = response.replace(/```(json)?\n?/g, '');
    
    // Trim whitespace
    response = response.trim();
    
    try {
        const parsed = JSON.parse(response);
        if (validatePhrases(parsed)) {
            return parsed;
        }
    } catch (error) {
        console.error('JSON parse error:', error);
    }
    return null;
}
function validatePhrases(phrases) {
    if (!Array.isArray(phrases)) return false;
    return phrases.every(phrase => 
        phrase.phrase && 
        phrase.translation && 
        phrase.transliteration
    );
}