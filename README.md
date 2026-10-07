# Little Lemon Food Ordering

SwiftUI iOS capstone app for the Little Lemon restaurant. It includes three-page onboarding, a searchable food menu, category filters, dish details, an order confirmation, and a profile that is saved on the device.

## Run the app

1. Open `LittleLemonFoodOrdering.xcodeproj` in Xcode 16 or later.
2. Select the **LittleLemonFoodOrdering** scheme and an iPhone simulator running iOS 17 or later.
3. Run the project. No third-party packages or API keys are required.
4. Complete the three onboarding pages using a first name, last name, and valid email address. Phone is optional.

A network connection is required to download the initial menu and remote dish photos. Menu entries are saved in Core Data and remain available if a later refresh fails. Pull down on the menu to refresh.

## Design

The Home screen follows the four sections shown in [Home-Wireframe.jpg](Design/Home-Wireframe.jpg): header, hero, menu breakdown, and food menu list. The editable vector version is [Home-Wireframe.svg](Design/Home-Wireframe.svg).

## Features

- Three onboarding pages with Next and native Back navigation; Register is enabled only for valid details.
- Header with the Little Lemon logo and profile button.
- Hero with the restaurant description, image, and search field.
- Selectable category chips with a yellow selected state. Multiple categories can be selected; All clears category selections.
- Menu fetched using URLSession from the Meta course REST API, decoded into Swift structures, and imported into Core Data without duplicates.
- Alphabetical sorting using localized comparison and case/diacritic insensitive substring search. Search and category selections work together.
- Menu rows show the name, description, price, and image. Tapping a row opens dish details with quantity selection and an order confirmation alert.
- Profile fields are populated from onboarding. Save changes stores personal details and notification preferences across launches; Discard changes restores the saved values.
- Log out removes the saved profile and resets onboarding. Cached public menu data remains on the device.

The order confirmation is a local demonstration; it does not send an order or payment to a restaurant. Notification preferences are saved locally and do not subscribe the user to a mailing service.

## Reviewer walkthrough

1. On a fresh install, check that onboarding displays Step 1 of 3, Step 2 of 3, and Step 3 of 3. Use Back to revisit a step. Enter valid details and register.
2. On Home, verify the logo/profile header, green restaurant hero with search, category chips, and summarized menu rows.
3. Search for `gréEk` to find Greek Salad. Select Desserts while this search is active to get an empty result; select All to see Greek Salad again. Clear the search to restore the full list.
4. Select Desserts to display Lemon Desert. The upstream API currently supplies five dishes and no Drinks items, so Drinks correctly shows an empty result.
5. Open a dish, adjust the quantity, tap Place order, and check the alert. Use Back to return to Home.
6. Open Profile and verify the entered details. Edit a value or notification preference, tap Save changes, restart the app, and confirm the saved edit is retained.
7. Tap Log out. Restart the app and verify that onboarding is shown with blank personal fields.

## Verification

Built and checked with Xcode 27.0 on iPhone 17 Pro Simulator, iOS 26.5. The project targets iOS 17.0 or later. All 15 XCTest cases passed. They cover registration validation, profile persistence and logout, malformed stored data, SQLite persistence, menu import/update validation, category/search combination, case/diacritic insensitive search, and alphabetical sorting. The reviewer walkthrough was also exercised in the simulator.

Run the tests with Product → Test in Xcode.

## Files

- `Views/`: onboarding, Home, Profile, and dish detail screens.
- `Models/`: profile/session state, REST models, menu query, Dish, and Core Data model.
- `Services/`: REST loading and database persistence.
- `LittleLemonFoodOrderingTests/`: XCTest coverage.
- `Design/`: Home wireframe image, SVG, and diagram generation script (requires Python with Pillow only when regenerating the diagram).

## Data and assets

Menu API: https://raw.githubusercontent.com/Meta-Mobile-Developer-PC/Working-With-Data-API/main/menu.json

Restaurant logo and food imagery come from the Meta Little Lemon course materials. Menu names and descriptions are displayed as supplied by the API, including its spelling. Personal profile information is saved locally with UserDefaults; this course demonstration does not use a remote account service.
