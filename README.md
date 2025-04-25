# Tabebak

A modern healthcare mobile application built with Flutter that connects patients with healthcare professionals.

## About The App

Tabebak is a comprehensive healthcare platform designed to streamline the process of finding and connecting with healthcare providers. The app enables users to schedule appointments, receive consultations, and manage their health records in one place.

## Key Features

- **User Authentication**: Secure login and registration system
- **Doctor Directory**: Browse and search for healthcare professionals by specialty, location, and availability
- **Appointment Scheduling**: Book, reschedule, or cancel appointments with ease
- **AI Health Assistant**: Get preliminary health assessments and recommendations using our AI-powered chat feature
- **Medical Records**: Securely store and access your medical history
- **Notifications**: Receive reminders for upcoming appointments and medication schedules
- **In-App Messaging**: Communicate directly with healthcare providers
- **Hospital Finder**: Locate nearby hospitals with information about their services
- **Pharmacy Access**: Find pharmacies, check operating hours, and delivery options

## App Architecture

Tabebak is built using modern Flutter architecture principles:

- **Clean Architecture**: The app follows separation of concerns with distinct layers for presentation, business logic, and data
- **Firebase Backend**: Utilizes Firebase Authentication and Firestore for secure and scalable data management
- **GetX State Management**: Implements reactive state management for efficient UI updates and dependency injection
- **Responsive Design**: Adapts seamlessly to different screen sizes and orientations
- **Localization**: Supports multiple languages for broader accessibility
- **Offline Support**: Core features remain accessible even with limited connectivity

## Test Accounts

You can use the following pre-seeded accounts to test the application:

### Admin Account
- **Email**: admin@tabebak.com
- **Password**: admin123456

### Doctor Accounts
1. **Cardiologist**
   - **Email**: ahmed.ibrahim@tabebak.com
   - **Password**: doctor123456

2. **Dermatologist**
   - **Email**: nour.hassan@tabebak.com
   - **Password**: doctor123456

3. **Neurologist**
   - **Email**: khaled.mahmoud@tabebak.com
   - **Password**: doctor123456

4. **Pediatrician**
   - **Email**: fatma.ali@tabebak.com
   - **Password**: doctor123456

5. **Orthopedic Specialist**
   - **Email**: omar.sayed@tabebak.com
   - **Password**: doctor123456

## Available Healthcare Services

### Medical Specialties
The app provides access to doctors across 12 medical specialties:
- Cardiology
- Dermatology
- Neurology
- Orthopedics
- Pediatrics
- Psychiatry
- Ophthalmology
- Gynecology
- Urology
- ENT (Ear, Nose, and Throat)
- Dentistry
- Family Medicine

### Hospitals
Users can find information about hospitals including:
- Cairo University Hospital
- Al Salam International Hospital
- Dar Al Fouad Hospital
- Alexandria International Hospital

Each hospital listing includes contact details, location data, available services, and ratings.

### Pharmacies
The app provides information about:
- El Ezaby Pharmacy
- Seif Pharmacy
- 19011 Pharmacy
- Roshdy Pharmacy

Pharmacy listings include operating hours, delivery options, and contact information.

## Installation

### Prerequisites
- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 2.17.0 or higher)
- Android Studio / Xcode for emulators
- A physical device or emulator for testing
- Firebase project setup

### Steps to Install
1. Clone the repository:
   ```
   git clone https://github.com/yourusername/tabebak.git
   ```

2. Navigate to the project directory:
   ```
   cd tabebak
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## AI Feature

Our app integrates an advanced AI health assistant that:
- Provides preliminary symptom assessment
- Offers general health advice based on user inputs
- Helps users determine if they should seek professional medical attention
- Answers common health questions with medically verified information


## How to Use the App

1. **Login/Registration**: Use one of the pre-seeded accounts or register as a new patient
2. **Find a Doctor**: Browse doctors by specialty or use the search functionality
3. **View Doctor Profiles**: Check doctor bios, ratings, and availability
4. **Book Appointments**: Select available time slots to schedule consultations
5. **Find Hospitals**: Locate nearby hospitals and view their services
6. **Locate Pharmacies**: Find pharmacies with delivery options
7. **AI Health Assistant**: Use the chat interface for health guidance

## Development

This project follows standard Flutter architecture and best practices. To contribute:

1. Fork the repository
2. Create a new branch for your feature
3. Add your changes and test thoroughly
4. Submit a pull request

## Resources

For more information about Flutter development:

