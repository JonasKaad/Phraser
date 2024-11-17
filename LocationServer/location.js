const express = require('express');
const axios = require('axios');
const dotenv = require('dotenv');
dotenv.config();

const app = express();
const port = process.env.PORT || 8000;

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

app.post('/api/location', async (req, res) => {
    try {
        const { latitude, longitude } = req.body;

        if (!latitude || !longitude) {
            return res.status(400).json({
                error: 'Missing required parameters: latitude and longitude'
            });
        }

        // Get nearby places
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

        // Find the nearest place within the radius
        const nearestPlace = placesResponse.data.documents[0];

        if (nearestPlace && parseInt(nearestPlace.distance) <= PLACE_DETECTION_RADIUS) {
            // Return only the relevant place information
            return res.json({
                isInPlace: true,
                place: {
                    name: nearestPlace.place_name,
                    category: nearestPlace.category_name,
                    distance: parseInt(nearestPlace.distance),
                    address: nearestPlace.address_name,
                    phone: nearestPlace.phone
                }
            });
        }

        // If no place is found within radius
        res.json({
            isInPlace: false,
            message: "Not currently in any detected place"
        });

    } catch (error) {
        console.error('Error:', error.response?.data || error.message);
        res.status(500).json({
            error: 'Failed to fetch location information',
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