import requests
import json
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

class TravelTimeRequester:
    def __init__(self):
        self.locations_url = "https://accessmod.mapx.org/get_list_locations"
        self.compute_url = "https://accessmod.mapx.org/compute_travel_time"
        
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
    main()
