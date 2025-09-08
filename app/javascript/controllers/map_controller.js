import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="map"
export default class extends Controller {
  static targets = ["container", "coordinates"]
  static values = { 
    initialCoordinates: Array,
    center: Array,
    zoom: Number,
    readonly: Boolean
  }

  connect() {
    // Default values
    this.centerValue = this.centerValue.length ? this.centerValue : [-38.5434, -3.7319] // Fortaleza, CE
    this.zoomValue = this.zoomValue || 10
    this.readonlyValue = this.readonlyValue ?? false

    this.initializeMap()
    this.loadInitialRoute()
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }

  initializeMap() {
    // Initialize Leaflet map
    this.map = L.map(this.containerTarget).setView(this.centerValue, this.zoomValue)

    // Add OpenStreetMap tile layer
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '© <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(this.map)

    // Initialize route storage
    this.routeCoordinates = []
    this.routeMarkers = []
    this.routeLine = null

    if (!this.readonlyValue) {
      this.enableRouteCreation()
    }
  }

  enableRouteCreation() {
    // Add click handler for adding route points
    this.map.on('click', (e) => {
      this.addRoutePoint(e.latlng)
    })
  }

  addRoutePoint(latlng) {
    const coordinates = [latlng.lng, latlng.lat] // [longitude, latitude] format for PostGIS

    // Add to our coordinates array
    this.routeCoordinates.push(coordinates)

    // Create marker for this point
    const markerIndex = this.routeMarkers.length
    const marker = L.marker([latlng.lat, latlng.lng], {
      draggable: true,
      title: `Ponto ${markerIndex + 1}`
    }).addTo(this.map)

    // Add popup with point info and delete button
    marker.bindPopup(`
      <div class="text-center">
        <strong>Ponto ${markerIndex + 1}</strong><br>
        <small>Lat: ${latlng.lat.toFixed(5)}<br>Lng: ${latlng.lng.toFixed(5)}</small><br>
        <button class="mt-2 px-2 py-1 bg-red-500 text-white text-xs rounded hover:bg-red-600" 
                onclick="this.closest('.leaflet-popup').map.fire('remove-point', {index: ${markerIndex}})">
          Remover Ponto
        </button>
      </div>
    `)

    // Handle marker drag
    marker.on('drag', (e) => {
      this.updateRoutePoint(markerIndex, e.target.getLatLng())
    })

    marker.on('dragend', () => {
      this.updateRouteLine()
      this.updateHiddenField()
    })

    this.routeMarkers.push(marker)
    this.updateRouteLine()
    this.updateHiddenField()
  }

  updateRoutePoint(index, latlng) {
    if (index >= 0 && index < this.routeCoordinates.length) {
      this.routeCoordinates[index] = [latlng.lng, latlng.lat]
    }
  }

  removeRoutePoint(index) {
    if (index >= 0 && index < this.routeCoordinates.length) {
      // Remove from coordinates array
      this.routeCoordinates.splice(index, 1)
      
      // Remove marker from map
      if (this.routeMarkers[index]) {
        this.map.removeLayer(this.routeMarkers[index])
        this.routeMarkers.splice(index, 1)
      }

      // Update all remaining markers' popups with new indices
      this.routeMarkers.forEach((marker, idx) => {
        const latlng = marker.getLatLng()
        marker.bindPopup(`
          <div class="text-center">
            <strong>Ponto ${idx + 1}</strong><br>
            <small>Lat: ${latlng.lat.toFixed(5)}<br>Lng: ${latlng.lng.toFixed(5)}</small><br>
            <button class="mt-2 px-2 py-1 bg-red-500 text-white text-xs rounded hover:bg-red-600" 
                    onclick="event.target.dispatchEvent(new CustomEvent('remove-point', {bubbles: true, detail: {index: ${idx}}}))">
              Remover Ponto
            </button>
          </div>
        `)
      })

      this.updateRouteLine()
      this.updateHiddenField()
    }
  }

  updateRouteLine() {
    // Remove existing line
    if (this.routeLine) {
      this.map.removeLayer(this.routeLine)
    }

    // Create new line if we have at least 2 points
    if (this.routeCoordinates.length >= 2) {
      const latlngs = this.routeCoordinates.map(coord => [coord[1], coord[0]]) // Convert to [lat, lng] for Leaflet
      
      this.routeLine = L.polyline(latlngs, {
        color: 'blue',
        weight: 4,
        opacity: 0.7,
        lineJoin: 'round'
      }).addTo(this.map)

      // Fit map to show entire route
      this.map.fitBounds(this.routeLine.getBounds(), { padding: [20, 20] })
    }
  }

  updateHiddenField() {
    if (this.hasCoordinatesTarget) {
      this.coordinatesTarget.value = JSON.stringify(this.routeCoordinates)
      
      // Trigger change event for any listeners
      this.coordinatesTarget.dispatchEvent(new Event('change'))
    }
  }

  loadInitialRoute() {
    if (this.initialCoordinatesValue && this.initialCoordinatesValue.length >= 2) {
      // Load existing route
      this.routeCoordinates = [...this.initialCoordinatesValue]
      
      // Create markers for existing points
      this.routeCoordinates.forEach((coords, index) => {
        const latlng = { lat: coords[1], lng: coords[0] } // Convert from [lng, lat] to {lat, lng}
        
        if (!this.readonlyValue) {
          // Create draggable markers for editing
          const marker = L.marker([latlng.lat, latlng.lng], {
            draggable: true,
            title: `Ponto ${index + 1}`
          }).addTo(this.map)

          marker.bindPopup(`
            <div class="text-center">
              <strong>Ponto ${index + 1}</strong><br>
              <small>Lat: ${latlng.lat.toFixed(5)}<br>Lng: ${latlng.lng.toFixed(5)}</small><br>
              <button class="mt-2 px-2 py-1 bg-red-500 text-white text-xs rounded hover:bg-red-600" 
                      onclick="event.target.dispatchEvent(new CustomEvent('remove-point', {bubbles: true, detail: {index: ${index}}}))">
                Remover Ponto
              </button>
            </div>
          `)

          marker.on('drag', (e) => {
            this.updateRoutePoint(index, e.target.getLatLng())
          })

          marker.on('dragend', () => {
            this.updateRouteLine()
            this.updateHiddenField()
          })

          this.routeMarkers.push(marker)
        } else {
          // Create static markers for readonly view
          const marker = L.marker([latlng.lat, latlng.lng], {
            title: `Ponto ${index + 1}`
          }).addTo(this.map)

          marker.bindPopup(`
            <div class="text-center">
              <strong>Ponto ${index + 1}</strong><br>
              <small>Lat: ${latlng.lat.toFixed(5)}<br>Lng: ${latlng.lng.toFixed(5)}</small>
            </div>
          `)
        }
      })

      this.updateRouteLine()
    }
  }

  // Action for clearing all route points
  clearRoute() {
    // Remove all markers
    this.routeMarkers.forEach(marker => {
      this.map.removeLayer(marker)
    })
    
    // Remove route line
    if (this.routeLine) {
      this.map.removeLayer(this.routeLine)
    }

    // Reset arrays
    this.routeCoordinates = []
    this.routeMarkers = []
    this.routeLine = null

    this.updateHiddenField()
  }

  // Handle remove point events bubbled up from popups
  handleEvent(event) {
    if (event.type === 'remove-point' || event.detail?.type === 'remove-point') {
      const index = event.detail?.index
      if (typeof index === 'number') {
        this.removeRoutePoint(index)
      }
    }
  }
}