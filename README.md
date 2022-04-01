#  On The Map

## Description

On the Map allows Udacity students to display their location and introduce themselves via a URL attached to it. The app displays the latest user locations and allows adding a new location for the currently logged-in student.

## Requirements

- macOS
- Xcode
- Optional: an iPhone/iPad running iOS/iPadOS 15 or above, if you want to test it on an actual device (rather than the simulator).

The app was tested in the Xcode simulator, running iOS 15.

## Installaton and Usage

1. Download or clone the repo.
2. cd into the project directory.
3. Open onthemap.xcodeproj.
4. Click the build button and use the app on your device / in the built-in simulator.
5. Log in using your Udacity account using your username and password.

## Contents

The project currently contains five ViewControllers, with six custom classes:

1. **LoginViewController** - The root view controller in the navigation stack. Allows users to log in to the app.
2. **StudentsViewsBaseClass** - The base class for the MapViewController and the StudentListViewController. Contains common functionality, including navigating to a user's link, logging out and displaying error messages.
3. **MapViewController** - The root view controller for tab navigation. Contains a map, on which a user can see the existing pins fetched from the API.
4. **StudentListViewController** - Second view controller for tab navigation. Contains a table, in which existing user locations are ordered by update date (from latest to earliest).
5. **LocationEditViewController** - The initial view controller for posting a location. Allows the user to enter their location in string form.
6. **LinkPostViewController** - The second view controller for posting a location. Gets a location for the user based on their string input and allows them to add a link before sending the data to the server.

The project also contains the following non-view-related files:

1. **OnTheMapHandler.swift** - Shared data handler for the app. Contains methods related to getting and posting user locations and fetching user data, as well as persistent user and location data used throughout the app.
2. **StudentInformation.swift** - Contains the structs for StudentInformation and StudentInformationArray (the response from the GET endpoint).
3. **CurrentUser.swift** - Contains the struct with the currently logged in user's data.
4. **APIClient.swift** - Shared API Client for the app. Contains methods for interacting with the API, parsing JSON responses and parsing errors. Also contains an APIClientError struct.
5. **APIEndpoints.swift** - Contains the enum and extension of the API endpoints.

## Known Issues

There are no current issues at the time.
