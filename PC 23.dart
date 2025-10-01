import 'package:flutter/material.dart';

void main() {
  runApp(const ColorControlApp());
}

class ColorControlApp extends StatefulWidget {
  const ColorControlApp({super.key});

  @override
  State<ColorControlApp> createState() => _ColorControlAppState();
}

class _ColorControlAppState extends State<ColorControlApp> {
  // Shared state for About screen colors
  Color _aboutScaffoldColor = Colors.blue.shade50;
  Color _aboutAppBarColor = Colors.blue;

  void _updateAboutColors(Color scaffoldColor, Color appBarColor) {
    setState(() {
      _aboutScaffoldColor = scaffoldColor;
      _aboutAppBarColor = appBarColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Color Control App',
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.home,
      builder: (context, child) {
        // Pass color state to routes
        return ColorStateProvider(
          scaffoldColor: _aboutScaffoldColor,
          appBarColor: _aboutAppBarColor,
          updateColors: _updateAboutColors,
          child: child!,
        );
      },
    );
  }
}

// Dedicated routing class
class AppRouter {
  static const String home = '/';
  static const String about = '/about';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case about:
        return MaterialPageRoute(
          builder: (_) => const AboutScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
    }
  }
}

// Provider to pass color state down the widget tree
class ColorStateProvider extends InheritedWidget {
  final Color scaffoldColor;
  final Color appBarColor;
  final Function(Color, Color) updateColors;

  const ColorStateProvider({
    super.key,
    required this.scaffoldColor,
    required this.appBarColor,
    required this.updateColors,
    required super.child,
  });

  static ColorStateProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ColorStateProvider>();
  }

  @override
  bool updateShouldNotify(ColorStateProvider oldWidget) {
    return scaffoldColor != oldWidget.scaffoldColor ||
           appBarColor != oldWidget.appBarColor;
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorState = ColorStateProvider.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Control About Screen Colors',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Scaffold Color Controls
            const Text(
              'About Screen Scaffold Color:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ColorButton(
                  color: Colors.blue.shade50,
                  label: 'Blue',
                  onPressed: () => colorState?.updateColors(
                    Colors.blue.shade50,
                    colorState.appBarColor,
                  ),
                ),
                _ColorButton(
                  color: Colors.red.shade50,
                  label: 'Red',
                  onPressed: () => colorState?.updateColors(
                    Colors.red.shade50,
                    colorState.appBarColor,
                  ),
                ),
                _ColorButton(
                  color: Colors.green.shade50,
                  label: 'Green',
                  onPressed: () => colorState?.updateColors(
                    Colors.green.shade50,
                    colorState.appBarColor,
                  ),
                ),
                _ColorButton(
                  color: Colors.purple.shade50,
                  label: 'Purple',
                  onPressed: () => colorState?.updateColors(
                    Colors.purple.shade50,
                    colorState.appBarColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // AppBar Color Controls
            const Text(
              'About Screen AppBar Color:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ColorButton(
                  color: Colors.blue,
                  label: 'Blue',
                  onPressed: () => colorState?.updateColors(
                    colorState.scaffoldColor,
                    Colors.blue,
                  ),
                ),
                _ColorButton(
                  color: Colors.red,
                  label: 'Red',
                  onPressed: () => colorState?.updateColors(
                    colorState.scaffoldColor,
                    Colors.red,
                  ),
                ),
                _ColorButton(
                  color: Colors.green,
                  label: 'Green',
                  onPressed: () => colorState?.updateColors(
                    colorState.scaffoldColor,
                    Colors.green,
                  ),
                ),
                _ColorButton(
                  color: Colors.purple,
                  label: 'Purple',
                  onPressed: () => colorState?.updateColors(
                    colorState.scaffoldColor,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            
            const Spacer(),
            
            // Navigation Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRouter.about),
                icon: const Icon(Icons.info),
                label: const Text('Go to About Screen'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorState = ColorStateProvider.of(context);
    
    return Scaffold(
      backgroundColor: colorState?.scaffoldColor ?? Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('About Screen'),
        backgroundColor: colorState?.appBarColor ?? Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'About This App',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'This screen\'s background and AppBar colors are controlled from the Home screen. Use the color buttons on the Home screen to change these colors dynamically.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback onPressed;

  const _ColorButton({
    required this.color,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }
}
