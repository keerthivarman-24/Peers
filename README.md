class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text("About App"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            Text(
              "Anonymous Doubt Solving App",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "This app allows students to ask doubts anonymously, "
              "share solutions, upload files, and learn collaboratively.",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            GitHubProfileCard(),
          ],
        ),
      ),
    );
  }
}
# Peers
