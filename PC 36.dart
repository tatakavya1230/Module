import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Hover Text',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.blue[600],
      end: Colors.purple[600],
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Animated Hover Text'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Text with Hover Effect
            MouseRegion(
              onEnter: (_) => _onHover(true),
              onExit: (_) => _onHover(false),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        decoration: BoxDecoration(
                          color: _colorAnimation.value,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: _isHovered 
                                  ? Colors.purple.withOpacity(0.3)
                                  : Colors.blue.withOpacity(0.2),
                              blurRadius: _isHovered ? 20 : 10,
                              spreadRadius: _isHovered ? 5 : 2,
                            ),
                          ],
                        ),
                        child: Text(
                          _isHovered ? 'Hovering!' : 'Hover Me',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _isHovered ? 24 : 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: _isHovered ? 2.0 : 1.0,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            SizedBox(height: 50),
            
            // Additional animated text examples
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAnimatedTextCard(
                  text: 'Grow',
                  hoverText: 'Growing!',
                  color: Colors.green,
                  hoverColor: Colors.lightGreen,
                ),
                _buildAnimatedTextCard(
                  text: 'Shake',
                  hoverText: 'Shaking!',
                  color: Colors.orange,
                  hoverColor: Colors.deepOrange,
                ),
                _buildAnimatedTextCard(
                  text: 'Glow',
                  hoverText: 'Glowing!',
                  color: Colors.pink,
                  hoverColor: Colors.pinkAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTextCard({
    required String text,
    required String hoverText,
    required Color color,
    required Color hoverColor,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isHovered ? hoverColor : color,
              borderRadius: BorderRadius.circular(15),
              boxShadow: isHovered ? [
                BoxShadow(
                  color: hoverColor.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ] : [],
            ),
            child: AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 200),
              style: TextStyle(
                color: Colors.white,
                fontSize: isHovered ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
              child: Text(isHovered ? hoverText : text),
            ),
          ),
        );
      },
    );
  }
}
