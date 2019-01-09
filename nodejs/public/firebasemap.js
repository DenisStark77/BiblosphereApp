var firebase = new Firebase("https://biblosphere-210106.firebaseIO.com");

/**
 * Data object to be written to Firebase.
 */
var data = {
  sender: null,
  timestamp: null,
  lat: null,
  lng: null
};

/**
 * Starting point for running the program. Authenticates the user.
 * @param {function} Called when authentication succeeds.
 */
function initAuthentication(onAuthSuccess) {
  firebase.authAnonymously(function(error, authData) {
    if (error) {
      console.log('Login Failed!', error);
    } else {
      data.sender = authData.uid;
      onAuthSuccess();
    }
  }, {remember: 'sessionOnly'});  // Users will get a new id for every session.
}

// Listener for when a click is added - add it to the heatmap.
clicks.orderByChild('timestamp').startAt(startTime).on('child_added',
  function(snapshot) {
    var newPosition = snapshot.val();
    var point = new google.maps.LatLng(newPosition.lat, newPosition.lng);
    heatmap.getData().push(point);
  }
);

/**
 * Set up a Firebase with deletion on clicks older than expirySeconds
 * @param {!google.maps.visualization.HeatmapLayer} heatmap The heatmap to
 * which points are added from Firebase.
 */
function initFirebase(heatmap) {

  // 10 minutes before current time.
  var startTime = new Date().getTime() - (60 * 10 * 1000);

  // Reference to the clicks in Firebase.
  var clicks = firebase.child('clicks');

  // Remove old clicks.
  clicks.orderByChild('timestamp').endAt(startTime).on('child_added',
    function(snapshot) {
      snapshot.ref().remove();
    }
  );

}

/**
 * Adds a click to firebase.
 * @param {Object} data The data to be added to firebase.
 *     It contains the lat, lng, sender and timestamp.
 */
function addToFirebase(data) {
  getTimestamp(function(timestamp) {
    // Add the new timestamp to the record data.
    data.timestamp = timestamp;
    var ref = firebase.child('clicks').push(data, function(err) {
      if (err) {  // Data was not written to firebase.
        console.log(err);
      }
    });
  });
}

/**
 * Also called each time the map is clicked.
 * Updates the last_message/ path with the current timestamp.
 * @param {function(Date)} addClick After the last message timestamp has been updated,
 *     this function is called with the current timestamp to add the
 *     click to the firebase.
 */
function getTimestamp(addClick) {
  // Reference to location for saving the last click time.
  var ref = firebase.child('last_message/' + data.sender);

  ref.onDisconnect().remove();  // Delete reference from firebase on disconnect.

  // Set value to timestamp.
  ref.set(Firebase.ServerValue.TIMESTAMP, function(err) {
    if (err) {  // Write to last message was unsuccessful.
      console.log(err);
    } else {  // Write to last message was successful.
      ref.once('value', function(snap) {
        addClick(snap.val());  // Add click with same timestamp.
      }, function(err) {
        console.log(err);
      });
    }
  });
}

function initMap() {
  var map = new google.maps.Map(document.getElementById('map'), {
    center: {lat: 0, lng: 0},
    zoom: 3,
    styles: [{
      featureType: 'poi',
      stylers: [{ visibility: 'off' }]  // Turn off points of interest.
    }, {
      featureType: 'transit.station',
      stylers: [{ visibility: 'off' }]  // Turn off bus stations, train stations, etc.
    }],
    disableDoubleClickZoom: true
  });

  // Create the DIV to hold the control and call the makeInfoBox() constructor
  // passing in this DIV.
  var infoBoxDiv = document.createElement('div');
  var infoBox = new makeInfoBox(infoBoxDiv, map);
  infoBoxDiv.index = 1;
  map.controls[google.maps.ControlPosition.TOP_CENTER].push(infoBoxDiv);

  // Create a heatmap.
  var heatmap = new google.maps.visualization.HeatmapLayer({
    data: [],
    map: map,
    radius: 16
  });
}

  function makeInfoBox(controlDiv, map) {
    // Set CSS for the control border.
    var controlUI = document.createElement('div');
    controlUI.style.boxShadow = 'rgba(0, 0, 0, 0.298039) 0px 1px 4px -1px';
    controlUI.style.backgroundColor = '#fff';
    controlUI.style.border = '2px solid #fff';
    controlUI.style.borderRadius = '2px';
    controlUI.style.marginBottom = '22px';
    controlUI.style.marginTop = '10px';
    controlUI.style.textAlign = 'center';
    controlDiv.appendChild(controlUI);

    // Set CSS for the control interior.
    var controlText = document.createElement('div');
    controlText.style.color = 'rgb(25,25,25)';
    controlText.style.fontFamily = 'Roboto,Arial,sans-serif';
    controlText.style.fontSize = '100%';
    controlText.style.padding = '6px';
    controlText.innerText = 'The map shows all clicks made in the last 10 minutes.';
    controlUI.appendChild(controlText);
  }

