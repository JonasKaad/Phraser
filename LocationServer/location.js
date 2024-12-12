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
// Custom locations
const CUSTOM_LOCATIONS = [
    {
        name: "포항공과대학교 생활관 16동",
        coordinates: { lat: 36.017140, lng: 129.322108 },
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

    const a = Math.sin(distance1/2) * Math.sin(distance1/2) +
            Math.cos(length1) * Math.cos(length2) *
            Math.sin(distance2/2) * Math.sin(distance2/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

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