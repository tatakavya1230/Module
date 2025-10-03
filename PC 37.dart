import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Slide Animation',
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
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  int _currentImageIndex = 0;
  bool _isAutoPlaying = false;
  
  final List<String> _imageUrls = [
    'https://picsum.photos/400/300?random=1',
    'https://picsum.photos/400/300?random=2',
    'https://picsum.photos/400/300?random=3',
    'https://picsum.photos/400/300?random=4',
    'https://picsum.photos/400/300?random=5',
  ];

  @override
  void initState() {
    super.initState();
    
    // Slide animation controller
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Fade animation controller
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Scale animation controller
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0), // Start from right
      end: Offset.zero, // End at center
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _nextImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % _imageUrls.length;
    });
    _playSlideAnimation();
  }

  void _previousImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex - 1 + _imageUrls.length) % _imageUrls.length;
    });
    _playSlideAnimation();
  }

  void _playSlideAnimation() {
    _slideController.reset();
    _fadeController.reset();
    _scaleController.reset();
    
    _slideController.forward();
    _fadeController.forward();
    _scaleController.forward();
  }

  void _toggleAutoPlay() {
    setState(() {
      _isAutoPlaying = !_isAutoPlaying;
    });
    
    if (_isAutoPlaying) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    Future.delayed(Duration(seconds: 3), () {
      if (_isAutoPlaying) {
        _nextImage();
        _startAutoPlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Image Slide Animation'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isAutoPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleAutoPlay,
          ),
        ],
      ),
      body: Column(
        children: [
          // Main Image Slide Area
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Background image
                    Positioned.fill(
                      child: Image.network(
                        _imageUrls[_currentImageIndex],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image,
                              size: 100,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Animated overlay
                    AnimatedBuilder(
                      animation: _slideController,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Image ${_currentImageIndex + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black,
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Control Buttons
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Navigation Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _previousImage,
                        icon: Icon(Icons.arrow_back),
                        label: Text('Previous'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _nextImage,
                        icon: Icon(Icons.arrow_forward),
                        label: Text('Next'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Auto Play Toggle
                  ElevatedButton.icon(
                    onPressed: _toggleAutoPlay,
                    icon: Icon(_isAutoPlaying ? Icons.pause : Icons.play_arrow),
                    label: Text(_isAutoPlaying ? 'Stop Auto Play' : 'Start Auto Play'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAutoPlaying ? Colors.red[600] : Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Image Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _imageUrls.length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == index
                              ? Colors.blue[600]
                              : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
