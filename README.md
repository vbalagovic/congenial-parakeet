# RealSocial Flutter App

A simple Flutter application with Supabase integration that allows users to:

- Login using Google or email & password authentication
- View their favorite words list
- Add new words to the list
- Receive toast notifications at specific word count milestones

## Features

- **Authentication**: Google sign-in using Supabase
- **Data Management**: Store and retrieve favorite words from Supabase database
- **Real-time Updates**: Real-time synchronization of the word list using Supabase Realtime
- **Navigation**: Auto_route for efficient navigation
- **State Management**: Riverpod for clean and testable state management
- **UI Enhancements**: Smooth animations and toast notifications
- **Security**: Backend security with Row Level Security policies

## Project Structure

``` bash
lib/
├── main.dart                # Application entry point
├── app_router.dart          # Routing configuration
├── constants.dart           # Application constants
├── guards/
│   └── auth_guard.dart      # Authentication guard for routing
├── models/
│   └── word_model.dart      # Word data model
├── providers/
│   ├── auth_provider.dart   # Authentication state management
│   ├── words_provider.dart  # Words state management
│   └── theme_provider.dart  # Theme state management
├── screens/
│   ├── login_screen.dart    # Login screen UI
│   ├── app_screen.dart      # Main app screen with words list
│   └── splash_screen.dart   # Splash screen under which auth is checked
├── services/
│   └── supabase_service.dart # Supabase API integration
└── widgets/
    ├── word_list.dart       # Words list widget
    ├── word_input.dart      # Input widget for adding new words
    └── toast_notification.dart # Custom toast notification
```

## Setup Instructions

### Prerequisites

- Flutter SDK `3.27.3`
- Supabase account

### Configuration Steps

1. **Clone the repository**

```bash
git clone https://github.com/vbalagovic/congenial-parakeet
cd congenial-parakeet
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure Supabase**

- Create a new Supabase project
- Execute the SQL commands in the `supabase/setup.sql` file to set up tables and security policies
- Enable Google authentication in Supabase dashboard
- Go to Database > Replication and enable Realtime for the favorite_words table
- Configure Google OAuth in Supabase Authentication settings
- Go to Authentication > Providers > Google and set it up with your Google credentials
- Set redirect URL to: io.supabase.realsocial://login-callback

4. **Set up environment variables**

Create a `.env` file in the project root with your Supabase credentials:

```
SUPABASE_URL=https://your-supabase-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

5. **Generate Auto_route files**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

6. **Run the application**

```bash
flutter run
```

## Security Features

- **Row Level Security**: Users can only access their own data
- **Secure Authentication**: OAuth authentication through Supabase
- **Data Validation**: Server-side validation with PostgreSQL constraints

## Additional Notes

- The application demonstrates optimistic UI updates and real-time synchronization
- Toast notifications appear at specific milestone counts (5, 12, 17, 21, and 25 words)
- Clean architecture principles are followed to ensure maintainability and scalability
