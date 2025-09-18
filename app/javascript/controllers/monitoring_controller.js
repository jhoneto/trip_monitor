import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["map"]
  static values = {
    routeCoordinates: Array,
    lastLocations: Object,
    routeId: Number
  }

  connect() {
    console.log("Monitoring controller connecting...");
    console.log("Route ID:", this.routeIdValue);
    console.log("Route coordinates:", this.routeCoordinatesValue);
    console.log("Last locations:", this.lastLocationsValue);

    // Store participant markers for real-time updates
    this.participantMarkers = new Map();

    // Listen for position updates
    this.boundHandlePositionUpdate = this.handlePositionUpdate.bind(this);
    window.addEventListener('participant-position-update', this.boundHandlePositionUpdate);
    console.log("📡 Event listener registered for 'participant-position-update'");

    // Wait a bit for DOM to be fully ready
    setTimeout(() => {
      this.initializeMap();
    }, 100);
  }

  disconnect() {
    if (this.boundHandlePositionUpdate) {
      window.removeEventListener('participant-position-update', this.boundHandlePositionUpdate);
    }
  }

  initializeMap() {
    console.log("Initializing map...");

    // Check if Leaflet is loaded
    if (typeof L === 'undefined') {
      console.error("Leaflet is not loaded!");
      return;
    }

    const mapElement = this.mapTarget;
    if (!mapElement) {
      console.error("Map element not found!");
      return;
    }

    // Force map container to have explicit dimensions
    mapElement.style.width = '100%';
    mapElement.style.height = '100%';
    mapElement.style.minHeight = '400px';

    // Default center (Fortaleza, CE)
    let center = [-3.7319, -38.5434];
    let zoom = 13;

    // If we have last locations, use them to calculate center
    const lastLocations = this.lastLocationsValue;
    if (Object.keys(lastLocations).length > 0) {
      const locations = Object.values(lastLocations);
      const lats = locations.map(loc => loc.latitude);
      const lngs = locations.map(loc => loc.longitude);

      center = [
        lats.reduce((a, b) => a + b) / lats.length,
        lngs.reduce((a, b) => a + b) / lngs.length
      ];
    }

    console.log("Initializing map with center:", center, "zoom:", zoom);

    try {
      // Initialize map
      this.map = L.map(mapElement, {
        center: center,
        zoom: zoom,
        zoomControl: true,
        attributionControl: true
      });

      console.log("Map object created successfully");

      // Add tile layer
      L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
      }).addTo(this.map);

      console.log("Tile layer added successfully");

      // Force map to resize after a short delay
      setTimeout(() => {
        this.map.invalidateSize();
        console.log("Map size invalidated");
      }, 500);

      // Load data
      this.loadMapData();

    } catch (error) {
      console.error("Error initializing map:", error);
    }
  }

  loadMapData() {
    console.log("Loading map data...");

    const routeCoords = this.routeCoordinatesValue;
    const lastLocations = this.lastLocationsValue;

    console.log("Route coordinates:", routeCoords);
    console.log("Last locations:", lastLocations);

    // Add route line if exists
    if (routeCoords && routeCoords.length > 0) {
      console.log("Adding planned route line to map...");
      const routeLatLngs = routeCoords.map(coord => [coord[1], coord[0]]);
      const routeLine = L.polyline(routeLatLngs, {
        color: '#DC2626', // Red color for planned route
        weight: 4,
        opacity: 0.9
      }).addTo(this.map);
      console.log("Planned route line added successfully");

      // Center map on route bounds
      this.map.fitBounds(routeLine.getBounds().pad(0.1));
      console.log("Map centered on route bounds");
    }

    // Add participant markers
    if (Object.keys(lastLocations).length > 0) {
      console.log("Adding participant markers...");
      Object.entries(lastLocations).forEach(([userId, location]) => {
        console.log(`Adding marker for ${location.user_email}:`, location);
        this.addParticipantMarker(userId, location);
      });

      // If no route exists, fit map to participant locations
      if (!routeCoords || routeCoords.length === 0) {
        const locations = Object.values(lastLocations);
        const bounds = L.latLngBounds(locations.map(loc => [loc.latitude, loc.longitude]));
        this.map.fitBounds(bounds.pad(0.1));
      }
    } else {
      console.log("No participants with last locations found");
    }

    console.log("Map data loading completed");
  }

  addParticipantMarker(userId, location) {
    const { latitude, longitude, user_email, user_initial, timestamp } = location;
    const latlng = [latitude, longitude];

    console.log(`Creating marker for ${user_email} at:`, latlng);

    // Create custom marker icon
    const markerIcon = L.divIcon({
      html: `<div class="participant-marker">
               <div class="marker-avatar">${user_initial}</div>
               <div class="marker-pulse"></div>
             </div>`,
      className: 'custom-marker',
      iconSize: [40, 40],
      iconAnchor: [20, 20]
    });

    // Create marker
    const marker = L.marker(latlng, { icon: markerIcon }).addTo(this.map);

    // Add popup
    marker.bindPopup(`
      <div class="text-center">
        <strong>${user_email}</strong><br>
        <small>Última atualização: ${new Date(timestamp).toLocaleTimeString()}</small>
      </div>
    `);

    // Store marker for updates
    this.participantMarkers.set(parseInt(userId), marker);

    console.log(`Marker created for ${user_email}`);
  }

  handlePositionUpdate(event) {
    console.log("📍 Position update received:", event.detail);

    const { user_id, user_email, user_initial, latitude, longitude, timestamp } = event.detail;
    const latlng = [latitude, longitude];

    // Get existing marker or create new one
    let marker = this.participantMarkers.get(user_id);

    if (marker) {
      console.log(`🔄 Updating marker position for ${user_email} to:`, latlng);

      // Update marker position
      marker.setLatLng(latlng);

      // Update popup content
      marker.getPopup().setContent(`
        <div class="text-center">
          <strong>${user_email}</strong><br>
          <small>Última atualização: ${new Date(timestamp).toLocaleTimeString()}</small>
        </div>
      `);
    } else {
      console.log(`✨ Creating new marker for ${user_email} at:`, latlng);

      // Create new marker
      const markerIcon = L.divIcon({
        html: `<div class="participant-marker">
                 <div class="marker-avatar">${user_initial}</div>
                 <div class="marker-pulse"></div>
               </div>`,
        className: 'custom-marker',
        iconSize: [40, 40],
        iconAnchor: [20, 20]
      });

      marker = L.marker(latlng, { icon: markerIcon }).addTo(this.map);

      marker.bindPopup(`
        <div class="text-center">
          <strong>${user_email}</strong><br>
          <small>Última atualização: ${new Date(timestamp).toLocaleTimeString()}</small>
        </div>
      `);

      this.participantMarkers.set(user_id, marker);
    }

    console.log(`✅ Position updated for ${user_email}`);
  }
}