import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RecipePage(),
    );
  }
}

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {

  // --- task 5: The createLayout() function ---
  // This builds the top-level Column layout and returns it to the Scaffold body.
  Widget createLayout() {
    return Column(
      // task 2: Use SpaceBetween alignment for the outer Column layout
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Screen Header Text
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
          child: Text(
            "Favorite Recipes",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),

        // task 1: 6 individual items displayed inside the Column.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              Expanded(child: buildRecipeItem("images/veggie.jpg", "Veggie Stir-fry", "Colorful, crisp, vibrant")),
              const SizedBox(width: 12),
              Expanded(child: buildRecipeItem("images/salad.jpg", "Caesar Salad", "Crisp, creamy, tangy")),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              Expanded(child: buildRecipeItem("images/sushi.jpg", "Sushi Rolls", "Fresh, delicate, flavorful")),
              const SizedBox(width: 12),
              Expanded(child: buildRecipeItem("images/brownie.jpg", "Chocolate Brownie", "Rich, fudgy, sweet")),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              Expanded(child: buildRecipeItem("images/salmon.jpg", "Grilled Salmon", "Juicy, smoky, healthy")),
              const SizedBox(width: 12),
              Expanded(child: buildRecipeItem("images/beef.jpg", "Beef Tacos", "Spicy, crunchy, tasty")),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // builder ()
  // task 3: item-->Image, Heart icon-->top right,two text strings below.
  Widget buildRecipeItem(String imagePath, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stacking layers (heart icon) on top of image
        Stack(
          children: [
            // ClipRRect-->  rounded image corners
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.asset(
                imagePath,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Positioned pushes heart widget to top right corner
            const Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                radius: 16,
                child: Icon(Icons.favorite, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Item Name string
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 2),
        // Item Description string
        Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(" "),
      ),
      // task 5: set body to a SingleChildScrollView wrapping createLayout()
      body: SingleChildScrollView(
        child: createLayout(),
      ),
      // task 4: BottomNavigationBar has 5 items with empty text labels
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, // Highlights the middle heart icon by default
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
        ],
      ),
    );
  }
}