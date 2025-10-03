import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Cards with Slide Animation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ImageCardsPage(),
    );
  }
}

class ImageCard {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final DateTime createdAt;

  ImageCard({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory ImageCard.fromMap(Map<String, dynamic> data, String docId) {
    return ImageCard(
      id: docId,
      imageUrl: data['imageUrl'] ?? '',
      title: data['title'] ?? 'Untitled',
      description: data['description'] ?? 'No description',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }
}

class ImageCardsPage extends StatefulWidget {
  @override
  _ImageCardsPageState createState() => _ImageCardsPageState();
}

class _ImageCardsPageState extends State<ImageCardsPage>
    with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = true;
  String _errorMessage = '';
  List<ImageCard> _imageCards = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadImageCards();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0), // Start from right
      end: Offset.zero, // End at center
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadImageCards() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Option 1: Use Firestore (uncomment to use real Firestore)
      /*
      QuerySnapshot querySnapshot = await _firestore
          .collection('images') // Replace 'images' with your collection name
          .orderBy('createdAt', descending: true)
          .get();

      List<ImageCard> cards = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        cards.add(ImageCard.fromMap(data, doc.id));
      }
      */

      // Option 2: Mock data for demonstration
      List<ImageCard> cards = [
        ImageCard(
          id: '1',
          imageUrl: 'https://picsum.photos/400/300?random=1',
          title: 'Beautiful Landscape',
          description: 'A stunning view of mountains and valleys with golden hour lighting.',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
        ),
        ImageCard(
          id: '2',
          imageUrl: 'https://picsum.photos/400/300?random=2',
          title: 'Ocean Waves',
          description: 'Peaceful ocean waves crashing against the shore at sunset.',
          createdAt: DateTime.now().subtract(Duration(days: 2)),
        ),
        ImageCard(
          id: '3',
          imageUrl: 'https://picsum.photos/400/300?random=3',
          title: 'Forest Path',
          description: 'A winding path through a dense forest with sunlight filtering through trees.',
          createdAt: DateTime.now().subtract(Duration(days: 3)),
        ),
        ImageCard(
          id: '4',
          imageUrl: 'https://picsum.photos/400/300?random=4',
          title: 'City Skyline',
          description: 'Modern city skyline at night with illuminated buildings and lights.',
          createdAt: DateTime.now().subtract(Duration(days: 4)),
        ),
        ImageCard(
          id: '5',
          imageUrl: 'https://picsum.photos/400/300?random=5',
          title: 'Mountain Peak',
          description: 'Snow-capped mountain peak reaching towards the clear blue sky.',
          createdAt: DateTime.now().subtract(Duration(days: 5)),
        ),
        ImageCard(
          id: '6',
          imageUrl: 'https://picsum.photos/400/300?random=6',
          title: 'Desert Dunes',
          description: 'Rolling sand dunes in the desert with dramatic shadows and textures.',
          createdAt: DateTime.now().subtract(Duration(days: 6)),
        ),
      ];

      setState(() {
        _imageCards = cards;
        _isLoading = false;
      });

      // Start slide animation
      _slideController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading images: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _nextCard() {
    if (_currentIndex < _imageCards.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _slideController.reset();
      _slideController.forward();
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _slideController.reset();
      _slideController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Image Gallery',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadImageCards,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    }

    if (_imageCards.isEmpty) {
      return _buildEmptyWidget();
    }

    return _buildImageCardsView();
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'Loading images...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            SizedBox(height: 20),
            Text(
              'Error Loading Images',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
            SizedBox(height: 10),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadImageCards,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 20),
            Text(
              'No Images Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'There are no images in the collection yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadImageCards,
              icon: Icon(Icons.refresh),
              label: Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCardsView() {
    return Column(
      children: [
        // Current Image Card with Slide Animation
        Expanded(
          flex: 3,
          child: Container(
            margin: EdgeInsets.all(20),
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return SlideTransition(
                  position: _slideAnimation,
                  child: _buildImageCard(_imageCards[_currentIndex]),
                );
              },
            ),
          ),
        ),
        
        // Navigation Controls
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
                      onPressed: _currentIndex > 0 ? _previousCard : null,
                      icon: Icon(Icons.arrow_back),
                      label: Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _currentIndex < _imageCards.length - 1 ? _nextCard : null,
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
                
                // Image Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _imageCards.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? Colors.blue[600]
                            : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 10),
                
                // Image Counter
                Text(
                  '${_currentIndex + 1} of ${_imageCards.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(ImageCard card) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.network(
                    card.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.grey[600],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Failed to load image',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // Text Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      card.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 8),
                    
                    // Description
                    Expanded(
                      child: Text(
                        card.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    SizedBox(height: 8),
                    
                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        SizedBox(width: 4),
                        Text(
                          _formatDate(card.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
