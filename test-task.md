**Swim Success**

Flutter Developer — Test Task

| Position | Flutter Developer |
| :---- | :---- |
| **Level** | Strong Junior / Middle |
| **Time estimate** | 6–8 hours total |
| **Submission** | GitHub repo \+ Loom video (3–5 min) |
| **Deadline** | 5 days from receiving this task |

The task consists of two screens. Each screen evaluates different skills. Please submit both as a single Flutter project.

# **Task 1 — Pace Selector**

| Skills evaluated | Custom UI, interactive widgets, state management, API call |
| :---- | :---- |
| **Time estimate** | 3–4 hours |

## **Overview**

Implement the pace selector screen shown in the reference video. The screen allows users to set their fastest 100m freestyle time, which is used to determine their swimmer level.

*Reference video:* [Open in Google Drive](https://drive.google.com/file/d/1Vj2-nVxXao4j2yLpMNBy0bxLg4AofUL6/view?usp=sharing)

## **Requirements**

**Pace input (MIN : SEC)**

* Two large numeric displays for minutes and seconds

* Up/down arrows to increment or decrement each value

* Tap to edit — allow direct numeric input

* Validate: seconds must be 0–59

**Slider**

* A horizontal slider below the timer

* Visible tick marks or labels at key points (e.g. 1:10, 1:30, 2:00)

* Moving the slider updates the MIN:SEC display in real time

* Editing MIN:SEC also moves the slider

**Swimmer level**

* Display the current level below the timer (e.g. Beginner, Intermediate, Advanced, Elite)

* Level updates dynamically as the value changes

* Define the time ranges yourself and document them in the README

**Continue button**

* On tap, convert the selected time to total seconds (MIN \* 60 \+ SEC)

* Send a POST request to https://jsonplaceholder.typicode.com/posts with body:

| { "pace\_seconds": 137 } |
| :---- |

* Show a loading indicator while the request is in progress

* Handle network errors gracefully (show an error message)

* Use a debounce of \~500ms if you trigger requests on slider change

## **Design**

Dark background, light text, accent color of your choice. Pixel-perfect match to the reference is not required — clean and readable is enough.

# **Task 2 — User List**

| Skills evaluated | API integration, JSON parsing, typed models, list rendering, navigation |
| :---- | :---- |
| **Time estimate** | 3–4 hours |

## **Overview**

Fetch data from a public REST API and display it in a user-friendly interface. The overall design, layout, navigation flow, and user experience are intentionally left open-ended — make your own decisions and be ready to explain them.

## **API endpoint**

| GET https://jsonplaceholder.typicode.com/users |
| :---- |

## **User List screen**

* Fetch and display users from the API

* Show at minimum: Name, Email, Phone number

* Add search or filter by name

* Allow users to refresh the data

## **User Detail screen**

* Tapping a user navigates to a detail screen

* Display additional information about the selected user

## **Technical requirements**

1. Parse the response into typed models. No raw Map\<String, dynamic\> in the UI layer.

2. Handle loading state and network errors gracefully.

3. State management of your choice — explain your decision in the README.

4. Clean, maintainable project structure.



# **What we evaluate**

| Area | What we look for |
| :---- | :---- |
| **Code quality & readability** | Naming, structure, no magic numbers. |
| **Architecture & structure** | Sensible project layout, separation of concerns. |
| **API integration** | Typed models, loading and error states handled. |
| **UI / UX** | Readable layout, thoughtful design decisions. |
| **State management** | Sensible choice, clear separation from UI. |
| **README & Loom** | Can you explain your own decisions clearly? |


