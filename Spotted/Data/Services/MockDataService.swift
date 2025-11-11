import Foundation

class MockDataService {
    static let shared = MockDataService()

    // MARK: - Zurich Hotspots
    let zurichLocations: [Location] = [
        // Train Stations
        Location(
            name: "Zürich Hauptbahnhof",
            type: .trainStation,
            address: "Bahnhofplatz, 8001 Zürich",
            latitude: 47.3779,
            longitude: 8.5403,
            activeUsers: 24
        ),
        Location(
            name: "Zürich Stadelhofen",
            type: .trainStation,
            address: "Stadelhoferplatz, 8001 Zürich",
            latitude: 47.3664,
            longitude: 8.5483,
            activeUsers: 12
        ),
        Location(
            name: "Zürich Oerlikon",
            type: .trainStation,
            address: "Oerlikon, 8050 Zürich",
            latitude: 47.4113,
            longitude: 8.5440,
            activeUsers: 8
        ),

        // Airport
        Location(
            name: "Zurich Airport",
            type: .airport,
            address: "Flughafenstrasse, 8058 Zürich",
            latitude: 47.4647,
            longitude: 8.5492,
            activeUsers: 18
        ),

        // Parks
        Location(
            name: "Zürichsee Promenade",
            type: .park,
            address: "Seepromenade, 8002 Zürich",
            latitude: 47.3662,
            longitude: 8.5418,
            activeUsers: 15
        ),
        Location(
            name: "Lindenhof",
            type: .park,
            address: "Lindenhof, 8001 Zürich",
            latitude: 47.3730,
            longitude: 8.5412,
            activeUsers: 9
        ),
        Location(
            name: "Rieterpark",
            type: .park,
            address: "Rieterpark, 8002 Zürich",
            latitude: 47.3588,
            longitude: 8.5297,
            activeUsers: 6
        ),

        // Cafes & Bars
        Location(
            name: "Café Odeon",
            type: .cafe,
            address: "Limmatquai 2, 8001 Zürich",
            latitude: 47.3692,
            longitude: 8.5440,
            activeUsers: 11
        ),
        Location(
            name: "Langstrasse Area",
            type: .bar,
            address: "Langstrasse, 8004 Zürich",
            latitude: 47.3782,
            longitude: 8.5277,
            activeUsers: 22
        ),
        Location(
            name: "Niederdorf",
            type: .bar,
            address: "Niederdorfstrasse, 8001 Zürich",
            latitude: 47.3734,
            longitude: 8.5450,
            activeUsers: 19
        ),

        // Gyms
        Location(
            name: "Zürich Sports Center",
            type: .gym,
            address: "Giesshübelstrasse 15, 8045 Zürich",
            latitude: 47.3622,
            longitude: 8.5289,
            activeUsers: 7
        )
    ]

    // MARK: - Mock Users
    func generateMockUsers() -> [User] {
        print("MockDataService: Generating mock users...")

        let names = [
            ("Lara", 27), ("Marco", 29), ("Sophie", 25), ("David", 31),
            ("Emma", 26), ("Lukas", 28), ("Nina", 24), ("Felix", 30),
            ("Mia", 27), ("Jonas", 29), ("Lisa", 26), ("Noah", 28),
            ("Anna", 25), ("Leon", 32), ("Sara", 27), ("Tim", 26),
            ("Julia", 24), ("Max", 30), ("Laura", 28), ("Simon", 27),
            ("Elena", 26), ("Daniel", 29), ("Olivia", 25), ("Thomas", 31),
            ("Isabella", 23), ("Paul", 28), ("Sophia", 27), ("Robin", 26),
            ("Maya", 29), ("Lucas", 30), ("Nora", 24), ("Samuel", 28),
            ("Amelie", 26), ("Benjamin", 27), ("Zoe", 25), ("Elias", 29),
            ("Leah", 28), ("Alexander", 30), ("Mila", 24), ("Adrian", 27)
        ]

        let bios = [
            "Love exploring Zurich's coffee scene ☕️",
            "Always up for spontaneous adventures",
            "Fitness enthusiast | Coffee addict",
            "Let's grab drinks in Niederdorf!",
            "New to Zurich, show me around?",
            "Weekend hiker 🏔️ Weekday professional",
            "Life's too short for boring dates",
            "Catch me at Zürichsee every weekend",
            "Looking for real connections, not just swipes",
            "Let's meet at the HB and go somewhere fun",
            "Part-time DJ, full-time dreamer 🎵",
            "Foodie on a mission to try every restaurant",
            "Dog lover looking for walking buddies 🐕",
            "Swiss by birth, global by heart 🌍",
            "Runner | Yogi | Amateur chef",
            "Can recommend the best fondue in town",
            "Just here to meet interesting people",
            "Beach volleyball on Sundays, who's in?",
            "Bookworm seeking library recommendations",
            "Craft beer enthusiast | Board game nerd",
            "Into photography and urban exploration",
            "Startup founder looking to network",
            "Languages: 🇩🇪 🇬🇧 🇫🇷 🇮🇹",
            "Concert junkie and festival goer",
            "Mountain biker seeking trail partners",
            "Yoga instructor by day, wine lover by night",
            "Tech geek who loves nature",
            "Aspiring chef testing recipes on friends",
            "Art gallery regular | Culture vulture",
            "Spontaneous traveler, let's explore!",
            "Rock climbing Saturdays, anyone?",
            "Coffee snob seeking espresso recommendations",
            "Making Zurich feel like home",
            "Always planning the next adventure",
            "Gamer looking for co-op partners 🎮",
            "Dance classes Wednesdays, join me?",
            "Podcast addict with strong opinions",
            "Sunrise chaser and sunset lover",
            "Trying to perfect my pasta recipe 🍝",
            "Live music > recorded music always"
        ]

        let ethnicities = ["Swiss", "German", "Italian", "French", "Spanish", "Mixed", nil, nil]

        let users = names.enumerated().map { index, nameAge in
            let favoriteLocations = Array(zurichLocations.shuffled().prefix(Int.random(in: 2...4)))

            // Some users have active check-ins (increased for demo)
            let hasCheckIn = index < 15
            let checkIn: CheckIn? = {
                if hasCheckIn, let location = zurichLocations.randomElement() {
                    return CheckIn(
                        userId: "user_\(index)",
                        location: location,
                        caption: index % 3 == 0 ? "☕️ Coffee break" : nil
                    )
                }
                return nil
            }()

            // Some users have stories
            let hasStory = index < 6
            let stories: [Story] = {
                if hasStory, let location = zurichLocations.randomElement() {
                    return [Story(
                        userId: "user_\(index)",
                        location: location,
                        imageUrl: "story_\(index)",
                        caption: "Great vibes here!",
                        viewCount: Int.random(in: 5...50)
                    )]
                }
                return []
            }()

            // Assign interests - ensure each category has users
            let allInterests = ["Short-term Fun", "Long-term Partner", "Gamers", "Creatives", "Foodies", "Travel Buddies", "Binge Watchers", "Sports", "Music Lovers", "Spiritual"]
            // First user gets first interest, second user gets second interest, etc.
            // Plus 2-3 additional random interests for variety
            var userInterests = [allInterests[index % allInterests.count]]
            let additionalInterests = allInterests.filter { $0 != userInterests[0] }.shuffled().prefix(Int.random(in: 1...3))
            userInterests.append(contentsOf: additionalInterests)

            // Generate prompts
            let promptQuestions = [
                "My simple pleasures",
                "I'm looking for",
                "A life goal of mine",
                "I geek out on",
                "The way to win me over is",
                "I'm overly competitive about",
                "We'll get along if",
                "Don't hate me if I",
                "The one thing I'd love to know about you is",
                "My most controversial opinion",
                "Together we could",
                "I'm actually legitimately bad at"
            ]
            let promptAnswers = [
                "Sunday morning coffee and croissants",
                "Someone who can make me laugh",
                "Starting my own business",
                "Vintage record collecting",
                "Cook me your favorite meal",
                "Board games, I never lose at Catan",
                "You love deep conversations over wine",
                "I'm always 10 minutes late",
                "What book changed your life?",
                "Pineapple belongs on pizza 🍕",
                "Plan spontaneous weekend trips",
                "Parallel parking, it's embarrassing",
                "Early morning hikes by the lake",
                "Someone adventurous and genuine",
                "Travel to every continent",
                "True crime documentaries",
                "Show up with my favorite chocolate",
                "Video games, prepare to lose",
                "You appreciate good food",
                "Cancel plans to stay in with movies",
                "Your go-to karaoke song",
                "Oat milk is superior to regular milk",
                "Start a food tour business",
                "Dancing like nobody's watching",
                "Fresh pastries from the local bakery",
                "Real conversations, not small talk",
                "Run a marathon someday",
                "Efficient packing techniques",
                "Bring your dog along on dates",
                "Trivia nights, I know random facts",
                "You can keep up with my energy",
                "Talk through movies, sorry not sorry",
                "If you've traveled somewhere unique",
                "The Office is overrated there I said it",
                "Build furniture from scratch",
                "Remembering people's names"
            ]
            let userPrompts = (0..<3).map { i -> ProfilePrompt in
                // First prompt has voice for some users
                let hasVoice = i == 0 && index % 2 == 0
                return ProfilePrompt(
                    question: promptQuestions[(index + i) % promptQuestions.count],
                    answer: promptAnswers[(index + i) % promptAnswers.count],
                    hasVoiceRecording: hasVoice,
                    voiceDuration: hasVoice ? Int.random(in: 15...45) : nil
                )
            }

            // Spontaneous status for some users
            let isSpontaneous = index % 4 == 0 // 25% of users are spontaneous
            let spontaneousActivities = ["Coffee", "Drinks", "Lunch", "Walk", "Workout"]
            let spontaneousUntil = isSpontaneous ? Date().addingTimeInterval(Double.random(in: 1800...7200)) : nil // 30min to 2hrs

            // Generate last activity for some users
            let activityTexts = [
                "coffee ☕️", "the sunset 🌅", "lunch at this spot",
                "amazing pastries here", "the atmosphere", "live music 🎵"
            ]
            let activityTypes: [UserActivity.ActivityType] = [.ordered, .enjoying, .arrived, .looking]
            let hasActivity = index % 3 == 0
            let lastActivity: UserActivity? = {
                if hasActivity,
                   let type = activityTypes.randomElement(),
                   let text = activityTexts.randomElement() {
                    return UserActivity(
                        userId: "user_\(index)",
                        type: type,
                        location: zurichLocations.randomElement(),
                        text: text,
                        timestamp: Date().addingTimeInterval(-Double.random(in: 300...3600)),
                        reactions: ["❤️": Int.random(in: 0...5), "🔥": Int.random(in: 0...3)]
                    )
                }
                return nil
            }()

            // Generate lifestyle details
            let jobs = ["Product Designer", "Software Engineer", "Marketing Manager", "Entrepreneur", "Teacher", "Photographer"]
            let companies = ["Google", "Startup", "Freelance", "ETH Zurich", "Local Business", "Tech Firm"]
            let schools = ["ETH Zurich", "University of Zurich", "ZHAW", "UZH", "Basel", "Geneva"]
            let heights = ["5'6\"", "5'8\"", "5'10\"", "6'0\"", "5'4\"", "5'9\""]
            let hometowns = ["Zurich", "Basel", "Geneva", "Bern", "Lausanne", "Lucerne"]
            let lookingFors = ["Long-term relationship", "Something casual", "New friends", "Not sure yet"]
            let drinkingOptions = ["Socially", "Never", "Frequently", "Sober"]
            let smokingOptions = ["No", "Socially", "Yes", "Trying to quit"]
            let exerciseOptions = ["Active", "Sometimes", "Everyday", "Never"]
            let sexualities = ["Straight", "Gay", "Lesbian", "Bisexual", "Queer", "Pansexual"]
            let kidsOptions = ["Don't have kids", "Have kids", "Want kids", "Don't want kids", "Open to kids"]

            // Generate realistic portrait URLs from randomuser.me API
            let gender = index % 2 == 0 ? "women" : "men"
            let baseId = index % 70 // randomuser.me has 0-99 portraits per gender
            let photos = (0..<6).map { photoIndex -> String in
                let portraitId = (baseId + photoIndex) % 70
                return "https://randomuser.me/api/portraits/\(gender)/\(portraitId).jpg"
            }

            let user = User(
                id: "user_\(index)",
                name: nameAge.0,
                age: nameAge.1,
                bio: bios[index % bios.count],
                photos: photos,
                profilePhoto: photos[0],
                ethnicity: ethnicities[index % ethnicities.count],
                isVerified: index % 3 == 0,
                favoriteHangouts: favoriteLocations,
                currentCheckIn: checkIn,
                stories: stories,
                interests: userInterests,
                prompts: userPrompts,
                job: jobs[index % jobs.count],
                company: companies[index % companies.count],
                school: schools[index % schools.count],
                height: heights[index % heights.count],
                hometown: hometowns[index % hometowns.count],
                lookingFor: lookingFors[index % lookingFors.count],
                drinking: drinkingOptions[index % drinkingOptions.count],
                smoking: smokingOptions[index % smokingOptions.count],
                exercise: exerciseOptions[index % exerciseOptions.count],
                education: "Bachelor's Degree",
                sexuality: sexualities[index % sexualities.count],
                kids: kidsOptions[index % kidsOptions.count],
                isSpontaneous: isSpontaneous,
                spontaneousUntil: spontaneousUntil,
                spontaneousActivity: isSpontaneous ? spontaneousActivities.randomElement() : nil,
                lastActivity: lastActivity
            )

            print("MockDataService: User \(index) - \(user.name) has interests: \(user.interests.joined(separator: ", "))")
            return user
        }

        print("MockDataService: Generated \(users.count) users total")

        // Count users per category for debugging
        let allInterests = ["Short-term Fun", "Long-term Partner", "Gamers", "Creatives", "Foodies", "Travel Buddies", "Binge Watchers", "Sports", "Music Lovers", "Spiritual"]
        for interest in allInterests {
            let count = users.filter { $0.interests.contains(interest) }.count
            print("MockDataService: '\(interest)' has \(count) users")
        }

        return users
    }

    // MARK: - Mock Conversations
    func generateMockConversations(users: [User]) -> [Conversation] {
        guard users.count >= 3 else { return [] }

        return [
            Conversation(
                participants: ["current_user", users[0].id],
                messages: [
                    Message(senderId: users[0].id, text: "Hey! I saw you're at Zürich HB too 👋", timestamp: Date().addingTimeInterval(-3600)),
                    Message(senderId: "current_user", text: "Yes! Just grabbed coffee", timestamp: Date().addingTimeInterval(-3500)),
                    Message(senderId: users[0].id, text: "Want to meet up? I'm near platform 12", timestamp: Date().addingTimeInterval(-300))
                ],
                matchedAt: Date().addingTimeInterval(-7200)
            ),
            Conversation(
                participants: ["current_user", users[1].id],
                messages: [
                    Message(senderId: users[1].id, text: "Love your profile! You hang out at Lindenhof?", timestamp: Date().addingTimeInterval(-86400)),
                    Message(senderId: "current_user", text: "All the time! Best spot in Zurich 😊", timestamp: Date().addingTimeInterval(-86000))
                ],
                matchedAt: Date().addingTimeInterval(-90000)
            )
        ]
    }

    // MARK: - Mock Matches
    func generateMockMatches(users: [User]) -> [Match] {
        guard users.count >= 3 else { return [] }

        return [
            Match(
                users: ["current_user", users[0].id],
                location: zurichLocations.first
            ),
            Match(
                users: ["current_user", users[1].id],
                location: zurichLocations.count > 4 ? zurichLocations[4] : zurichLocations.first
            ),
            Match(
                users: ["current_user", users[2].id],
                location: nil
            )
        ]
    }

    // Generate current user
    func generateCurrentUser() -> User {
        let prompts = [
            ProfilePrompt(question: "My simple pleasures", answer: "Morning runs by the lake and artisan coffee"),
            ProfilePrompt(question: "I'm looking for", answer: "Someone adventurous who loves exploring Zurich"),
            ProfilePrompt(question: "The way to win me over is", answer: "Good conversation over fondue")
        ]

        // Generate portrait URLs for current user
        let currentUserPhotos = (65..<71).map { portraitId -> String in
            return "https://randomuser.me/api/portraits/women/\(portraitId).jpg"
        }

        return User(
            id: "current_user",
            name: "You",
            age: 28,
            bio: "Looking for authentic connections in Zurich",
            photos: currentUserPhotos,
            profilePhoto: currentUserPhotos[0],
            ethnicity: "Swiss",
            isVerified: true,
            favoriteHangouts: Array(zurichLocations.prefix(3)),
            interests: ["Long-term Partner", "Foodies", "Travel Buddies"],
            prompts: prompts,
            job: "Product Designer",
            company: "Tech Startup",
            school: "ETH Zurich",
            height: "5'9\"",
            hometown: "Zurich",
            lookingFor: "Long-term relationship",
            drinking: "Socially",
            smoking: "No",
            exercise: "Active",
            education: "Master's Degree",
            sexuality: "Straight",
            kids: "Open to kids"
        )
    }
}
