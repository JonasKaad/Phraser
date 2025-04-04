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

let generateNewPhrases = true;
let lastGPTCallTime = 0;
const GPT_CALL_COOLDOWN = 5000; // 5 seconds cooldown
const INITIAL_CONNECT_DELAY = 500; // 1 second
const initialConnections = new Map(); // Track requests per client
const activeRequests = new Map(); // Track active requests per client
const clientPhrases = new Map(); // Track phrases per client
const gptRequests = new Map(); // Track GPT requests per client
const GPT_REQUEST_DEBOUNCE = 2000; // 2 second debounce

const PHRASE_RESEND_TIMEOUT = 10000; // 10 seconds
const lastClientRequest = new Map(); // Track last request time per client

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

let previousLocation = null;


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

function getClientIdentifier(req) {
    return req.ip || 'unknown';
}

app.post('/geocode', async (req, res) => {
    try {
       
        const { latitude, longitude, clientId, mode } = req.body;

        // Use client ID if provided, fallback to IP
        const effectiveClientId = clientId || getClientIdentifier(req);
        
        // Reset phrases for client if new session
        if (mode === "new" || mode === "append" && !clientPhrases.has(effectiveClientId)) {
            generateNewPhrases = true;
        }

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

        let place = null;
        let isInPlace = false;

        // If we're within range of a custom location, return it
        if (nearestCustomLocation) {
            place = {
                name: nearestCustomLocation.name,
                category: nearestCustomLocation.category,
                distance: nearestCustomLocation.distance,
                isCustomLocation: true
            };
            isInPlace = true;
        }

        // If no custom location found, check Kakao API
        if (!place) {
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
                place = {
                    name: nearestPlace.place_name,
                    category: nearestPlace.category_name,
                    distance: parseInt(nearestPlace.distance),
                    address: nearestPlace.address_name,
                    phone: nearestPlace.phone,
                    isCustomLocation: false
                };
                isInPlace = true;
            }
        }

        // Prepare response object
        const locationResponse = {
            isInPlace,
            place: place,
            message: place ? previousLocation : "Not currently in any detected place"
        };

        //console.log('response up');
        
        // currentLocation
        const currentLocation = place?.address || place?.name || null;
        console.log('Previous Location:', previousLocation);
        console.log('Current Location:', currentLocation);


        if (!isInPlace) {
            clientPhrases.delete(effectiveClientId);
            console.log('Not in place, clearing phrases', locationResponse);
            return res.json({
                location: locationResponse
            });
        }
        
        // Check if client already has phrases for this location
        const clientCache = clientPhrases.get(effectiveClientId);
        if (clientCache && clientCache.location === currentLocation && mode != "append") {
            previousLocation = currentLocation;
            
            const now = Date.now();
            const lastRequest = lastClientRequest.get(effectiveClientId) || 0;
            const timeSinceLastRequest = now - lastRequest;
            lastClientRequest.set(effectiveClientId, now);

            if (timeSinceLastRequest > PHRASE_RESEND_TIMEOUT) {
                console.log('Returning cached phrases:', locationResponse, clientCache.phrases);
                return res.json({
                    location: locationResponse,
                    phrases: clientCache.phrases
                });
            } else {
                return res.json({
                    location: locationResponse
                });
            }
            
        }

        // Safe comparison for places
        if (previousLocation != currentLocation) {
            generateNewPhrases = true;
        }

        let phrases = null;
        const currentTime = Date.now();

        if (currentTime - lastGPTCallTime >= GPT_CALL_COOLDOWN && generateNewPhrases) {
            
            const lastGptRequest = gptRequests.get(effectiveClientId);
            if (lastGptRequest && (currentTime - lastGptRequest < GPT_REQUEST_DEBOUNCE)) {
                return;
            }

            // Set GPT request timestamp
            gptRequests.set(effectiveClientId, currentTime);
            lastGPTCallTime = currentTime;

            try {
                // Reset conversation if mode is "new"
                if (mode === "new") {
                    messages = [{ role: "system", content: MASTER_PROMPT }];
                }

                // Add user input to conversation
                messages.push({
                    role: "user",
                    content: `Address: ${place.address || 'N/A'}, Name: ${place.name}, Category: ${place.category}`
                });

                const payload = {
                    messages,
                    max_tokens: 2000,
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
                messages.push({
                    role: "assistant",
                    content: assistantResponse
                });

                

                try {
                    phrases = JSON.parse(assistantResponse);
                    if (!validatePhrases(phrases)) {
                        console.error('Invalid phrase format:', phrases);
                        phrases = null;
                    }
                    console.log('Parsed phrases:', phrases);

                    // Clear GPT request after successful call
                    gptRequests.delete(effectiveClientId);

                    clientPhrases.set(effectiveClientId, {
                        location: currentLocation,
                        phrases: phrases
                    });
                } catch (parseError) {
                    gptRequests.delete(effectiveClientId);
                    console.error('JSON parse error:', parseError);
                    console.log('Raw response:', assistantResponse);
                    phrases = null;
                }
                lastGPTCallTime = currentTime;
                
                console.log('Successfully generated phrases');
            } catch (gptError) {
                console.error("Error generating phrases:", gptError);
                phrases = null;
            }
        } else {        
            const finalResponse = {
                location: locationResponse
            };
            return res.json(finalResponse);
        }

        previousLocation = currentLocation;

        // Send final response
        const finalResponse = {
            location: locationResponse,
            phrases: phrases
        };

        console.log('Sending response:', JSON.stringify(finalResponse, null, 2));
        return res.json(finalResponse);

    } catch (error) {
      //  activeRequests.delete(clientId); // Clear request status on error
        console.error('Error:', error.response?.data || error.message);
        res.status(500).json({
            error: 'Failed to fetch location information',
            details: error.response?.data || error.message
        });
    }
});

setInterval(() => {
    const now = Date.now();
    for (const [clientId, timestamp] of gptRequests) {
        if (now - timestamp > GPT_REQUEST_DEBOUNCE * 2) {
            console.log('Clearing stale GPT request:', clientId);
            gptRequests.delete(clientId);
        }
    }
}, GPT_REQUEST_DEBOUNCE);

setInterval(() => {
    const now = Date.now();
    for (const [clientId, lastTime] of lastClientRequest) {
        if (now - lastTime > PHRASE_RESEND_TIMEOUT * 2) {
            lastClientRequest.delete(clientId);
        }
    }
}, PHRASE_RESEND_TIMEOUT);

function validatePhrases(phrases) {
    if (!Array.isArray(phrases)) return false;
    return phrases.every(phrase => 
        phrase.phrase && 
        phrase.translation && 
        phrase.transliteration
    );
}

app.get('/health', (req, res) => {
    res.json({ status: 'ok' });
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});