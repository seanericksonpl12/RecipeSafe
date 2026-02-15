import Foundation

#if DEBUG
extension Recipe {
  static let allRecipesMock: [Recipe] = [
    recipeMockScampi, recipeMockSpaghetti, recipeMockChicken, recipeMockRice, recipeMockPizza
  ]
  
  static let recipeMockScampi = Recipe(
    title: "Garlic Butter Shrimp Scampi",
    description: "A quick and flavorful shrimp dish tossed in a garlic butter white wine sauce over linguine.",
    ingredients: ["1 lb shrimp, peeled and deveined", "8 oz linguine", "4 cloves garlic, minced", "3 tbsp butter", "1/4 cup white wine", "2 tbsp lemon juice", "Red pepper flakes", "Fresh parsley, chopped"],
    instructions: ["Cook linguine according to package directions.", "Melt butter in a large skillet over medium-high heat.", "Add garlic and red pepper flakes, cook 30 seconds.", "Add shrimp and cook until pink, about 2 minutes per side.", "Pour in white wine and lemon juice, simmer 2 minutes.", "Toss with linguine and garnish with parsley."],
    img: .none,
    url: URL(string: "https://example.com/shrimp-scampi"),
    prepTime: "10 min",
    cookTime: "15 min"
  )
  
  static let recipeMockSpaghetti = Recipe(
    title: "Best Spaghetti & Meatballs",
    description: "Classic homemade meatballs in a rich marinara sauce served over spaghetti.",
    ingredients: ["1 lb ground beef", "1/2 cup breadcrumbs", "1 egg", "1/4 cup parmesan", "1 lb spaghetti", "2 cups marinara sauce", "2 cloves garlic, minced", "Salt and pepper"],
    instructions: ["Mix ground beef, breadcrumbs, egg, parmesan, salt, and pepper.", "Roll into 1-inch meatballs.", "Brown meatballs in a skillet over medium heat.", "Add marinara sauce and simmer 20 minutes.", "Cook spaghetti and serve topped with meatballs."],
    img: .none,
    url: URL(string: "https://example.com/spaghetti-meatballs"),
    prepTime: "15 min",
    cookTime: "30 min"
  )
  
  static let recipeMockChicken = Recipe(
    title: "Lemon Herb Roasted Chicken",
    description: "Juicy whole roasted chicken with lemon, thyme, and rosemary.",
    ingredients: ["1 whole chicken (4 lbs)", "2 lemons", "4 sprigs fresh thyme", "3 sprigs fresh rosemary", "4 tbsp butter, softened", "6 cloves garlic", "Salt and pepper", "1 lb baby potatoes"],
    instructions: ["Preheat oven to 425°F.", "Pat chicken dry and rub with softened butter, salt, and pepper.", "Stuff cavity with lemon halves, garlic, thyme, and rosemary.", "Place chicken on a bed of baby potatoes in a roasting pan.", "Roast for 1 hour 15 minutes until internal temp reaches 165°F.", "Rest 10 minutes before carving."],
    img: .none,
    url: nil,
    prepTime: "15 min",
    cookTime: "1 hr 15 min"
  )
  
  static let recipeMockRice = Recipe(
    title: "Thai Basil Fried Rice",
    description: "A quick weeknight fried rice with Thai basil, soy sauce, and a fried egg on top.",
    ingredients: ["3 cups day-old rice", "2 tbsp soy sauce", "1 tbsp fish sauce", "1 tbsp oyster sauce", "3 cloves garlic, minced", "2 Thai chilies, sliced", "1 cup Thai basil leaves", "2 eggs", "1 tbsp vegetable oil"],
    instructions: ["Heat oil in a wok over high heat.", "Add garlic and chilies, stir-fry 30 seconds.", "Add rice and toss to coat.", "Pour in soy sauce, fish sauce, and oyster sauce.", "Stir-fry 3 minutes until rice is heated through.", "Fold in Thai basil leaves.", "Fry eggs separately and serve on top."],
    img: .none,
    url: URL(string: "https://example.com/thai-basil-fried-rice"),
    prepTime: "5 min",
    cookTime: "10 min"
  )
  
  static let recipeMockPizza = Recipe(
    title: "Classic Margherita Pizza",
    description: "Simple and delicious pizza with fresh mozzarella, tomatoes, and basil.",
    ingredients: ["1 pizza dough ball", "1/2 cup San Marzano tomato sauce", "8 oz fresh mozzarella, sliced", "Fresh basil leaves", "1 tbsp olive oil", "Salt"],
    instructions: ["Preheat oven to 500°F with a pizza stone.", "Stretch dough into a 12-inch round.", "Spread tomato sauce evenly over the dough.", "Arrange mozzarella slices on top.", "Bake 8-10 minutes until crust is golden and cheese is bubbly.", "Top with fresh basil and drizzle with olive oil."],
    img: .none,
    url: nil,
    prepTime: "10 min",
    cookTime: "10 min"
  )
}
#endif
