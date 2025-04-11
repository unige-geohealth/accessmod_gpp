import requests
import json
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

class TravelTimeRequester:
    def __init__(self):
        self.locations_url = "https://api.accessmod.org/get_list_locations"
        self.compute_url = "https://api.accessmod.org/compute_travel_time"
        
    def get_locations(self):
        """Fetch list of available locations"""
        try:
            response = requests.get(self.locations_url)
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            print(f"Error fetching locations: {e}")
            return []

    def compute_travel_time(self, location):
        """Make POST request for a single location"""
        payload = {
            "location": location
        }
        
        try:
            response = requests.post(self.compute_url, json=payload)
            response.raise_for_status()
            return {
                "location": location,
                "status": response.status_code,
                "response": response.json()
            }
        except requests.RequestException as e:
            return {
                "location": location,
                "status": getattr(e.response, 'status_code', None),
                "error": str(e)
            }

    def process_all_locations(self, max_workers=5):
        """Process all locations with concurrent requests"""
        locations = self.get_locations()
        if not locations:
            print("No locations found!")
            return
        
        results = []
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            future_to_location = {
                executor.submit(self.compute_travel_time, location): location 
                for location in locations
            }
            
            for future in as_completed(future_to_location):
                result = future.result()
                results.append(result)
                location = result["location"]
                if "error" in result:
                    print(f"❌ {location}: {result['error']}")
                else:
                    print(f"✅ {location}: Status {result['status']}")
        
        return results

def test_specific_location(location_name):
    requester = TravelTimeRequester()
    print(f"Testing travel time computation for {location_name}...")
    
    # Get locations to verify the location exists
    locations = requester.get_locations()
    if not locations:
        print("Failed to fetch locations!")
        return
    
    print(f"Available locations: {locations}")
    
    if location_name not in locations:
        print(f"Location '{location_name}' not found in available locations!")
        return
    
    # Test specific location
    result = requester.compute_travel_time(location_name)
    print(f"\nResult for {location_name}:")
    print(json.dumps(result, indent=2))
    return result

def main():
    requester = TravelTimeRequester()
    print("Starting travel time computation for all locations...")
    results = requester.process_all_locations()
    
    # Save results to file
    timestamp = time.strftime("%Y%m%d-%H%M%S")
    filename = f"travel_time_results_{timestamp}.json"
    with open(filename, 'w') as f:
        json.dump(results, f, indent=2)
    print(f"\nResults saved to {filename}")

if __name__ == "__main__":
    # Test specifically for Lausanne
    test_specific_location("Lausanne")
